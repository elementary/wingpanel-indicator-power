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

public class Power.Widgets.AppList : Gtk.Box {
	private Services.AppManager app_manager;

	public AppList () {
		Object (orientation: Gtk.Orientation.VERTICAL);

		app_manager = Services.AppManager.get_default ();
	}

	public void update_list () {
		clear_list ();

		app_manager.get_top_power_eaters (12).@foreach ((power_eater) => {
			add_app (power_eater);

			return true;
		});
	}

	public bool is_empty () {
		return (this.get_children ().length () == 0);
	}

	private void clear_list () {
		foreach (var child in this.get_children ())
			this.remove (child);
	}

	private void add_app (Services.AppManager.PowerEater power_eater) {
		var desktop_app_info = new DesktopAppInfo.from_filename (power_eater.application.get_desktop_file ());

		var app_icon = desktop_app_info.get_icon ();
		var app_name = desktop_app_info.get_generic_name ();
		var cpu_usage = power_eater.cpu_usage;

		if (app_icon == null || app_name == null)
			return;

		var grid = new Gtk.Grid ();
		grid.column_spacing = 6;
		grid.margin = 6;

		var app_icon_image = new Gtk.Image.from_gicon (app_icon, Gtk.IconSize.LARGE_TOOLBAR);
		app_icon_image.pixel_size = 24;

		var app_name_label = new Gtk.Label (app_name);
		app_name_label.hexpand = true;
		app_name_label.halign = Gtk.Align.START;

		var cpu_usage_label = new Gtk.Label ("%i%%".printf (cpu_usage));
		cpu_usage_label.halign = Gtk.Align.END;

		grid.attach (app_icon_image, 0, 0, 1, 1);
		grid.attach (app_name_label, 1, 0, 1, 1);
		grid.attach (cpu_usage_label, 2, 0, 1, 1);

		this.add (grid);
		this.show_all ();
	}
}
