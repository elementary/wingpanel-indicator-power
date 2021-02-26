/*
 * Copyright 2011-2021 elementary, Inc. (https://elementary.io)
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

public class Power.Widgets.AppList : Gtk.ListBox {
    private Services.AppManager app_manager;

    construct {
        activate_on_single_click = true;

        app_manager = Services.AppManager.get_default ();

        Services.ProcessMonitor.Monitor.get_default ().updated.connect (() => {
            /* Don't block the ui while updating the data */
            Idle.add (() => {
                clear_list ();
                update_list ();

                return false;
            });
        });

        unowned Gtk.Popover popover = null;

        row_activated.connect ((row) => {
            try {
                ((AppRow) row).app_info.launch (null, null);
                if (popover == null) {
                    popover = (Gtk.Popover) get_ancestor (typeof (Gtk.Popover));
                }
                popover.popdown ();
            } catch (Error e) {
                critical (e.message);
            }
        });
    }

    public void clear_list () {
        foreach (unowned var child in this.get_children ()) {
            remove (child);
        }
    }

    private void update_list () {
        var eaters = app_manager.get_top_power_eaters (12);

        if (eaters.size > 0) {
            var title_label = new Granite.HeaderLabel (_("Apps Using Lots of Power")) {
                margin_start = 6
            };

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
                hexpand = true,
                margin_top = 3,
                margin_bottom = 3
            };

            add (separator);
            add (title_label);
        }

        eaters.@foreach ((power_eater) => {
            var desktop_app_info = new DesktopAppInfo.from_filename (power_eater.application.get_desktop_file ());

            if (desktop_app_info == null) {
                return false;
            }

            var app_row = new AppRow (desktop_app_info);
            add (app_row);

            return true;
        });

        show_all ();
    }

    private class AppRow : Gtk.ListBoxRow {
        public DesktopAppInfo app_info { get; construct; }

        public AppRow (DesktopAppInfo app_info) {
            Object (app_info: app_info);
        }

        class construct {
            set_css_name (Gtk.STYLE_CLASS_MENUITEM);
        }

        construct {
            var app_icon_image = new Gtk.Image.from_icon_name ("application-default-icon", Gtk.IconSize.DND) {
                pixel_size = 32
            };

            var app_name_label = new Gtk.Label (_("Unknown App")) {
                halign = Gtk.Align.START
            };

            var app_icon = app_info.get_icon ();
            if (app_icon != null) {
                app_icon_image.gicon = app_icon;
            }

            var app_name = app_info.get_name ();
            if (app_name != null) {
                app_name_label.label = app_name;
            }

            var grid = new Gtk.Grid () {
                column_spacing = 9,
                margin_start = 3
            };
            grid.attach (app_icon_image, 0, 0);
            grid.attach (app_name_label, 1, 0);

            add (grid);
        }
    }
}
