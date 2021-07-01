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

public class Power.Widgets.DeviceList : Gtk.ListBox {
    public Gee.HashMap<string, Power.Widgets.DeviceRow> entries;

    construct {
        selection_mode = Gtk.SelectionMode.NONE;
        set_sort_func (sort_function);

        entries = new Gee.HashMap<string, Power.Widgets.DeviceRow> ();

        var dm = Services.DeviceManager.get_default ();
        dm.battery_registered.connect (add_battery);
        dm.battery_deregistered.connect (remove_battery);

        // load all battery information.
        dm.read_devices ();

        this.row_activated.connect ((value) => {
          try {
              AppInfo statistics_app = AppInfo.create_from_commandline ("gnome-power-statistics", "", AppInfoCreateFlags.NONE);
              statistics_app.launch (null, null);
          } catch (Error e) {
              print ("Error opening Gnome Power Statistics: %s\n", e.message);
          }
        });
    }

    private void add_battery (string device_path, Services.Device battery) {
        var device_row = new Power.Widgets.DeviceRow (battery);

        entries.@set (device_path, device_row);

        add (device_row);
        show_all ();
        invalidate_sort ();
    }

    private void remove_battery (string device_path) {
        if (!entries.has_key (device_path)) {
            return;
        }

        entries.@get (device_path).destroy ();

        entries.unset (device_path);
    }

    [CCode (instance_pos = -1)]
    private int sort_function (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        var battery1 = ((Power.Widgets.DeviceRow) row1).battery;
        var battery2 = ((Power.Widgets.DeviceRow) row2).battery;

        if (battery1.device_type == battery2.device_type) {
            return 0;
        } else if (battery1.device_type == Power.Services.Device.Type.BATTERY) {
            return -1;
        } else {
            return 1;
        }
    }
}
