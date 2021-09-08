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

public class Power.Widgets.ScreenBrightness : Gtk.EventBox {
    private Gtk.Scale brightness_slider;
    private Power.Services.DeviceManager dm;

    public bool natural_scroll_touchpad { get; set; }
    public bool natural_scroll_mouse { get; set; }

    construct {
        dm = Power.Services.DeviceManager.get_default ();

        var mouse_settings = new GLib.Settings ("org.gnome.desktop.peripherals.mouse");
        mouse_settings.bind ("natural-scroll", this, "natural-scroll-mouse", SettingsBindFlags.DEFAULT);
        var touchpad_settings = new GLib.Settings ("org.gnome.desktop.peripherals.touchpad");
        touchpad_settings.bind ("natural-scroll", this, "natural-scroll-touchpad", SettingsBindFlags.DEFAULT);

        var image = new Gtk.Image.from_icon_name ("brightness-display-symbolic", Gtk.IconSize.DIALOG) {
            margin_start = 6
        };

        brightness_slider = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 100, 10) {
            margin_end = 12,
            hexpand = true,
            draw_value = false,
            width_request = 175
        };

        var grid = new Gtk.Grid () {
            column_spacing = 6,
            hexpand = true,
            margin_start = 6,
            margin_end = 12
        };

        grid.add (image);
        grid.add (brightness_slider);

        add (grid);

        brightness_slider.set_value (dm.brightness);

        brightness_slider.scroll_event.connect ((e) => {
          /* Re-emit the signal on the eventbox instead of using native handler */
          on_scroll_event (e);
          return true;
        });

        dm.brightness_changed.connect ((brightness) => {
            brightness_slider.value_changed.disconnect (on_scale_value_changed);
            if (brightness > 0) {
                brightness_slider.set_value ((double)brightness);
            }
            brightness_slider.value_changed.connect (on_scale_value_changed);
        });


        dm.brightness_changed.connect ((brightness) => {
            brightness_slider.set_value ((double)brightness);
        });
    }

    private bool on_scroll_event (Gdk.EventScroll e) {
        return Utils.handle_scroll_event (e, natural_scroll_mouse, natural_scroll_touchpad);
    }
}
