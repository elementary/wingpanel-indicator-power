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

public class Power.Widgets.AppList : Gtk.Grid {
    private Services.AppManager app_manager;

    public AppList () {
        Object (orientation: Gtk.Orientation.VERTICAL);
    }

    construct {
        app_manager = Services.AppManager.get_default ();

        Services.ProcessMonitor.Monitor.get_default ().updated.connect (() => {
            /* Don't block the ui while updating the data */
            Idle.add (() => {
                update_list ();

                return false;
            });
        });
    }

    public void clear_list () {
        foreach (var child in this.get_children ()) {
            this.remove (child);
        }
    }

    private void update_list () {
        clear_list ();

        var eaters = app_manager.get_top_power_eaters (12);

        if (eaters.size > 0) {
            var title_label = new Gtk.Label (_("Apps Using Lots of Power"));
            title_label.get_style_context ().add_class ("h4");
            title_label.halign = Gtk.Align.START;
            title_label.margin_start = 12;
            title_label.margin_end = 12;
            title_label.margin_bottom = 6;

            var separator = new Wingpanel.Widgets.Separator ();
            separator.hexpand = true;

            this.add (separator);
            this.add (title_label);
        }

        eaters.@foreach ((power_eater) => {
            var desktop_app_info = new DesktopAppInfo.from_filename (power_eater.application.get_desktop_file ());

            if (desktop_app_info == null) {
                return false;
            }

            var app_icon = desktop_app_info.get_icon ();
            var app_name = desktop_app_info.get_name ();

            if (app_icon == null || app_name == null) {
                return false;
            }

            var app_row = new AppRow (app_icon, app_name);
            add (app_row);

            return true;
        });

            show_all ();
    }

    private class AppRow : Gtk.Grid {
        public AppRow (GLib.Icon app_icon, string app_name) {
            var app_icon_image = new Gtk.Image.from_gicon (app_icon, Gtk.IconSize.LARGE_TOOLBAR);
            app_icon_image.pixel_size = 24;

            var app_name_label = new Gtk.Label (app_name);
            app_name_label.halign = Gtk.Align.START;

            column_spacing = 18;
            margin_start = 18;
            margin_end = 12;
            margin_bottom = 12;
            attach (app_icon_image, 0, 0, 1, 1);
            attach (app_name_label, 1, 0, 1, 1);
        }
    }
}
