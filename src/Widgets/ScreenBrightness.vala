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

public class Power.Widgets.ScreenBrightness : Granite.Bin {
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

        var image = new Gtk.Image.from_icon_name ("brightness-display-symbolic") {
            pixel_size = 48
        };

        brightness_slider = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 100, 10) {
            margin_end = 6,
            hexpand = true,
            draw_value = false,
            width_request = 175
        };

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            hexpand = true,
            margin_start = 6,
            margin_end = 12
        };

        box.append (image);
        box.append (brightness_slider);

        var show_brightness_slider = new Gtk.Revealer () {
            child = box
        };

        child = show_brightness_slider;

        if (dm.brightness != -1) {
            brightness_slider.set_value (dm.brightness);
            show_brightness_slider.reveal_child = true;
        }

        var scroll_controller = new Gtk.EventControllerScroll (BOTH_AXES);
        scroll_controller.scroll.connect (on_scroll);
        add_controller (scroll_controller);

        brightness_slider.value_changed.connect ((value) => {
            brightness_slider.set_value (value.get_value ());
            dm.brightness = (int) value.get_value ();
        });

        dm.brightness_changed.connect ((brightness) => {
            if (brightness != -1) {
                brightness_slider.set_value ((double) brightness);
                show_brightness_slider.reveal_child = true;
            } else {
                show_brightness_slider.reveal_child = false;
            }
        });
    }

    private bool on_scroll (Gtk.EventControllerScroll controller, double dx, double dy) {
        return Utils.handle_scroll_event ((Gdk.ScrollEvent) controller.get_current_event (), natural_scroll_mouse, natural_scroll_touchpad);
    }
}
