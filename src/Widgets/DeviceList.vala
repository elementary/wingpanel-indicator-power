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

public class Power.Widgets.DeviceList : Gtk.Box {
    public Gee.HashMap<string, Power.Widgets.DeviceRow> entries;

    construct {
        orientation = Gtk.Orientation.VERTICAL;

        entries = new Gee.HashMap<string, Power.Widgets.DeviceRow> ();

        var dm = Services.DeviceManager.get_default ();
        dm.battery_registered.connect (add_battery);
        dm.battery_deregistered.connect (remove_battery);

        // load all battery information.
        dm.read_devices ();
    }

    private void add_battery (string device_path, Services.Device battery) {
        var device_row = new Power.Widgets.DeviceRow (battery);

        entries.@set (device_path, device_row);

        if (battery.device_type == Power.Services.Device.Type.BATTERY) {
            this.pack_start (device_row);
        } else {
            this.pack_end (device_row);
        }

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
