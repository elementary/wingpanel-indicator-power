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
        eaters.@foreach ((power_eater) => {
            var power_eater_desktop_file = power_eater.application.get_desktop_file ();
            if (power_eater_desktop_file == null) {
                return false;
            }

            var desktop_app_info = new DesktopAppInfo.from_filename (power_eater_desktop_file);
            var app_row = new AppRow (desktop_app_info);
            add (app_row);

            return true;
        });

        // Add the header label if we acually have row(s)
        if (get_row_at_index (0) != null) {
            var title_label = new Granite.HeaderLabel (_("Apps Using Lots of Power"));
            set_header_func ((row, before) => {
                if (row.get_index () == 0) {
                    row.set_header (title_label);
                }
            });
        }

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

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 9) {
                margin_start = 3
            };
            box.add (app_icon_image);
            box.add (app_name_label);

            add (box);
        }
    }
}
