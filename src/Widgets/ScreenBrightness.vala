/*
 * Copyright (c) 2011-2021 elementary LLC. (https://elementary.io)
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

public class Power.Widgets.ScreenBrightness : Gtk.Grid {
    private Gtk.Scale brightness_slider;
    private Power.Services.DeviceManager dm;

    construct {
        dm = Power.Services.DeviceManager.get_default ();
        column_spacing = 6;

        var image = new Gtk.Image.from_icon_name ("brightness-display-symbolic", Gtk.IconSize.DIALOG);
        image.margin_start = 6;

        brightness_slider = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 100, 10) {
            draw_value = false,
            margin_end = 12,
            hexpand = true,
            width_request = 175
        };

        brightness_slider.adjustment.page_increment = 10;

        brightness_slider.value_changed.connect ((value) => {
            brightness_slider.set_value (value.get_value ());
            dm.brightness = (int) value.get_value ();
        });

        dm.brightness_changed.connect ((brightness) => {
            brightness_slider.set_value ((double)brightness);
        });

        brightness_slider.set_value (dm.brightness);

        attach (image, 0, 0);
        attach (brightness_slider, 1, 0);
    }
}
