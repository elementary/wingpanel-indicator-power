/*
 * Copyright (c) 2011-2015 Wingpanel Developers (http://launchpad.net/wingpanel)
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

public class Power.Widgets.DeviceList : Gtk.Box {
    public Gee.HashMap<string, Gtk.Grid> entries;

    public DeviceList () {
        Object (orientation: Gtk.Orientation.VERTICAL);

        entries = new Gee.HashMap<string, Gtk.Grid> ();

        connect_signals ();
    }

    private void connect_signals () {
        Services.DeviceManager.get_default ().battery_registered.connect (add_battery);
        Services.DeviceManager.get_default ().battery_deregistered.connect (remove_battery);
    }

    private void update_icons (Services.Device battery, Gtk.Image device_image, Gtk.Image battery_image) {
        if (Utils.type_has_device_icon (battery.device_type)) {
            device_image.set_from_icon_name (Utils.get_icon_name_for_device (battery), Gtk.IconSize.DIALOG);
            battery_image.set_from_icon_name (Utils.get_icon_name_for_battery (battery), Gtk.IconSize.DND);
        } else {
            device_image.set_from_icon_name (Utils.get_icon_name_for_battery (battery), Gtk.IconSize.DIALOG);
            battery_image.clear ();
        }
    }

    private void add_battery (string device_path, Services.Device battery) {
        var grid = new Gtk.Grid ();
        grid.column_spacing = 6;
        grid.row_spacing = 6;
        grid.margin = 6;

        var device_image = new Gtk.Image ();
        device_image.margin_end = 3;

        var battery_image = new Gtk.Image ();
        battery_image.halign = Gtk.Align.END;
        battery_image.valign = Gtk.Align.END;

        update_icons (battery, device_image, battery_image);

        var overlay = new Gtk.Overlay ();
        overlay.add (device_image);
        overlay.add_overlay (battery_image);

        grid.attach (overlay, 0, 0, 1, 2);

        var title_label = new Gtk.Label (Utils.get_title_for_battery (battery));
        title_label.use_markup = true;
        title_label.halign = Gtk.Align.START;
        title_label.valign = Gtk.Align.END;
        title_label.hexpand = true;
        title_label.vexpand = true;
        title_label.margin_end = 6;

        grid.attach (title_label, 1, 0, 1, 1);

        var info_label = new Gtk.Label (Utils.get_info_for_battery (battery));
        info_label.halign = Gtk.Align.START;
        info_label.valign = Gtk.Align.START;
        info_label.hexpand = true;
        info_label.vexpand = true;
        info_label.margin_end = 6;

        grid.attach (info_label, 1, 1, 1, 1);

        entries.@set (device_path, grid);

        if (battery.device_type == DEVICE_TYPE_BATTERY) {
            this.pack_start (grid);
        } else {
            this.pack_end (grid);
        }

        battery.properties_updated.connect (() => {
            update_icons (battery, device_image, battery_image);
            title_label.set_markup (Utils.get_title_for_battery (battery));
            info_label.set_label (Utils.get_info_for_battery (battery));
        });

        this.show_all ();
    }

    private void remove_battery (string device_path) {
        if (!entries.has_key (device_path)) {
            return;
        }

        this.remove (entries.@get (device_path));

        entries.unset (device_path);
    }
}
