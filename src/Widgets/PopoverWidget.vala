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
    private AppList app_list;
    private ScreenBrightness screen_brightness;

    private Wingpanel.Widgets.Switch show_percent_switch;
    private Wingpanel.Widgets.Button show_settings_button;

    public signal void settings_shown ();

    public PopoverWidget (bool is_in_session) {
        Object (is_in_session: is_in_session, orientation: Gtk.Orientation.VERTICAL);
    }

    construct {
        device_list = new DeviceList ();
        var dm = Services.DeviceManager.get_default ();

        if (dm.has_battery) {
            debug ("show list of batteries");
            pack_start (device_list);
            pack_start (new Wingpanel.Widgets.Separator ());
        }

        if (dm.backlight.present) {
            debug ("show brightness slider");
            screen_brightness = new ScreenBrightness ();
            pack_start (screen_brightness);
        }

        show_percent_switch = new Wingpanel.Widgets.Switch (_("Show Percentage"), Services.SettingsManager.get_default ().show_percentage);
        show_settings_button = new Wingpanel.Widgets.Button (_("Power Settings…"));

        this.pack_start (device_list);

        if (is_in_session) {
            app_list = new AppList ();
            this.pack_start (app_list); /* The app-list contains an own separator that is displayed if necessary. */
            this.pack_start (new Wingpanel.Widgets.Separator ());

            if (dm.has_battery) {
                this.pack_start (show_percent_switch);
            }

            this.pack_start (show_settings_button);
        } else if (dm.has_battery) {
            this.pack_start (new Wingpanel.Widgets.Separator ());
            this.pack_start (show_percent_switch);
        }

        Services.SettingsManager.get_default ().schema.bind ("show-percentage", show_percent_switch.get_switch (), "active", SettingsBindFlags.DEFAULT);

        show_settings_button.clicked.connect (show_settings);
    }

    public void slim_down () {
        if (is_in_session) {
            app_list.clear_list ();
        }
    }

    public void update_brightness_slider () {
        screen_brightness.update_slider ();
    }

    private void show_settings () {
        var list = new List<string> ();
        list.append ("power");
        try {
            var appinfo = AppInfo.create_from_commandline ("switchboard", null, AppInfoCreateFlags.SUPPORTS_URIS);
            appinfo.launch_uris (list, null);
        } catch (Error e) {
            warning ("%s\n", e.message);
        }

        settings_shown ();
    }
}
