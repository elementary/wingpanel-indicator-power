/*
 * Copyright (c) 2011-2018 elementary LLC. (https://elementary.io)
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

public class Power.Widgets.PopoverWidget : Gtk.Grid {
    public bool is_in_session { get; construct; default = false; }

    private static Services.DeviceManager dm;

    private AppList app_list;
    private Gtk.Revealer device_separator_revealer;
    private Gtk.Revealer last_separator_revealer;

    public PopoverWidget (bool is_in_session) {
        Object (is_in_session: is_in_session);
    }

    static construct {
        dm = Services.DeviceManager.get_default ();
    }

    construct {
        var settings = new GLib.Settings ("io.elementary.desktop.wingpanel.power");

        var device_list = new DeviceList ();

        var device_separator = new Wingpanel.Widgets.Separator ();

        device_separator_revealer = new Gtk.Revealer ();
        device_separator_revealer.add (device_separator);

        var last_separator = new Wingpanel.Widgets.Separator ();

        last_separator_revealer = new Gtk.Revealer ();
        last_separator_revealer.add (last_separator);

        var show_percent_switch = new Wingpanel.Widgets.Switch (_("Show Percentage"), settings.get_boolean ("show-percentage"));

        var show_percent_revealer = new Gtk.Revealer ();
        show_percent_revealer.add (show_percent_switch);

        var show_settings_button = new Gtk.ModelButton ();
        show_settings_button.text = _("Power Settings…");

        attach (device_list, 0, 0);
        attach (device_separator_revealer, 0, 1);

        if (dm.backlight.present) {
            var screen_brightness = new ScreenBrightness ();
            attach (screen_brightness, 0, 2);
        }

        attach (last_separator_revealer, 0, 4);
        attach (show_percent_revealer, 0, 5);

        if (is_in_session) {
            app_list = new AppList ();
            attach (app_list, 0, 3); /* The app-list contains an own separator that is displayed if necessary. */
            attach (show_settings_button, 0, 6);
        }

        update_device_seperator_revealer ();
        update_last_seperator_revealer ();

        dm.notify["has-battery"].connect((s, p) => {
            update_device_seperator_revealer ();
            update_last_seperator_revealer ();
        });

        settings.bind ("show-percentage", show_percent_switch.get_switch (), "active", SettingsBindFlags.DEFAULT);

        dm.bind_property ("has-battery", show_percent_revealer, "reveal-child", GLib.BindingFlags.DEFAULT | GLib.BindingFlags.SYNC_CREATE);

        show_settings_button.clicked.connect (() => {
            try {
                AppInfo.launch_default_for_uri ("settings://power", null);
            } catch (Error e) {
                warning ("Failed to open power settings: %s", e.message);
            }
        });
    }

    private void update_device_seperator_revealer () {
        device_separator_revealer.reveal_child = dm.backlight.present && dm.has_battery;
    }

    private void update_last_seperator_revealer () {
        last_separator_revealer.reveal_child = is_in_session || dm.has_battery;
    }

    public void slim_down () {
        if (is_in_session) {
            app_list.clear_list ();
        }
    }
}
