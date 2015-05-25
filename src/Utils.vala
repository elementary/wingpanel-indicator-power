/*-
 * Copyright (c) 2015 Wingpanel Developers (http://launchpad.net/wingpanel)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Power.Utils {
	public bool type_is_battery (uint32 device_type) {
		return device_type != DEVICE_TYPE_UNKNOWN && device_type != DEVICE_TYPE_LINE_POWER;
	}

	public string get_symbolic_icon_name_for_battery (Services.Device battery) {
		return get_icon_name_for_battery (battery) + "-symbolic";
	}

	public string get_icon_name_for_battery (Services.Device battery) {
		switch (battery.device_type) {
			case DEVICE_TYPE_MOUSE: return get_mouse_icon (battery.percentage);
			case DEVICE_TYPE_PHONE: return get_phone_icon (battery.percentage);
			default: return get_battery_icon (battery.percentage) + (is_charging (battery.state) ? "-charging" : "");
		}
	}

	private string get_mouse_icon (double percentage) {
		if (percentage <= 0) return "input-mouse";
		if (percentage < 20) return "battery-mouse-000";
		if (percentage < 40) return "battery-mouse-020";
		if (percentage < 60) return "battery-mouse-040";
		if (percentage < 80) return "battery-mouse-080";
		return "battery-mouse-080";
	}

	private string get_phone_icon (double percentage) {
		if (percentage <= 0) return "phone";
		if (percentage < 20) return "battery-phone-000";
		if (percentage < 40) return "battery-phone-020";
		if (percentage < 60) return "battery-phone-040";
		if (percentage < 80) return "battery-phone-080";
		return "battery-phone-080";
	}

	private string get_battery_icon (double percentage) {
		if (percentage <= 0) return "battery-good";
		if (percentage < 20) return "battery-empty";
		if (percentage < 40) return "battery-caution";
		if (percentage < 60) return "battery-low";
		if (percentage < 80) return "battery-good";
		return "battery-full";
	}

	private bool is_charging (uint32 state) {
		return state == DEVICE_STATE_FULLY_CHARGED || state == DEVICE_STATE_CHARGING;
	}

	public string get_title_for_battery (Services.Device battery) {
		var title = "";

		if (battery.vendor != "" && battery.device_type != DEVICE_TYPE_BATTERY)
			title += "%s ".printf (battery.vendor);

		switch (battery.device_type) {
			// TODO: Do we want to differentiate between batteries and rechargeable batteries? (See German: Batterie <-> Akku)
			case DEVICE_TYPE_BATTERY: title += _("Battery"); break;
			case DEVICE_TYPE_UPS: title += _("UPS"); break;
			case DEVICE_TYPE_MONITOR: title += _("Monitor"); break;
			case DEVICE_TYPE_MOUSE: title += _("Mouse"); break;
			case DEVICE_TYPE_KEYBOARD: title += _("Keyboard"); break;
			case DEVICE_TYPE_PDA: title += _("PDA"); break;
			case DEVICE_TYPE_PHONE: title += _("Phone"); break;
			default: title += _("Device"); break;
		}

		return "<b>%s</b>".printf (title);
	}

	public string get_info_for_battery (Services.Device battery) {
		var percent = (int)Math.round (battery.percentage);
		var charging = is_charging (battery.state);

		if (percent <= 0)
			return _("Calculating...");

		var info = "";

		if (charging) {
			info += _("%i%% charged").printf (percent);

			var seconds = battery.time_to_full;

			if (seconds > 0) {
				info += " - ";
				info += _("%s until full").printf (format_seconds (seconds));
			}
		} else {
			info += _("%i%% remaining").printf (percent);

			var seconds = battery.time_to_empty;

			if (seconds > 0) {
				info += " - ";
				info += _("%s until empty").printf (format_seconds (seconds));
			}
		}

		return info;
	}

	private string format_seconds (int64 seconds) {
		var d = divide (seconds, 86400);
		var h = divide (seconds, 3600);
		var m = divide (seconds, 60);
		var s = seconds;

		if (d > 0)
			return _("%i days").printf (d);
		else if (h > 0)
			return _("%i hours").printf (h);
		else if (m > 0)
			return _("%i minutes").printf (m);
		else
			return _("%i seconds").printf (s);
	}

	private int divide (int64 x, int y) {
		return (int)(x - (x % y)) / y;
	}
}
