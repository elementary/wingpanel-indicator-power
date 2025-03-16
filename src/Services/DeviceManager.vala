/*
 * Copyright (c) 2011-2021 elementary LLC. (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

public class Power.Services.DeviceManager : Object {
    private const string UPOWER_INTERFACE = "org.freedesktop.UPower";
    private const string UPOWER_PATH = "/org/freedesktop/UPower";

    private const string POWER_SETTINGS_INTERFACE = "org.gnome.SettingsDaemon.Power";
    private const string POWER_SETTINGS_PATH = "/org/gnome/SettingsDaemon/Power";

    private static DeviceManager? instance = null;

    private DBusInterfaces.UPower? upower = null;
    private DBusInterfaces.PowerSettings? iscreen = null;

    private DDCUtil.DisplayHandle? display_handle = null;
    private DDCUtil.NonTableVcpValue? display_value = null;

    public Services.Backlight backlight { get; construct; }
    public Gee.HashMap<string, Device> devices { get; private set; }
    public Gee.Iterator batteries { get; private set; }
    public Device display_device { get; private set; }
    public bool has_battery { get; private set; }
    public bool on_battery { get; private set; }
    public bool on_low_battery { get; private set; }
    public int brightness {
        get {
            if (!backlight.present) {
                print ("VJR BACKLIST PRESENT = FALSE");
                return -1;
            }

            if (iscreen != null) {
                return iscreen.brightness;
            }

            if (display_handle != null) {
                DDCUtil.Status status;
                DDCUtil.VcpFeatureCode feature = 0x10;
                status = DDCUtil.get_non_table_vcp_value (display_handle, feature, out display_value);
                if (status == DDCUtil.Status.OK) {
                    return (int) display_value.sh << 8 | display_value.sl;
                }
                print ("VJR BACKLIST STATUS = NOT OK");
            }

            print ("VJR HANDLE = NULL");

            return -1;
        }

        set {
            if (!backlight.present) {
                print ("VJR BACKLIST PRESENT = FALSE2");
                return;
            }

            if (iscreen != null) {
                iscreen.brightness = value.clamp (0, 100);
                return;
            }

            if (display_handle != null) {
                DDCUtil.VcpFeatureCode feature = 0x10;
                value = value.clamp (0, (int) display_value.mh << 8 | display_value.ml);
                uint8 hibyte = (uint8) ((value >> 8) & 0xff);
                uint8 lobyte = (uint8) (value & 0xff);
                DDCUtil.set_non_table_vcp_value (display_handle, feature, hibyte, lobyte);
            }
            print ("VJR BACKLIST HANDLE = NULL2");
        }
    }

    public signal void battery_registered (string device_path, Device battery);
    public signal void battery_deregistered (string device_path);
    public signal void brightness_changed (int brightness);

    construct {
        backlight = new Services.Backlight ();

        connect_to_bus.begin ((obj, res) => {
            if (connect_to_bus.end (res)) {
                update_properties ();
                read_devices ();
                update_batteries ();
                connect_signals ();
            }
        });

        if (iscreen != null) {
            return;
        }

        DDCUtil.Status status;

        DDCUtil.DisplayInfoList dlist;

        status = DDCUtil.get_display_info_list2 (false, out dlist);

        if (status != DDCUtil.Status.OK || dlist.info.length <= 0) {
            return;
        }

        status = DDCUtil.open_display2 (dlist.info[0].dref, true, out display_handle);

        if (status != DDCUtil.Status.OK || display_handle == null) {
            return;
        }

        DDCUtil.VcpFeatureCode feature = 0x10;
        DDCUtil.get_non_table_vcp_value (display_handle, feature, out display_value);
    }

    // singleton one class object in memory. use instance to get data.
    public static unowned DeviceManager get_default () {
        if (instance == null) {
            instance = new DeviceManager ();
        }

        return instance;
    }

    private async bool connect_to_bus () {
        devices = new Gee.HashMap<string, Device> ();

        try {
            upower = yield Bus.get_proxy (
                BusType.SYSTEM,
                UPOWER_INTERFACE,
                UPOWER_PATH,
                DBusProxyFlags.NONE
            );
            debug ("Connection to UPower bus established");

            iscreen = yield Bus.get_proxy (
                BusType.SESSION,
                POWER_SETTINGS_INTERFACE,
                POWER_SETTINGS_PATH,
                DBusProxyFlags.GET_INVALIDATED_PROPERTIES
            );
            debug ("Connection to Power Settings bus established");

            return true;
        } catch (Error e) {
            critical ("Connecting to UPower or PowerSettings bus failed: %s", e.message);

            return false;
        }
    }

    private bool determine_attached_device (ObjectPath device_path) {
        var device = new Device (device_path);

        // this prevents from showing weird devices to show up.
        // such as a laptops track pad pointer to show up as wacom tablet with no battery.
        if ((device.technology == Device.Technology.UNKNOWN) &&
            (device.state == Device.State.UNKNOWN)) {
            return false;
        }
        return true;
    }

    public void read_devices () {
        if (upower == null) {
            return;
        }

        try {
            // Add Display Device for Panel display
            var display_device_path = upower.get_display_device ();
            display_device = new Device (display_device_path);
            // Fetch other devices for Detail in Panel
            var devices = upower.enumerate_devices ();
            foreach (ObjectPath device_path in devices) {
                if (determine_attached_device (device_path) == true) {
                    register_device (device_path);
                }
            }
        } catch (Error e) {
            critical ("Reading UPower devices failed: %s", e.message);
        }
    }

    private void connect_signals () requires (upower != null && iscreen != null) {
        upower.g_properties_changed.connect (() => {
            update_properties ();
            update_batteries ();
        });

        upower.DeviceAdded.connect (register_device);
        upower.DeviceRemoved.connect (deregister_device);

        ((DBusProxy)iscreen).g_properties_changed.connect ((changed_properties, invalidated_properties) => {
            var changed_brightness = changed_properties.lookup_value ("Brightness", new VariantType ("i"));
            if (changed_brightness != null) {
                brightness_changed (changed_brightness.get_int32 ());
            }
        });
    }

    private void update_properties () requires (upower != null) {
        on_battery = upower.on_battery;
    }

    private void update_batteries () {
        batteries = devices.filter ((entry) => {
            var device = entry.value;
            return device.is_a_battery;
        });

        has_battery = batteries.has_next ();
    }

    private void register_device (ObjectPath device_path) {
        var device = new Device (device_path);

        devices.@set (device_path, device);
        debug ("Device \"%s\" registered", device_path);
        update_batteries ();

        if (device.is_a_battery) {
            battery_registered (device_path, device);
        }
    }

    private void deregister_device (ObjectPath device_path) {
        if (!devices.has_key (device_path)) {
            return;
        }

        var device = devices.@get (device_path);

        if (!devices.unset (device_path)) {
            return;
        }

        debug ("Device \"%s\" deregistered", device_path);
        update_batteries ();

        if (device.is_a_battery) {
            battery_deregistered (device_path);
        }
    }

    public void change_brightness (int change) {
        if (iscreen != null) {
            brightness = iscreen.brightness + change;
        }
    }
}
