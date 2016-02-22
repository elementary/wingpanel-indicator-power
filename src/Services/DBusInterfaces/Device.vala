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
    public interface Device : DBusProxy {
        public abstract HistoryDataPoint[] GetHistory (string type, uint32 timespan, uint32 resolution) throws IOError;

        public abstract StatisticsDataPoint[] GetStatistics (string type) throws IOError;
        public abstract void Refresh () throws IOError;
    }
}
