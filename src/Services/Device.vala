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

            debug ("Connection to UPower device established");
        } catch (Error e) {
            critical ("Connecting to UPower device failed: %s", e.message);
        }

        return device != null;
    }

    private void connect_signals () {
        device.g_properties_changed.connect (update_properties);
    }

    private void update_properties () {
        try {
            device.Refresh ();
        } catch (Error e) {
            critical ("Updating the upower device parameters failed: %s", e.message);
        }

        has_history = device.has_history;
        has_statistics = device.has_statistics;
        is_present = device.is_present;
        is_rechargeable = device.is_rechargeable;
        online = device.online;
        power_supply = device.power_supply;
        capacity = device.capacity;
        energy = device.energy;
        energy_empty = device.energy_empty;
        energy_full = device.energy_full;
        energy_full_design = device.energy_full_design;
        energy_rate = device.energy_rate;
        luminosity = device.luminosity;
        percentage = device.percentage;
        temperature = device.temperature;
        voltage = device.voltage;
        time_to_empty = device.time_to_empty;
        time_to_full = device.time_to_full;
        model = device.model;
        native_path = device.native_path;
        serial = device.serial;
        vendor = device.vendor;
        device_type = device.Type;
        state = device.state;
        technology = device.technology;
        update_time = device.update_time;

        properties_updated ();
    }
}
