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

public class Power.Widgets.PopoverWidget : Gtk.Box {
	private const string SETTINGS_EXEC = "/usr/bin/switchboard power";

	private DeviceList device_list;

	private Wingpanel.Widgets.IndicatorSwitch show_percent_switch;

	private Wingpanel.Widgets.IndicatorButton show_settings_button;

	public signal void settings_shown ();

	public PopoverWidget () {
		Object (orientation: Gtk.Orientation.VERTICAL);

		build_ui ();
		connect_signals ();
	}

	private void build_ui () {
		device_list = new DeviceList ();

		this.pack_start (device_list);

		this.pack_start (new Wingpanel.Widgets.IndicatorSeparator ());

		show_percent_switch = new Wingpanel.Widgets.IndicatorSwitch (_("Show Percentage"), Services.SettingsManager.get_default ().show_percentage);
		show_percent_switch.margin_start = 10;

		this.pack_start (show_percent_switch);

		show_settings_button = new Wingpanel.Widgets.IndicatorButton (_("Power Settings") + "…");

		this.pack_start (show_settings_button);
	}

	private void connect_signals () {
		Services.SettingsManager.get_default ().schema.bind ("show-percentage", show_percent_switch.get_switch (), "active", SettingsBindFlags.DEFAULT);

		show_settings_button.clicked.connect (show_settings);
	}

	private void show_settings () {
		var cmd = new Granite.Services.SimpleCommand ("/usr/bin", SETTINGS_EXEC);
		cmd.run ();

		settings_shown ();
	}
}
