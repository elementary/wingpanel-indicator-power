/*
 * Copyright 2011-2018 elementary, Inc. (https://elementary.io)
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

public class Power.Widgets.DeviceRow : Gtk.ListBoxRow {
    public Services.Device battery { get; construct; }

    private Gtk.Image battery_image;
    private Gtk.Image device_image;

    public DeviceRow (Services.Device battery) {
        Object (battery: battery);
    }

    construct {
        device_image = new Gtk.Image.from_icon_name ("battery", Gtk.IconSize.DIALOG) {
          pixel_size = 48,
          margin_end = 3
        };

        battery_image = new Gtk.Image () {
          pixel_size = 32,
          halign = Gtk.Align.END,
          valign = Gtk.Align.END
        };

        var overlay = new Gtk.Overlay ();
        overlay.add (device_image);
        overlay.add_overlay (battery_image);

        var title_label = new Gtk.Label (get_title ()) {
          use_markup = true,
          halign = Gtk.Align.START,
          valign = Gtk.Align.END
        };


        var info_label = new Gtk.Label (battery.get_info ()) {
          halign = Gtk.Align.START,
          valign = Gtk.Align.START
        };

        var grid = new Gtk.Grid () {
          column_spacing = 3,
          margin = 3,
          margin_start = 6,
          margin_end = 12
        };
        grid.attach (overlay, 0, 0, 1, 2);
        grid.attach (title_label, 1, 0);
        grid.attach (info_label, 1, 1);


        add (grid);
        update_icons ();

        battery.properties_updated.connect (() => {
            update_icons ();
            title_label.set_markup (get_title ());
            info_label.label = battery.get_info ();
        });
    }

    private void update_icons () {
        unowned string? icon_name = battery.device_type.get_icon_name ();
        if (icon_name != null) {
            device_image.icon_name = icon_name;
            battery_image.icon_name = battery.get_icon_name_for_battery ();
        } else {
            battery_image.clear ();
            device_image.icon_name = battery.get_icon_name_for_battery ();
        }
    }

    private string get_title () {
        string? type_string = battery.device_type.get_name ();

        switch (battery.device_type) {
            case Power.Services.Device.Type.COMPUTER:
            case Power.Services.Device.Type.PHONE:
            case Power.Services.Device.Type.TABLET:
                if (battery.model != "") {
                    type_string = battery.model;
                }
                break;
        }

        if (type_string == null) {
            type_string = "%s %s".printf (battery.vendor, _("Device"));
        }

        return "<b>%s</b>".printf (type_string);
    }
}
