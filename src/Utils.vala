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

namespace Power.Utils {
    public bool type_is_battery (uint32 device_type) {
        return device_type != DEVICE_TYPE_UNKNOWN && device_type != DEVICE_TYPE_LINE_POWER;
    }

    public bool type_has_device_icon (uint32 device_type) {
        return device_type == DEVICE_TYPE_PHONE || device_type == DEVICE_TYPE_MOUSE || device_type == DEVICE_TYPE_KEYBOARD;
    }

    public string get_symbolic_icon_name_for_battery (Services.Device battery) {
        return get_icon_name_for_battery (battery) + "-symbolic";
    }

    public string get_symbolic_icon_name_for_backlight () {
        return "display-brightness-symbolic";
    }

    public string get_icon_name_for_battery (Services.Device battery) {
        if (battery.percentage == 100 && is_charging (battery.state) == true) {
            return "battery-full-charged";
        } else {
            return get_battery_icon (battery.percentage, battery.time_to_empty) +
                (is_charging (battery.state) ? "-charging" : "");
        }
    }

    public string? get_icon_name_for_device (Services.Device device) {
        switch (device.device_type) {
            case DEVICE_TYPE_PHONE: return "phone";
            case DEVICE_TYPE_MOUSE: return "input-mouse";
            case DEVICE_TYPE_KEYBOARD: return "input-keyboard";
            default: return get_icon_name_for_battery (device);
        }
    }

    private string get_battery_icon (double percentage, int64 remaining_time) {
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

    private bool is_charging (uint32 state) {
        return state == DEVICE_STATE_FULLY_CHARGED || state == DEVICE_STATE_CHARGING;
    }

    public string get_title_for_battery (Services.Device battery) {
        var title = "";

        switch (battery.device_type) {
            /* TODO: Do we want to differentiate between batteries and rechargeable batteries? (See German: Batterie <-> Akku) */
            case DEVICE_TYPE_BATTERY: title = _("Battery"); break;
            case DEVICE_TYPE_UPS: title = _("UPS"); break;
            case DEVICE_TYPE_MONITOR: title = _("Display"); break;
            case DEVICE_TYPE_MOUSE: title = _("Mouse"); break;
            case DEVICE_TYPE_KEYBOARD: title = _("Keyboard"); break;
            case DEVICE_TYPE_PDA: title = _("PDA"); break;
            case DEVICE_TYPE_PHONE: title = _("Phone"); break;
            default: title = battery.vendor + " " + _("Device"); break;
        }

        if (battery.device_type == DEVICE_TYPE_PHONE && battery.model != "") {
            title = battery.model;
        }

        return "<b>%s</b>".printf (title);
    }

    public string get_info_for_battery (Services.Device battery) {
        var percent = (int)Math.round (battery.percentage);
        var charging = is_charging (battery.state);

        if (percent <= 0) {
            return _("Calculating…");
        }

        var info = "";

        if (charging) {
            info += _("%i%% charged").printf (percent);

            var seconds = battery.time_to_full;

            if (seconds > 0) {
                info += " - ";
                if (seconds >= 86400) {
                    var days = seconds/86400;
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld day until full", "%lld days until full", (ulong) days).printf (days);
                } else if (seconds >= 3600) {
                    var hours = seconds/3600;
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld hour until full", "%lld hours until full", (ulong) hours).printf (hours);
                } else if (seconds >= 60) {
                    var minutes = seconds/60;
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld minute until full", "%lld minutes until full", (ulong) minutes).printf (minutes);
                } else {
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld second until full", "%lld seconds until full", (ulong) seconds).printf (seconds);
                }
            }
        } else {
            info += _("%i%% remaining").printf (percent);

            var seconds = battery.time_to_empty;

            if (seconds > 0) {
                info += " - ";
                if (seconds >= 86400) {
                    var days = seconds/86400;
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld day until empty", "%lld days until empty", (ulong) days).printf (days);
                } else if (seconds >= 3600) {
                    var hours = seconds/3600;
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld hour until empty", "%lld hours until empty", (ulong) hours).printf (hours);
                } else if (seconds >= 60) {
                    var minutes = seconds/60;
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld minute until empty", "%lld minutes until empty", (ulong) minutes).printf (minutes);
                } else {
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld second until empty", "%lld seconds until empty", (ulong) seconds).printf (seconds);
                }
            }
        }

        return info;
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
