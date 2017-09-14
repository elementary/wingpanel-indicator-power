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

public class Power.Widgets.ScreenBrightness : Gtk.Grid {
    private const string DBUS_PATH = "/org/gnome/SettingsDaemon/Power";
    private const string DBUS_NAME = "org.gnome.SettingsDaemon";

    private Gtk.Image image;
    private Gtk.Scale scale;
    private Services.DBusInterfaces.PowerSettings iscreen;

    public int val {
        get { return (int) scale.get_value (); }
        set { scale.set_value (value); }
    }

    const int STEP = 10;

    construct {
        orientation = Gtk.Orientation.HORIZONTAL;
        column_spacing = 6;
        init_bus.begin ();

        var image_box = new Gtk.EventBox ();
        image = new Gtk.Image.from_icon_name ("brightness-display-symbolic", Gtk.IconSize.DIALOG);
        image_box.halign = Gtk.Align.START;
        image_box.add (image);
        image_box.scroll_event.connect (on_scroll);
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

    public void update_slider () {
      #if OLD_GSD
        scale.val = iscreen.get_percentage ();
      #else
        // When trying to use val property:
        // error: The name `val' does not exist in the context of `Gtk.Scale'
        scale.set_value (iscreen.brightness);
      #endif
    }

    private async void init_bus () {
        try {
            iscreen = Bus.get_proxy_sync (BusType.SESSION, DBUS_NAME, DBUS_PATH, DBusProxyFlags.GET_INVALIDATED_PROPERTIES);
        } catch (IOError e) {
            warning ("screen brightness error %s", e.message);
        }
    }

    private async void on_scale_value_changed () {
        try {
            #if OLD_GSD
                if (iscreen.get_percentage () != val) {
                    iscreen.set_percentage (val);
                }
          #else
                if (iscreen.brightness != val) {
                    iscreen.brightness = val;
                }
          #endif
        } catch (IOError e) {
            warning ("screen brightness error %s", e.message);
        }
    }

    public bool on_scroll (Gdk.EventScroll e) {
            if (e.direction == Gdk.ScrollDirection.UP) {
                val += STEP;
            } else if (e.direction == Gdk.ScrollDirection.DOWN) {
                val -= STEP;
            }
            return Gdk.EVENT_STOP;
        }

}
