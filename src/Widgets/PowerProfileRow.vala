/*
 * Copyright 2021 Justin Haygood (jhaygood86@gmail.com)
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

public class Power.Widgets.PowerProfileRow : Gtk.ListBoxRow {
    public Services.PowerProfile profile { get; construct; }
    
    private Gtk.RadioButton radio_button;
    private Gtk.Label label;
    
    public signal void toggled ();

    public PowerProfileRow (Services.PowerProfile profile, PowerProfileRow? previous = null) {
        Object(profile: profile);
        
        var profile_name = profile.get_name ();
    
        label = new Gtk.Label (null) {
            ellipsize = Pango.EllipsizeMode.MIDDLE,
            label = profile_name
        };
        
        if (previous == null) {
            radio_button = new Gtk.RadioButton (null) {
                hexpand = true
            };
        } else {
            radio_button = new Gtk.RadioButton ( previous.get_group ()) {
                hexpand = true
            };
        }

        radio_button.add (label);
        
        add (radio_button);
        
        radio_button.toggled.connect (() => toggled ());;
    }
    
    class construct {
        set_css_name (Gtk.STYLE_CLASS_MENUITEM);
    }
    
    public bool active {
        get { return radio_button.active; }
        set { radio_button.active = true; }
    }
    
    private unowned SList get_group () {
        return radio_button.get_group ();
    }
}
