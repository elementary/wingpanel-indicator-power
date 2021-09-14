/*
 * Copyright (c) 2021 Justin Haygood (jhaygood86@gmail.com)
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

 public class Power.Widgets.PowerProfileList : Gtk.ListBox {

    Power.Services.PowerProfileManager ppm;

    construct {
        ppm = Power.Services.PowerProfileManager.get_default ();

        ppm.profile_added.connect (add_profile);

        foreach (var profile in ppm.profiles.values) {
            add_profile (profile);
        }

        set_active ();
    }

    private void add_profile (Power.Services.PowerProfile profile) {
        PowerProfileRow? previous_row = null;

        foreach (weak Gtk.Widget w in get_children ()) {
            var existing_row = w as PowerProfileRow;

            if (existing_row != null) {
                previous_row = existing_row;
            }
        }

        var profile_row = new PowerProfileRow (profile, previous_row);

        if (ppm.active_profile == profile) {
            profile_row.active = true;
        }

        profile_row.toggled.connect (() => {
            update_active ();
        });

        ppm.profile_changed.connect ((profile) => {
            set_active ();
        });

        add (profile_row);
        show_all ();
    }

    private void set_active () {
        var active_profile = ppm.active_profile;

        foreach (weak Gtk.Widget w in get_children ()) {
            var row = w as PowerProfileRow;

            if (row != null && row.profile == active_profile) {
                row.active = true;
            }
        }
    }

    private void update_active () {
        foreach (weak Gtk.Widget w in get_children ()) {
            var row = w as PowerProfileRow;

            if (row != null && row.active) {
                ppm.active_profile = row.profile;
            }
        }
    }
 }
