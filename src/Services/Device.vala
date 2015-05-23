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

public class Power.Services.Device : Object {
	private const string DEVICE_INTERFACE = "org.freedesktop.UPower.Device";

	private DBusInterfaces.Device? device = null;
	private DBusInterfaces.Properties? device_properties = null;

	public bool has_battery { get; private set; }
	public bool on_battery { get; private set; }
	public bool on_low_battery { get; private set; }

	public Device (string device_path) {
		if (connect_to_bus (device_path)) {
			update_properties ();
			connect_signals ();
		}
	}

	private bool connect_to_bus (string device_path) {
		try {
			device = Bus.get_proxy_sync (BusType.SYSTEM, DEVICE_INTERFACE, device_path, DBusProxyFlags.NONE);
			device_properties = Bus.get_proxy_sync (BusType.SYSTEM, DEVICE_INTERFACE, device_path, DBusProxyFlags.NONE);

			debug ("Connection to UPower device established");

			return device != null & device_properties != null;
		} catch (Error e) {
			warning ("Connecting to UPower device failed");

			return false;
		}
	}

	private void connect_signals () {
		device.Changed.connect (update_properties);
	}

	private void update_properties () {
		
	}
}
