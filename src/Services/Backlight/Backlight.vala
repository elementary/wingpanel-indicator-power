/*
 * Copyright (c) 2011-2015 elementary LLC. (https://elementary.io)
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

public class Power.Services.Backlight : GLib.Object {

    private const string BACKLIGHT_NAME = "backlight";

    public bool present { get; construct set; }

    construct {
        present = get_backlight_present ();
        debug ("backlight present: %s", present.to_string ());
    }

    private static bool get_backlight_present () {
        print ("VJR BACKLIGHT CHECK\n");
        var context = new UDev.Context ();
        var e = context.create_enumerate ();
        e.add_match_subsystem (BACKLIGHT_NAME);
        e.scan_devices ();

        for (unowned UDev.List d = e.entries; d != null; d = d.next) {
            var path = d.name;
            var dev = context.open_syspath (path);

            if (dev != null) {
                return true;
            }
        }

        DDCUtil.Status status;

        DDCUtil.DisplayInfoList dlist;

        print ("VJR BACKLIGHT CHECK2\n");

        status = DDCUtil.get_display_info_list2 (true, out dlist);

        print ("VJR BACKLIGHT CHECK3\n");

        if (status == DDCUtil.Status.OK && dlist.info.length > 0) {
            print ("VJR BACKLIGHT CHECK4\n");
            return true;
        }

        print ("VJR BACKLIGHT CHECK5 %i\n", status);
        return false;
    }
}
