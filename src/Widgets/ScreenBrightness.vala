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

    private const double BRIGHTNESS_STEP = 5;
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
            width_request = 175,
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

        brightness_slider.value_changed.connect ((value) => {
            brightness_slider.set_value (value.get_value ());
            dm.brightness = (int) value.get_value ();
        });


        dm.brightness_changed.connect ((brightness) => {
            brightness_slider.set_value ((double)brightness);
        });
    }

    private bool on_scroll_event (Gdk.EventScroll e) {
        double change = 0.0;
        if (handle_scroll_event (e, out change)) {
            dm.change_brightness ((int)(change * BRIGHTNESS_STEP));
            return true;
        }
        return false;
    }

    /* Handles both SMOOTH and non-SMOOTH events.
     * * accumulates very small changes until they become significant.
     * * ignores rapid changes in direction.
     * * responds to both horizontal and vertical scrolling.
     * In the case of diagonal scrolling, it ignores the event unless movement in one direction
     * is more than twice the movement in the other direction.
     */
    private double total_y_delta= 0;
    private double total_x_delta= 0;
    private bool handle_scroll_event (Gdk.EventScroll e, out double change) {
        change = 0.0;
        bool natural_scroll;
        var event_source = e.get_source_device ().input_source;
        if (event_source == Gdk.InputSource.MOUSE) {
            natural_scroll = natural_scroll_mouse;
        } else if (event_source == Gdk.InputSource.TOUCHPAD) {
            natural_scroll = natural_scroll_touchpad;
        } else {
            natural_scroll = true;
        }

        switch (e.direction) {
            case Gdk.ScrollDirection.SMOOTH:
                var abs_x = double.max (e.delta_x.abs (), 0.0001);
                var abs_y = double.max (e.delta_y.abs (), 0.0001);

                if (abs_y / abs_x > 2.0) {
                    total_y_delta += e.delta_y;
                } else if (abs_x / abs_y > 2.0) {
                    total_x_delta += e.delta_x;
                }
                break;
            case Gdk.ScrollDirection.UP:
                total_y_delta = -1.0;
                break;
            case Gdk.ScrollDirection.DOWN:
                total_y_delta = 1.0;
                break;
            case Gdk.ScrollDirection.LEFT:
                total_x_delta = -1.0;
                break;
            case Gdk.ScrollDirection.RIGHT:
                total_x_delta = 1.0;
                break;
            default:
                break;
        }

        if (total_y_delta.abs () > 0.5) {
            change = natural_scroll ? total_y_delta : -total_y_delta;
        } else if (total_x_delta.abs () > 0.5) {
            change = natural_scroll ? -total_x_delta : total_x_delta;
        }

        if (change.abs () > 0.0) {
            total_y_delta = 0.0;
            total_x_delta = 0.0;
            return true;
        }

        return false;
    }
}
