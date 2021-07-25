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
 * Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

public class Power.Services.Device : Object {
    private const string DEVICE_INTERFACE = "org.freedesktop.UPower";

    [CCode (type_signature = "u")]
    public enum State {
        UNKNOWN = 0,
        CHARGING = 1,
        DISCHARGING = 2,
        EMPTY = 3,
        FULLY_CHARGED = 4,
        PENDING_CHARGE = 5,
        PENDING_DISCHARGE = 6
    }

    [CCode (type_signature = "u")]
    public enum Technology {
        UNKNOWN = 0,
        LITHIUM_ION = 1,
        LITHIUM_POLYMER = 2,
        LITHIUM_IRON_PHOSPHATE = 3,
        LEAD_ACID = 4,
        NICKEL_CADMIUM = 5,
        NICKEL_METAL_HYDRIDE = 6
    }

    [CCode (type_signature = "u")]
    public enum Type {
        UNKNOWN = 0,
        LINE_POWER = 1,
        BATTERY = 2,
        UPS = 3,
        MONITOR = 4,
        MOUSE = 5,
        KEYBOARD = 6,
        PDA = 7,
        PHONE = 8,
        MEDIA_PLAYER = 9,
        TABLET = 10,
        COMPUTER = 11,
        GAMING_INPUT = 12,
        PEN = 13;
        public unowned string? get_name () {
            switch (this) {
                /* TODO: Do we want to differentiate between batteries and rechargeable batteries? (See German: Batterie <-> Akku) */
                case BATTERY:
                    return _("Battery");
                case UPS:
                    return _("UPS");
                case MONITOR:
                    return _("Display");
                case MOUSE:
                    return _("Mouse");
                case KEYBOARD:
                    return _("Keyboard");
                case PDA:
                    return _("PDA");
                case PHONE:
                    return _("Phone");
                case MEDIA_PLAYER:
                    return _("Media Player");
                case TABLET:
                    return _("Tablet");
                case COMPUTER:
                    return _("Computer");
                case GAMING_INPUT:
                    return _("Controller");
                case PEN:
                    return _("Pen");
                case LINE_POWER:
                    return _("Plugged In");
                default:
                    return null;
            }
        }

        public unowned string? get_icon_name () {
            switch (this) {
                case UPS:
                    return "uninterruptible-power-supply";
                case MOUSE:
                    return "input-mouse";
                case KEYBOARD:
                    return "input-keyboard";
                case PDA:
                case PHONE:
                    return "phone";
                case MEDIA_PLAYER:
                    return "multimedia-player";
                case TABLET:
                case PEN:
                    return "input-tablet";
                case GAMING_INPUT:
                    return "input-gaming";
                case COMPUTER:
                case MONITOR:
                case UNKNOWN:
                case BATTERY:
                case LINE_POWER:
                default:
                    return null;
            }
        }
    }

    private string device_path = "";

    private DBusInterfaces.Device? device = null;

    public bool has_history { get; private set; }
    public bool has_statistics { get; private set; }
    public bool is_present { get; private set; }
    public bool is_rechargeable { get; private set; }
    public bool online { get; private set; }
    public bool power_supply { get; private set; }
    public double capacity { get; private set; }
    public double energy { get; private set; }
    public double energy_empty { get; private set; }
    public double energy_full { get; private set; }
    public double energy_full_design { get; private set; }
    public double energy_rate { get; private set; }
    public double luminosity { get; private set; }
    public double percentage { get; private set; }
    public double temperature { get; private set; }
    public double voltage { get; private set; }
    public int64 time_to_empty { get; private set; }
    public int64 time_to_full { get; private set; }
    public string model { get; private set; }
    public string native_path { get; private set; }
    public string serial { get; private set; }
    public string vendor { get; private set; }
    public Power.Services.Device.State state { get; private set; }
    public Power.Services.Device.Technology technology { get; private set; }
    public Power.Services.Device.Type device_type { get; private set; }
    public uint64 update_time { get; private set; }

    // Extra property
    public bool is_charging { get; private set; }
    public bool is_a_battery { get; private set; }

    public signal void properties_updated ();

    public Device (string device_path) {
        this.device_path = device_path;

        if (connect_to_bus ()) {
            update_properties ();
            connect_signals ();
        }
    }

    private bool connect_to_bus () {
        try {
            device = Bus.get_proxy_sync (BusType.SYSTEM, DEVICE_INTERFACE, device_path, DBusProxyFlags.NONE);

            debug ("Connection to UPower device established");
        } catch (Error e) {
            critical ("Connecting to UPower device failed: %s", e.message);
        }

        return device != null;
    }

    private void connect_signals () {
        device.g_properties_changed.connect (update_properties);
    }

