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

public class Power.Services.DeviceManager : Object {
	private const string UPOWER_INTERFACE = "org.freedesktop.UPower";
	private const string UPOWER_PATH = "/org/freedesktop/UPower";

	private static DeviceManager? instance = null;

	private DBusInterfaces.UPower? upower = null;
	private DBusInterfaces.Properties? upower_properties = null;

	public Gee.HashMap<string, Device> devices;
	public Gee.Iterator batteries;

	public bool has_battery { get; private set; }

	public bool on_battery { get; private set; }
	public bool on_low_battery { get; private set; }

	public DeviceManager () {
		if (connect_to_bus ()) {
			update_properties ();
			read_devices ();
			update_batteries ();
			connect_signals ();
		}
	}

	private bool connect_to_bus () {
		devices = new Gee.HashMap<string, Device> ();

		try {
			upower = Bus.get_proxy_sync (BusType.SYSTEM, UPOWER_INTERFACE, UPOWER_PATH, DBusProxyFlags.NONE);
			upower_properties = Bus.get_proxy_sync (BusType.SYSTEM, UPOWER_INTERFACE, UPOWER_PATH, DBusProxyFlags.NONE);

			debug ("Connection to UPower bus established");

			return upower != null & upower_properties != null;
		} catch (Error e) {
			warning ("Connecting to UPower bus failed: %s", e.message);

			return false;
		}
	}

	private void read_devices () {
		try {
			var devices = upower.EnumerateDevices ();

			foreach (string device_path in devices) {
				register_device (device_path);
			}
		} catch (Error e) {
			warning ("Reading UPower devices failed: %s", e.message);
		}
	}

	private void connect_signals () {
		upower.Changed.connect (update_properties);
		upower.DeviceChanged.connect (() => {
			update_properties ();
			update_batteries ();
		});
		upower.DeviceAdded.connect (register_device);
		upower.DeviceRemoved.connect (deregister_device);
	}

	private void update_properties () {
		try {
			on_battery = upower_properties.Get (UPOWER_PATH, "OnBattery").get_boolean ();
			on_low_battery = upower_properties.Get (UPOWER_PATH, "OnLowBattery").get_boolean ();
		} catch (Error e) {
			warning ("Updating UPower properties failed: %s", e.message);
		}
	}

	private void update_batteries () {
		batteries = devices.filter ((entry) => {
			var device = entry.value;

			return device.device_type != DEVICE_TYPE_UNKNOWN && device.device_type != DEVICE_TYPE_LINE_POWER;
		});

		has_battery = batteries.has_next ();
	}

	private void register_device (string device_path) {
		var device = new Device (device_path);

		devices.@set (device_path, device);

		debug ("Device \"%s\" registered", device_path);

		update_batteries ();
	}

	private void deregister_device (string device_path) {
		if (!devices.has_key (device_path))
			return;

		if (!devices.unset (device_path))
			return;

		debug ("Device \"%s\" deregistered", device_path);

		update_batteries ();
	}

	public static DeviceManager get_default () {
		if (instance == null)
			instance = new DeviceManager ();

		return instance;
	}
}
