/*
 * Copyright 2011-2020 elementary, Inc. (https://elementary.io)
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

public class Power.Widgets.DisplayWidget : Gtk.Box {
    public string icon_name {
        set {
            image.icon_name = value;
        }
    }

    public bool allow_percent { get; set; default = false; }
    public int percentage {
        set {
            /// Translators: This represents battery charge percentage with `%i` representing the number and `%%` representing the percent symbol
            percent_label.label = _("%i%%").printf (value);
        }
    }

    private Gtk.Revealer image_revealer;
    private Gtk.Image image;
    private Gtk.Revealer percent_revealer;
    private Gtk.Label percent_label;

    private GLib.Settings settings;

    construct {
        valign = Gtk.Align.CENTER;

        image = new Gtk.Image () {
            icon_name = "content-loading-symbolic",
            pixel_size = 24
        };

        image_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
            child = image
        };

        percent_label = new Gtk.Label (null);

        percent_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
            child = percent_label
        };

        add (image_revealer);
        add (percent_revealer);

        settings = new GLib.Settings ("io.elementary.desktop.wingpanel.power");

        sync_appearance ();
        settings.changed["appearance"].connect (sync_appearance);
    }

    private void sync_appearance () {
        var appearance_value = settings.get_enum ("appearance");

        if (appearance_value == 0) {
            image_revealer.reveal_child = true;
            percent_revealer.reveal_child = false;
        } else if (appearance_value == 1) {
            image_revealer.reveal_child = true;
            percent_revealer.reveal_child = true;
        } else {
            image_revealer.reveal_child = false;
            percent_revealer.reveal_child = true;
        }
    }
}
