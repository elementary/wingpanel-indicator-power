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

const string HISTORY_TYPE_RATE = "rate";
const string HISTORY_TYPE_CHARGE = "charge";

const string STATISTICS_TYPE_CHARGING = "charging";
const string STATISTICS_TYPE_DISCHARGING = "discharging";

namespace Power.Services.DBusInterfaces {
	public struct HistoryDataPoint {
		uint32 time;
		double value;
		uint32 state;
	}

	public struct StatisticsDataPoint {
		double value;
		double accuracy;
	}

	[DBus (name = "org.freedesktop.UPower.Device")]
	public interface Device : Object {
		public abstract HistoryDataPoint[] GetHistory (string type, uint32 timespan, uint32 resolution) throws IOError;
		public abstract StatisticsDataPoint[] GetStatistics (string type) throws IOError;
		public abstract void Refresh () throws IOError;

		public signal void Changed ();
	}
}