    private void update_properties () {
        try {
            device.refresh ();
        } catch (Error e) {
            critical ("Updating the upower device parameters failed: %s", e.message);
        }

        has_history = device.has_history;
        has_statistics = device.has_statistics;
        is_present = device.is_present;
        is_rechargeable = device.is_rechargeable;
        online = device.online;
        power_supply = device.power_supply;
        capacity = device.capacity;
        energy = device.energy;
        energy_empty = device.energy_empty;
        energy_full = device.energy_full;
        energy_full_design = device.energy_full_design;
        energy_rate = device.energy_rate;
        luminosity = device.luminosity;
        percentage = device.percentage;
        temperature = device.temperature;
        voltage = device.voltage;
        time_to_empty = device.time_to_empty;
        time_to_full = device.time_to_full;
        model = device.model;
        native_path = device.native_path;
        serial = device.serial;
        vendor = device.vendor;
        device_type = determine_device_type ();
        state = (Power.Services.Device.State) device.state;
        technology = (Power.Services.Device.Technology) device.technology;
        update_time = device.update_time;

        is_charging = state == Power.Services.Device.State.FULLY_CHARGED || state == Power.Services.Device.State.CHARGING;
        is_a_battery = device_type != Power.Services.Device.Type.UNKNOWN && device_type != Power.Services.Device.Type.LINE_POWER;

        properties_updated ();
    }

    private Power.Services.Device.Type determine_device_type () {
        // In case a all-in-one keyboard is clasified as mouse because of a mouse pointer. we should show it as keyboard.
        // referenced upstream issue https://gitlab.freedesktop.org/upower/upower/-/issues/139
        if (device.Type == Type.MOUSE && device.model.contains ("keyboard")) {
            return (Power.Services.Device.Type) Type.KEYBOARD;
        }
        return (Power.Services.Device.Type) device.Type;
    }

    public string get_symbolic_icon_name_for_battery () {
        return get_icon_name_for_battery () + "-symbolic";
    }

    public string get_icon_name_for_battery () {
        if (!is_a_battery) {
            return "preferences-system-power-symbolic";
        }
        if (percentage == 100 && is_charging) {
            return "battery-full-charged";
        }
        unowned string battery_icon = get_battery_icon ();
        if (is_charging) {
            return battery_icon + "-charging";
        } else {
            return battery_icon;
        }
    }

    private unowned string get_battery_icon () {
        if (percentage <= 0) {
            return "battery-good";
        }

        if (percentage < 10 && (time_to_empty == 0 || time_to_empty < 30 * 60)) {
            return "battery-empty";
        }

        if (percentage < 30) {
            return "battery-caution";
        }

        if (percentage < 60) {
            return "battery-low";
        }

        if (percentage < 80) {
            return "battery-good";
        }

        return "battery-full";
    }

    public string get_info () {
        var percent = (int)Math.round (percentage);

        if (!is_a_battery) {
            return "";
        }

        if (percent <= 0) {
            return _("Calculating…");
        }

        if (percent == 100 ) {
            return _("Charged");
        }
        var info = "";

        if (is_charging) {
            info += _("%i%% charged").printf (percent);

            if (time_to_full > 0) {
                info += " - ";
                if (time_to_full >= 86400) {
                    var days = time_to_full / 86400;
                    info += dngettext (
                        Constants.GETTEXT_PACKAGE,
                        "%lld day until full",
                        "%lld days until full",
                        (ulong) days
                    ).printf (days);
                } else if (time_to_full >= 3600) {
                    var hours = time_to_full / 3600;
                    info += dngettext (
                        Constants.GETTEXT_PACKAGE,
                        "%lld hour until full",
                        "%lld hours until full",
                        (ulong) hours
                    ).printf (hours);
                } else if (time_to_full >= 60) {
                    var minutes = time_to_full / 60;
                    info += dngettext (
                        Constants.GETTEXT_PACKAGE,
                        "%lld minute until full",
                        "%lld minutes until full",
                        (ulong) minutes
                    ).printf (minutes);
                } else {
                    info += dngettext (
                        Constants.GETTEXT_PACKAGE,
                        "%lld second until full",
                        "%lld seconds until full",
                        (ulong) time_to_full
                    ).printf (time_to_full);
                }
            }
        } else {
            info += _("%i%% remaining").printf (percent);

            if (time_to_empty > 0) {
                info += " - ";
                if (time_to_empty >= 86400) {
                    var days = time_to_empty / 86400;
                    info += dngettext (
                        Constants.GETTEXT_PACKAGE,
                        "%lld day until empty",
                        "%lld days until empty",
                        (ulong) days
                    ).printf (days);
                } else if (time_to_empty >= 3600) {
                    var hours = time_to_empty / 3600;
                    info += dngettext (
                        Constants.GETTEXT_PACKAGE,
                        "%lld hour until empty",
                        "%lld hours until empty",
                        (ulong) hours
                    ).printf (hours);
                } else if (time_to_empty >= 60) {
                    var minutes = time_to_empty / 60;
                    info += dngettext (
                        Constants.GETTEXT_PACKAGE,
                        "%lld minute until empty",
                        "%lld minutes until empty",
                        (ulong) minutes
                    ).printf (minutes);
                } else {
                    info += dngettext (
                        Constants.GETTEXT_PACKAGE,
                        "%lld second until empty",
                        "%lld seconds until empty",
                        (ulong) time_to_empty
                    ).printf (time_to_empty);
                }
            }
        }

        return info;
    }
}
