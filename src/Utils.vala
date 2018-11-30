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

namespace Power.Utils {
    public bool type_is_battery (uint32 device_type) {
        return device_type != DEVICE_TYPE_UNKNOWN && device_type != DEVICE_TYPE_LINE_POWER;
    }

    public string get_symbolic_icon_name_for_battery (Services.Device battery) {
        return get_icon_name_for_battery (battery) + "-symbolic";
    }

    public string get_icon_name_for_battery (Services.Device battery) {
        if (battery.percentage == 100 && is_charging (battery.state) == true) {
            return "battery-full-charged";
        } else {
            return get_battery_icon (battery.percentage, battery.time_to_empty) +
                (is_charging (battery.state) ? "-charging" : "");
        }
    }

    private unowned string get_battery_icon (double percentage, int64 remaining_time) {
        if (percentage <= 0) {
            return "battery-good";
        }

        if (percentage < 10 && (remaining_time == 0 || remaining_time < 30 * 60)) {
            return "battery-empty";
        }

        if (percentage < 30) {
            return "battery-caution";
        }

        if (percentage < 60) {
            return "battery-low";
        }

        if (percentage < 80) {
            return "battery-good";
        }

        return "battery-full";
    }

    public bool is_charging (uint32 state) {
        return state == DEVICE_STATE_FULLY_CHARGED || state == DEVICE_STATE_CHARGING;
    }

    // TODO: Replace this and above with P_ when https://bugzilla.gnome.org/show_bug.cgi?id=758000 is fixed.
    private void translations () {
        ngettext ("%lld day until full", "%lld days until full", 0);
        ngettext ("%lld hour until full", "%lld hours until full", 0);
        ngettext ("%lld minute until full", "%lld minutes until full", 0);
        ngettext ("%lld second until full", "%lld seconds until full", 0);
        ngettext ("%lld day until empty", "%lld days until empty", 0);
        ngettext ("%lld hour until empty", "%lld hours until empty", 0);
        ngettext ("%lld minute until empty", "%lld minutes until empty", 0);
        ngettext ("%lld second until empty", "%lld seconds until empty", 0);
    }
}
