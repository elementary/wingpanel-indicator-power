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

	private Widgets.PopoverWidget? popover_widget = null;

	private Services.Device primary_battery;

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
		if (popover_widget == null) {
			popover_widget = new Widgets.PopoverWidget ();
			popover_widget.settings_shown.connect (() => this.close ());

			// No need to display the indicator when the device is completely in AC mode
			Services.DeviceManager.get_default ().notify["has-battery"].connect (update_visibility);
			Services.DeviceManager.get_default ().notify["primary-battery"].connect (update_primary_battery);

			// Start the device-search after connecting the signals
			Services.DeviceManager.get_default ().init ();
		}

		return popover_widget;
	}

	public override void opened () {
		// TODO
	}

	public override void closed () {
		// TODO
	}

	private void update_visibility () {
		if (this.visible != Services.DeviceManager.get_default ().has_battery)
			this.visible = Services.DeviceManager.get_default ().has_battery;
	}

	private void update_primary_battery () {
		primary_battery = Services.DeviceManager.get_default ().primary_battery;

		show_battery_data (primary_battery);

		primary_battery.properties_updated.connect (() => {
			show_battery_data (primary_battery);
		});
	}

	private void show_battery_data (Services.Device battery) {
		if (display_widget != null) {
			var icon_name = Utils.get_symbolic_icon_name_for_battery (battery);

			display_widget.set_icon_name (icon_name);

			// Debug output for designers
			debug ("Icon changed to \"%s\"", icon_name);

			display_widget.set_percent ((int)Math.round (battery.percentage));
		}
	}
}

public Wingpanel.Indicator get_indicator (Module module) {
	debug ("Activating Power Indicator");
	var indicator = new Power.Indicator ();
	return indicator;
}
