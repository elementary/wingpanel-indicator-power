/*
 * Copyright (c) 2011-2016 elementary LLC. (https://elementary.io)
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
    private Widgets.BrightnessSlider brightness_slider;
    private AppList app_list;
    private Wingpanel.Widgets.Separator last_separator = null;

    private Wingpanel.Widgets.Switch show_percent_switch;

    public signal void settings_shown ();

    // Refering to a relative change in the brightness value (Power.Utils.STEP)
    public signal void brightness_change (int change);

    // The integer returned is absolute
    public signal void brightness_new_value (int new_value);

    public PopoverWidget (bool is_in_session) {
        Object (is_in_session: is_in_session, orientation: Gtk.Orientation.VERTICAL);
    }

    public int slider_val {
        get { return brightness_slider.val; }
        set { brightness_slider.val = value.clamp (0, 100); }
    }

    construct {
        var dm = Services.DeviceManager.get_default ();
        var sm = Services.SettingsManager.get_default ();

        device_list = new DeviceList ();
        pack_start (device_list);

        if (dm.backlight.present) {
            if (dm.has_battery) {
                device_separator = new Wingpanel.Widgets.Separator ();
                pack_start (device_separator);
            }

            brightness_slider = new BrightnessSlider ();
            brightness_slider.brightness_new_value.connect ((val) => { brightness_new_value (val); });
            brightness_slider.brightness_change.connect ((val) => { brightness_change (val); });

            add (brightness_slider);
        }

        show_percent_switch = new Wingpanel.Widgets.Switch (_("Show Percentage"), sm.show_percentage);

        var show_settings_button = new Gtk.ModelButton ();
        show_settings_button.text = _("Power Settings…");

        if (is_in_session) {
            app_list = new AppList ();
            pack_start (app_list); /* The app-list contains an own separator that is displayed if necessary. */
        }

        if (is_in_session || dm.has_battery) {
            last_separator = new Wingpanel.Widgets.Separator ();
            pack_start (last_separator);
            if (is_in_session) {
                pack_end (show_settings_button);
            }
            if (dm.has_battery) {
                pack_end (show_percent_switch);
            }
        }

        dm.notify["has-battery"].connect((s, p) => {
            bool had_separator = last_separator != null;
            bool has_separator = is_in_session || dm.has_battery;

            if (has_separator != had_separator) {
                if (has_separator) {
                    pack_start (last_separator = new Wingpanel.Widgets.Separator ());
                    last_separator.show ();
                } else {
                    remove (last_separator);
                    last_separator = null;
                }
            }

            remove (show_percent_switch);
            if (dm.has_battery) {
                pack_end (show_percent_switch);
            }

            if (dm.backlight.present) {
                bool had_battery = device_separator != null;
                if (dm.has_battery != had_battery) {
                    if (dm.has_battery) {
                        device_separator = new Wingpanel.Widgets.Separator ();
                        pack_start (device_separator);
                        reorder_child (device_separator, 1);
                        device_separator.show ();
                    } else {
                        remove (device_separator);
                        device_separator = null;
                    }
                }
            }
        });

        sm.schema.bind ("show-percentage", show_percent_switch.get_switch (), "active", SettingsBindFlags.DEFAULT);

        show_settings_button.clicked.connect (show_settings);
    }

    public void slim_down () {
        if (is_in_session) {
            app_list.clear_list ();
        }
    }

    private void show_settings () {
        try {
            AppInfo.launch_default_for_uri ("settings://power", null);
        } catch (Error e) {
            warning ("Failed to open power settings: %s", e.message);
        }
        settings_shown ();
    }
}
