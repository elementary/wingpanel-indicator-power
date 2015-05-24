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

	private void add_battery (string device_path,	 Services.Device battery) {
		var grid = new Gtk.Grid ();
		grid.column_spacing = 6;
		grid.row_spacing = 6;
		grid.margin = 6;

		var image = new Gtk.Image.from_icon_name (Utils.get_icon_name_for_battery (battery), Gtk.IconSize.DIALOG);

		grid.attach (image, 0, 0, 1, 2);

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

		if (battery.device_type == DEVICE_TYPE_BATTERY)
			this.pack_start (grid);
		else
			this.pack_end (grid);

		battery.properties_updated.connect (() => {
			image.set_from_icon_name (Utils.get_icon_name_for_battery (battery), Gtk.IconSize.DIALOG);
			title_label.set_markup (Utils.get_title_for_battery (battery));
			info_label.set_label (Utils.get_info_for_battery (battery));
		});

		this.show_all ();
	}

	private void remove_battery (string device_path) {
		if (!entries.has_key (device_path))
			return;

		this.remove (entries.@get (device_path));

		entries.unset (device_path);
	}
}
