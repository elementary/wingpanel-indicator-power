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

public class Power.Indicator : Wingpanel.Indicator {
	private Widgets.DisplayWidget? display_widget = null;

	private Widgets.DeviceList? device_list = null;

	public Indicator () {
		Object (code_name: Wingpanel.Indicator.POWER,
				display_name: _("Power"),
				description:_("Power indicator"));
	}

	public override Gtk.Widget get_display_widget () {
		if (display_widget == null) {
			display_widget = new Widgets.DisplayWidget ();
		}

		return display_widget;
	}

	public override Gtk.Widget? get_widget () {
		if (device_list == null) {
			device_list = new Widgets.DeviceList ();

/*
			DeviceManager.get_default ().has_battery_changed.connect ((has_battery) => {
				// No need to display the indicator when the device is completely in AC mode
				this.visible = has_battery;
			});
*/
this.visible = true;
		}

		return device_list;
	}

	public override void opened () {
		// TODO
	}

	public override void closed () {
		// TODO
	}
}

public Wingpanel.Indicator get_indicator (Module module) {
	debug ("Activating Power Indicator");
	var indicator = new Power.Indicator ();
	return indicator;
}
