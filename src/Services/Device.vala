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

const uint32 DEVICE_STATE_UNKNOWN = 0;
const uint32 DEVICE_STATE_CHARGING = 1;
const uint32 DEVICE_STATE_DISCHARGING = 2;
const uint32 DEVICE_STATE_EMPTY = 3;
const uint32 DEVICE_STATE_FULLY_CHARGED = 4;
const uint32 DEVICE_STATE_PENDING_CHARGE = 5;
const uint32 DEVICE_STATE_PENDING_DISCHARGE = 6;

const uint32 DEVICE_TECHNOLOGY_UNKNOWN = 0;
const uint32 DEVICE_TECHNOLOGY_LITHIUM_ION = 1;
const uint32 DEVICE_TECHNOLOGY_LITHIUM_POLYMER = 2;
const uint32 DEVICE_TECHNOLOGY_LITHIUM_IRON_PHOSPHATE = 3;
const uint32 DEVICE_TECHNOLOGY_LEAD_ACID = 4;
const uint32 DEVICE_TECHNOLOGY_NICKEL_CADMIUM = 5;
const uint32 DEVICE_TECHNOLOGY_NICKEL_METAL_HYDRIDE = 6;

const uint32 DEVICE_TYPE_UNKNOWN = 0;
const uint32 DEVICE_TYPE_LINE_POWER = 1;
const uint32 DEVICE_TYPE_BATTERY = 2;
const uint32 DEVICE_TYPE_UPS = 3;
const uint32 DEVICE_TYPE_MONITOR = 4;
const uint32 DEVICE_TYPE_MOUSE = 5;
const uint32 DEVICE_TYPE_KEYBOARD = 6;
const uint32 DEVICE_TYPE_PDA = 7;
const uint32 DEVICE_TYPE_PHONE = 8;

public class Power.Services.Device : Object {
	private const string DEVICE_INTERFACE = "org.freedesktop.UPower";

	private string device_path = "";

	private DBusInterfaces.Device? device = null;
	private DBusInterfaces.Properties? device_properties = null;

	public bool has_history { get; private set; }
	public bool has_statistics { get; private set; }
	public bool is_present { get; private set; }
	public bool is_rechargeable { get; private set; }
	public bool online { get; private set; }
	public bool power_supply { get; private set; }
	public double capacity { get; private set; }
	public double energy { get; private set; }
	public double energy_empty { get; private set; }
	public double energy_full { get; private set; }
	public double energy_full_design { get; private set; }
	public double energy_rate { get; private set; }
	public double luminosity { get; private set; }
	public double percentage { get; private set; }
	public double temperature { get; private set; }
	public double voltage { get; private set; }
	public int64 time_to_empty { get; private set; }
	public int64 time_to_full { get; private set; }
	public string model { get; private set; }
	public string native_path { get; private set; }
	public string serial { get; private set; }
	public string vendor { get; private set; }
	public uint32 state { get; private set; }
	public uint32 technology { get; private set; }
	public uint32 device_type { get; private set; }
	public uint64 update_time { get; private set; }

	public signal void properties_updated ();

	public Device (string device_path) {
		this.device_path = device_path;

		if (connect_to_bus ()) {
			update_properties ();
			connect_signals ();
		}
	}

	private bool connect_to_bus () {
		try {
			device = Bus.get_proxy_sync (BusType.SYSTEM, DEVICE_INTERFACE, device_path, DBusProxyFlags.NONE);
			device_properties = Bus.get_proxy_sync (BusType.SYSTEM, DEVICE_INTERFACE, device_path, DBusProxyFlags.NONE);

			debug ("Connection to UPower device established");

			return device != null & device_properties != null;
		} catch (Error e) {
			critical ("Connecting to UPower device failed: %s", e.message);

			return false;
		}
	}

	private void connect_signals () {
		device.g_properties_changed.connect (update_properties);
	}

	private void update_properties () {
		try {
			has_history = device_properties.Get (device_path, "HasHistory").get_boolean ();
			has_statistics = device_properties.Get (device_path, "HasStatistics").get_boolean ();
			is_present = device_properties.Get (device_path, "IsPresent").get_boolean ();
			is_rechargeable = device_properties.Get (device_path, "IsRechargeable").get_boolean ();
			online = device_properties.Get (device_path, "Online").get_boolean ();
			power_supply = device_properties.Get (device_path, "PowerSupply").get_boolean ();
			capacity = device_properties.Get (device_path, "Capacity").get_double ();
			energy = device_properties.Get (device_path, "Energy").get_double ();
			energy_empty = device_properties.Get (device_path, "EnergyEmpty").get_double ();
			energy_full = device_properties.Get (device_path, "EnergyFull").get_double ();
			energy_full_design = device_properties.Get (device_path, "EnergyFullDesign").get_double ();
			energy_rate = device_properties.Get (device_path, "EnergyRate").get_double ();
			luminosity = device_properties.Get (device_path, "Luminosity").get_double ();
			percentage = device_properties.Get (device_path, "Percentage").get_double ();
			temperature = device_properties.Get (device_path, "Temperature").get_double ();
			voltage = device_properties.Get (device_path, "Voltage").get_double ();
			time_to_empty = device_properties.Get (device_path, "TimeToEmpty").get_int64 ();
			time_to_full = device_properties.Get (device_path, "TimeToFull").get_int64 ();
			model = device_properties.Get (device_path, "Model").get_string ();
			native_path = device_properties.Get (device_path, "NativePath").get_string ();
			serial = device_properties.Get (device_path, "Serial").get_string ();
			vendor = device_properties.Get (device_path, "Vendor").get_string ();
			state = device_properties.Get (device_path, "State").get_uint32 ();
			technology = device_properties.Get (device_path, "Technology").get_uint32 ();
			device_type = device_properties.Get (device_path, "Type").get_uint32 ();
			update_time = device_properties.Get (device_path, "UpdateTime").get_uint64 ();

			properties_updated ();
		} catch (Error e) {
			critical ("Updating device properties failed: %s", e.message);
		}
	}
}
