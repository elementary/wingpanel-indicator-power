/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2024 elementary, Inc. (https://elementary.io)
 */

public class Power.Widgets.PowerModeList : Gtk.Box {
    private const string ACTION_GROUP_PREFIX = "power-mode-list";
    private const string ACTION_PREFIX = ACTION_GROUP_PREFIX + ".";
    private const string ACTION_PLUGGED_IN = "profile-plugged-in";
    private const string ACTION_ON_BATTERY = "profile-on-good-battery";

    public static bool successfully_initialized { get; private set; default = true; }

    private static Services.DBusInterfaces.PowerProfile? pprofile;
    private static Services.DeviceManager device_manager;
    private static GLib.Settings? settings;

    static construct {
        device_manager = Services.DeviceManager.get_default ();

        var schema = SettingsSchemaSource.get_default ().lookup ("io.elementary.settings-daemon.power", true);
        if (schema != null && schema.has_key ("profile-plugged-in") && schema.has_key ("profile-on-good-battery")) {
            settings = new GLib.Settings ("io.elementary.settings-daemon.power");
        } else {
            warning ("settings-daemon schema not found, power mode setting not available");
            successfully_initialized = false;
        }

        // Connect always to know which profiles are available on the system
        try {
            pprofile = Bus.get_proxy_sync (
                BusType.SYSTEM,
                Services.DBusInterfaces.POWER_PROFILES_DAEMON_NAME,
                Services.DBusInterfaces.POWER_PROFILES_DAEMON_PATH,
                DBusProxyFlags.NONE
            );
        } catch (Error e) {
            critical (e.message);
            successfully_initialized = false;
        }
    }

    private PowerModeCheck saver_radio;
    private PowerModeCheck balanced_radio;
    private PowerModeCheck performance_radio;

    construct {
        if (pprofile == null || settings == null) {
            return;
        }

        var action_plugged_in = settings.create_action (ACTION_PLUGGED_IN);
        var action_on_battery = settings.create_action (ACTION_ON_BATTERY);

        var action_group = new SimpleActionGroup ();
        action_group.add_action (action_plugged_in);
        action_group.add_action (action_on_battery);

        insert_action_group (ACTION_GROUP_PREFIX, action_group);

        orientation = VERTICAL;
        margin_start = 6;
        margin_top = 6;
        margin_bottom = 6;
        margin_end = 6;

        saver_radio = new PowerModeCheck ("power-mode-powersaver-symbolic", _("Power Saver"), "power-saver");
        balanced_radio = new PowerModeCheck ("power-mode-balanced-symbolic", _("Balanced"), "balanced");
        performance_radio = new PowerModeCheck ("power-mode-performance-symbolic", _("Performance"), "performance");

        foreach (unowned var profile in pprofile.profiles) {
            switch (profile.get ("Profile").get_string ()) {
                case "power-saver":
                    append (saver_radio);
                    break;
                case "balanced":
                    append (balanced_radio);
                    break;
                case "performance":
                    append (performance_radio);
                    break;
            }
        }

        update_on_battery_state ();
        device_manager.notify["on-battery"].connect (update_on_battery_state);
    }

    private void update_on_battery_state () {
        var action = ACTION_PREFIX + (device_manager.on_battery ? ACTION_ON_BATTERY : ACTION_PLUGGED_IN);
        saver_radio.action_name = action;
        balanced_radio.action_name = action;
        performance_radio.action_name = action;
    }

    private class PowerModeCheck : Gtk.CheckButton {
        public string icon_name { get; construct; }
        public new string label { get; construct; }
        public string profile { get; construct; }

        public PowerModeCheck (string icon_name, string label, string profile) {
            Object (
                icon_name: icon_name,
                label: label,
                profile: profile
            );
        }

        construct {
            var image = new Gtk.Image.from_icon_name (icon_name);

            var label_widget = new Gtk.Label (label);

            var box = new Gtk.Box (HORIZONTAL, 6) {
                halign = START,
                margin_top = 3,
                margin_bottom = 3,
                margin_start = 2,
                margin_end = 3
            };
            box.append (image);
            box.append (label_widget);

            child = box;
            action_target = profile;

            get_style_context ().add_class ("image-button");
        }
    }
}
