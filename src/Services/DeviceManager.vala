/*
 * Copyright (c) 2011-2015 elementary LLC. (https://elementary.io)
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
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class Power.Services.DeviceManager : Object {
    private const string UPOWER_INTERFACE = "org.freedesktop.UPower";
    private const string UPOWER_PATH = "/org/freedesktop/UPower";

    private static DeviceManager? instance = null;

    private DBusInterfaces.UPower? upower = null;
    private DBusInterfaces.Properties? upower_properties = null;

    public Services.Backlight backlight { get; construct; }
    public Gee.HashMap<string, Device> devices { get; private set; }
    public Gee.Iterator batteries { get; private set; }
    public Device primary_battery { get; private set; }
    public bool has_battery { get; private set; }
    public bool on_battery { get; private set; }
    public bool on_low_battery { get; private set; }

    public signal void battery_registered (string device_path, Device battery);
    public signal void battery_deregistered (string device_path);

    construct {
        backlight = new Services.Backlight ();
            
        if (connect_to_bus ()) {
            update_properties ();
            read_devices ();
            update_batteries ();
            connect_signals ();
        }    
    }

    // singleton one class object in memory. use instance to get data.
    public static unowned DeviceManager get_default () {
        if (instance == null) {
            instance = new DeviceManager ();
        }

        return instance;
    }

    private bool connect_to_bus () {
        devices = new Gee.HashMap<string, Device> ();

        try {
            upower = Bus.get_proxy_sync (BusType.SYSTEM, UPOWER_INTERFACE, UPOWER_PATH, DBusProxyFlags.NONE);
            upower_properties = Bus.get_proxy_sync (BusType.SYSTEM, UPOWER_INTERFACE, UPOWER_PATH, DBusProxyFlags.NONE);

            debug ("Connection to UPower bus established");

            return upower != null & upower_properties != null;
        } catch (Error e) {
            critical ("Connecting to UPower bus failed: %s", e.message);

            return false;
        }
    }

    public void read_devices () {
        try {
            var devices = upower.EnumerateDevices ();

            foreach (ObjectPath device_path in devices) {
                register_device (device_path);
            }
        } catch (Error e) {
            critical ("Reading UPower devices failed: %s", e.message);
        }
    }

    private void connect_signals () {
        upower_properties.PropertiesChanged.connect ((name, directory, array) => {
            update_properties ();
            update_batteries ();
        });

        upower.DeviceAdded.connect (register_device);
        upower.DeviceRemoved.connect (deregister_device);
    }

    private void update_properties () {
        try {
            on_battery = upower_properties.Get (UPOWER_INTERFACE, "OnBattery").get_boolean ();
        } catch (Error e) {
            critical ("Updating UPower properties failed: %s", e.message);
        }
    }

    private void update_batteries () {
        batteries = devices.filter ((entry) => {
            var device = entry.value;

            return Utils.type_is_battery (device.device_type);
        });

        has_battery = batteries.has_next ();

        if (has_battery) {
            update_primary_battery ();
        }
    }

    private void update_primary_battery () {
        Device? main_battery = null;
        Device? alternate_battery = null;

        devices.@foreach ((entry) => {
            var device = entry.value;
            var is_battery = Utils.type_is_battery (device.device_type);

            if (is_battery) {
                if (device.device_type == DEVICE_TYPE_BATTERY) {
                    main_battery = device;

                    return false;
                } else {
                    if (alternate_battery == null) {
                        alternate_battery = device;
                    }
                }
            }

            return true;
        });

        if (has_battery) {
            if (main_battery != null) {
                if (primary_battery != main_battery) {
                    primary_battery = main_battery;
                }
            } else if (alternate_battery != null) {
                if (primary_battery != alternate_battery) {
                    primary_battery = alternate_battery;
                }
            }
        }
    }

    private void register_device (ObjectPath device_path) {
        var device = new Device (device_path);

        devices.@set (device_path, device);
        debug ("Device \"%s\" registered", device_path);
        update_batteries ();

        if (Utils.type_is_battery (device.device_type)) {
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

        if (Utils.type_is_battery (device.device_type)) {
            battery_deregistered (device_path);
        }
    }
}
