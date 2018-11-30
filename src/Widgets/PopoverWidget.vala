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

public class Power.Widgets.PopoverWidget : Gtk.Box {
    public bool is_in_session { get; construct; default = false; }
    private DeviceList device_list;
    private Wingpanel.Widgets.Separator device_separator = null;
    private ScreenBrightness? screen_brightness;
    private AppList app_list;
    private Wingpanel.Widgets.Separator last_separator = null;

    public PopoverWidget (bool is_in_session) {
        Object (is_in_session: is_in_session, orientation: Gtk.Orientation.VERTICAL);
    }

    construct {
        var dm = Services.DeviceManager.get_default ();
        var settings = new GLib.Settings ("io.elementary.desktop.wingpanel.power");

        device_list = new DeviceList ();
        //debug ("show list of batteries");
        pack_start (device_list);

        if (dm.backlight.present) {
            if (dm.has_battery) {
                device_separator = new Wingpanel.Widgets.Separator ();
                pack_start (device_separator);
            }

            debug ("show brightness slider");
            screen_brightness = new ScreenBrightness ();
            pack_start (screen_brightness);
        }

        var show_percent_switch = new Wingpanel.Widgets.Switch (_("Show Percentage"), settings.get_boolean ("show-percentage"));

        var show_percent_revealer = new Gtk.Revealer ();
        show_percent_revealer.add (show_percent_switch);

        var show_settings_button = new Gtk.ModelButton ();
        show_settings_button.text = _("Power Settings…");

        if (is_in_session) {
            app_list = new AppList ();
            this.pack_start (app_list); /* The app-list contains an own separator that is displayed if necessary. */
        }

        if (is_in_session || dm.has_battery) {
            last_separator = new Wingpanel.Widgets.Separator ();
            this.pack_start (last_separator);
            add (show_percent_revealer);
            if (is_in_session) {
                this.pack_end (show_settings_button);
            }
        }

        dm.notify["has-battery"].connect((s, p) => {
            bool had_separator = last_separator != null;
            bool has_separator = is_in_session || dm.has_battery;

            if (has_separator != had_separator) {
                if (has_separator) {
                    this.pack_start (last_separator = new Wingpanel.Widgets.Separator ());
                    last_separator.show ();
                } else {
                    this.remove (last_separator);
                    last_separator = null;
                }
            }

            if (dm.backlight.present) {
                bool had_battery = device_separator != null;
                if (dm.has_battery != had_battery) {
                    if (dm.has_battery) {
                        device_separator = new Wingpanel.Widgets.Separator ();
                        this.pack_start (device_separator);
                        this.reorder_child (device_separator, 1);
                        device_separator.show ();
                    } else {
                        this.remove (device_separator);
                        device_separator = null;
                    }
                }
            }
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

    public void slim_down () {
        if (is_in_session) {
            app_list.clear_list ();
        }
    }
}
