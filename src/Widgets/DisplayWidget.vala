/*
 * Copyright (c) 2011-2016 elementary LLC. (https://launchpad.net/wingpanel)
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
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class Power.Widgets.DisplayWidget : Gtk.Box {
    private Gtk.Image image;
    private Gtk.Revealer percent_revealer;
    private Gtk.Label percent_label;

    public DisplayWidget () {
        Object (orientation: Gtk.Orientation.HORIZONTAL);
    }

    construct {
        image = new Gtk.Image ();
        image.icon_name = "content-loading-symbolic";

        this.pack_start (image);

        percent_revealer = new Gtk.Revealer ();
        percent_revealer.reveal_child = Services.SettingsManager.get_default ().show_percentage;
        percent_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;

        percent_label = new Gtk.Label ("");
        percent_label.margin_start = 6;

        percent_revealer.add (percent_label);

        this.pack_start (percent_revealer);

        Services.SettingsManager.get_default ().notify["show-percentage"].connect (() => {
            percent_revealer.set_reveal_child (Services.SettingsManager.get_default ().show_percentage);
        });
    }

    public void set_icon_name (string icon_name) {
        image.icon_name = icon_name;
    }

    public void set_percent (int percentage) {
        percent_label.set_label ("%i%%".printf (percentage));
    }
}
