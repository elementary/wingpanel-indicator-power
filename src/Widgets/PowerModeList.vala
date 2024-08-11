/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2024 elementary, Inc. (https://elementary.io)
 */

using Power.Services.DBusInterfaces;

public class Power.Widgets.PowerModeList : Gtk.Box {
    public static bool successfully_initialized { get; private set; default = true; }

    private static PowerProfile? pprofile;
    private static GLib.Settings? settings;

    public string settings_key { get; construct; }

    private Gtk.RadioButton saver_radio;
    private Gtk.RadioButton balanced_radio;
    private Gtk.RadioButton performance_radio;

    private const string ICON_RES = "/io/elementary/desktop/wingpanel/power/scalable/categories/";

    public PowerModeList (bool on_battery) {
        Object (
            settings_key: on_battery ? "profile-on-good-battery" : "profile-plugged-in",
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 0,
            margin: 6
        );
    }

    static construct {
        var schema = SettingsSchemaSource.get_default ().lookup ("io.elementary.settings-daemon.power", true);
        if (schema != null && schema.has_key ("profile-plugged-in") && schema.has_key ("profile-on-good-battery")) {
            settings = new GLib.Settings ("io.elementary.settings-daemon.power");
        } else {
            warning ("settings-daemon schema not found, will connect to power-profiles-daemon directly");
        }

        try {
            pprofile = Bus.get_proxy_sync (BusType.SYSTEM, POWER_PROFILES_DAEMON_NAME, POWER_PROFILES_DAEMON_PATH, DBusProxyFlags.NONE);
        } catch (Error e) {
            critical (e.message);
            successfully_initialized = false;
        }
    }

    construct {
        if (pprofile == null) {
            return;
        }

        build_ui ();
        build_events ();
    }

    private void build_ui () {
        var saver_icon = new Gtk.Image.from_resource (ICON_RES + "power-mode-powersaver-symbolic.svg");

        var saver_label = new Gtk.Label (_("Power Saver"));

        var saver_button_box = new Gtk.Box (HORIZONTAL, 6) {
            halign = Gtk.Align.START,
            margin = 4
        };
        saver_button_box.pack_start (saver_icon);
        saver_button_box.pack_end (saver_label);

        saver_radio = new Gtk.RadioButton (null);
        saver_radio.get_style_context ().add_class ("image-button");
        saver_radio.add (saver_button_box);

        var balanced_icon = new Gtk.Image.from_resource (ICON_RES + "power-mode-balanced-symbolic.svg");

        var balanced_label = new Gtk.Label (_("Balanced"));

        var balanced_button_box = new Gtk.Box (HORIZONTAL, 6) {
            halign = Gtk.Align.START,
            margin = 4
        };
        balanced_button_box.pack_start (balanced_icon);
        balanced_button_box.pack_end (balanced_label);

        balanced_radio = new Gtk.RadioButton.from_widget (saver_radio);
        balanced_radio.get_style_context ().add_class ("image-button");
        balanced_radio.add (balanced_button_box);

        var performance_icon = new Gtk.Image.from_resource (ICON_RES + "power-mode-performance-symbolic.svg");

        var performance_label = new Gtk.Label (_("Performance"));

        var performance_button_box = new Gtk.Box (HORIZONTAL, 6) {
            halign = Gtk.Align.START,
            margin = 4
        };
        performance_button_box.pack_start (performance_icon);
        performance_button_box.pack_end (performance_label);

        performance_radio = new Gtk.RadioButton.from_widget (saver_radio);
        performance_radio.get_style_context ().add_class ("image-button");
        performance_radio.add (performance_button_box);

        foreach (unowned var profile in pprofile.profiles) {
            switch (profile.get ("Profile").get_string ()) {
                case "power-saver":
                    pack_start (saver_radio);
                    break;
                case "balanced":
                    pack_start (balanced_radio);
                    break;
                case "performance":
                    pack_start (performance_radio);
                    break;
            }
        }
    }

    private void build_events () {
        update_active_profile ();

        saver_radio.toggled.connect (() => {
            if (saver_radio.active) {
                settings?.set_string (settings_key, "power-saver");
                pprofile.active_profile = "power-saver";
            }
        });

        balanced_radio.toggled.connect (() => {
            if (balanced_radio.active) {
                settings?.set_string (settings_key, "balanced");
                pprofile.active_profile = "balanced";
            }
        });

        performance_radio.toggled.connect (() => {
            if (performance_radio.active) {
                settings?.set_string (settings_key, "performance");
                pprofile.active_profile = "performance";
            }
        });
    }

    private void update_active_profile () {
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
}
