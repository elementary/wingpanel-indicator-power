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
    private const int STEP = 10;

    private Gtk.Image image;
    private Gtk.Scale scale;

    public int val {
        get { return (int) scale.get_value (); }
        set { scale.set_value (value); }
    }

    public signal void update_brightness (int val); 

    construct {
        orientation = Gtk.Orientation.HORIZONTAL;
        column_spacing = 6;

        var image_box = new Gtk.EventBox ();
        image = new Gtk.Image.from_icon_name ("brightness-display-symbolic", Gtk.IconSize.DIALOG);
        image_box.halign = Gtk.Align.START;
        image_box.add (image);
        image_box.scroll_event.connect ((e) => {
            val += Power.Utils.handle_scroll(e);
        });
        attach (image_box, 0, 0, 1, 1);

        scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 100, STEP);
        scale.adjustment.page_increment = STEP;
        scale.margin_end = 12;
        scale.hexpand = true;
        scale.draw_value = false;
        scale.width_request = 175;
        scale.value_changed.connect (on_scale_value_changed);
        attach (scale, 1, 0, 1, 1);
    }

    private async void on_scale_value_changed () {
        update_brightness (val);
    }

}
