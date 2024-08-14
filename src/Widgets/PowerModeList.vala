/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2024 elementary, Inc. (https://elementary.io)
 */

public class Power.Widgets.PowerModeList : Gtk.Box {
    public static bool successfully_initialized { get; private set; default = true; }

    private static Services.DBusInterfaces.PowerProfile? pprofile;
    private static Services.DeviceManager device_manager;
    private static GLib.Settings? settings;

    private string settings_key;
    private Gtk.RadioButton saver_radio;
    private Gtk.RadioButton balanced_radio;
    private Gtk.RadioButton performance_radio;

    class construct {
        device_manager = Services.DeviceManager.get_default ();

        var schema = SettingsSchemaSource.get_default ().lookup ("io.elementary.settings-daemon.power", true);
        if (schema != null && schema.has_key ("profile-plugged-in") && schema.has_key ("profile-on-good-battery")) {
            settings = new GLib.Settings ("io.elementary.settings-daemon.power");
        } else {
            warning ("settings-daemon schema not found, will connect to power-profiles-daemon directly");
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

    construct {
        if (pprofile == null) {
            return;
        }

        orientation = VERTICAL;
        margin_start = 6;
        margin_top = 6;
        margin_bottom = 6;
        margin_end = 6;

        saver_radio = new PowerModeCheck ("power-mode-powersaver-symbolic", _("Power Saver"));

        balanced_radio = new PowerModeCheck ("power-mode-balanced-symbolic", _("Balanced")) {
            group = saver_radio
        };

        performance_radio = new PowerModeCheck ("power-mode-performance-symbolic", _("Performance")) {
            group = saver_radio
        };

        foreach (unowned var profile in pprofile.profiles) {
            switch (profile.get ("Profile").get_string ()) {
                case "power-saver":
                    add (saver_radio);
                    break;
                case "balanced":
                    add (balanced_radio);
                    break;
                case "performance":
                    add (performance_radio);
                    break;
            }
        }

        update_on_battery_state ();
        device_manager.notify["on-battery"].connect (() => {
            update_on_battery_state ();
        });

        saver_radio.toggled.connect (() => {
            if (saver_radio.active) {
                if (settings != null) {
                    settings.set_string (settings_key, "power-saver");
                } else {
                    pprofile.active_profile = "power-saver";
                }
            }
        });

        balanced_radio.toggled.connect (() => {
            if (balanced_radio.active) {
                if (settings != null) {
                    settings.set_string (settings_key, "balanced");
                } else {
                    pprofile.active_profile = "balanced";
                }
            }
        });

        performance_radio.toggled.connect (() => {
            if (performance_radio.active) {
                if (settings != null) {
                    settings.set_string (settings_key, "performance");
                } else {
                    pprofile.active_profile = "performance";
                }
            }
        });
    }

    private void update_on_battery_state () {
        settings_key = device_manager.on_battery ? "profile-on-good-battery" : "profile-plugged-in";
        update_active_profile ();
    }

    public void update_active_profile () {
        if (settings != null) {
            switch (settings.get_string (settings_key)) {
                case "power-saver":
                    saver_radio.active = true;
                    break;
                case "balanced":
                    balanced_radio.active = true;
                    break;
                case "performance":
                    performance_radio.active = true;
                    break;
            }
        } else {
            switch (pprofile.active_profile) {
                case "power-saver":
                    saver_radio.active = true;
                    break;
                case "balanced":
                    balanced_radio.active = true;
                    break;
                case "performance":
                    performance_radio.active = true;
                    break;
            }
        }
    }

    private class PowerModeCheck : Gtk.RadioButton {
        public string icon_name { get; construct; }
        public new string label { get; construct; }

        public PowerModeCheck (string icon_name, string label) {
            Object (
                icon_name: icon_name,
                label: label
            );
        }

        construct {
            var image = new Gtk.Image.from_icon_name (icon_name, BUTTON);

            var label_widget = new Gtk.Label (label);

            // Kinda funky spacing to center icon between label and radio
            var box = new Gtk.Box (HORIZONTAL, 1) {
                halign = START,
                margin_top = 3,
                margin_bottom = 3,
                margin_start = 2,
                margin_end = 3
            };
            box.add (image);
            box.add (label_widget);

            child = box;

            get_style_context ().add_class ("image-button");
        }
    }
}
