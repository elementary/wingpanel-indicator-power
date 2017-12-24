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

public class Power.Widgets.BrightnessSlider : Gtk.Grid {

    private Gtk.Image image;
    private Gtk.Scale scale;

    public int val {
        get { return (int) scale.get_value (); }
        set { scale.set_value (value); }
    }

    // The integer returned is a relative change in the brightness value (ie.
    // a +10 increase or a -10 decrease)
    public signal void brightness_change (int change);

    // The integer returned is absolute
    public signal void brightness_new_value (int new_value);

    construct {
        orientation = Gtk.Orientation.HORIZONTAL;
        column_spacing = 6;

        var image_box = new Gtk.EventBox ();
        image = new Gtk.Image.from_icon_name ("brightness-display-symbolic", Gtk.IconSize.DIALOG);
        image_box.halign = Gtk.Align.START;
        image_box.add (image);
        image_box.scroll_event.connect ((e) => {
            brightness_change (Power.Utils.handle_scroll(e));
        });
        attach (image_box, 0, 0, 1, 1);

        scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 100, Power.Utils.STEP);
        scale.adjustment.page_increment = Power.Utils.STEP;
        scale.margin_end = 12;
        scale.hexpand = true;
        scale.draw_value = false;
        scale.width_request = 175;
        scale.value_changed.connect (() => {
            brightness_new_value(val);
        });
        attach (scale, 1, 0, 1, 1);
    }

}
