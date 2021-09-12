/*
 * Copyright (c) 2011-2016 elementary LLC. (https://launchpad.net/switchboard-plug-power)
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
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA  02110-1301, USA.
 * 
 * Author: Subhadeep Jasu <subhajasu@gmail.com>
 */

namespace Power.Services.DBusInterfaces {
    public const string POWER_PROFILES_DAEMON_NAME = "net.hadess.PowerProfiles";
    public const string POWER_PROFILES_DAEMON_PATH = "/net/hadess/PowerProfiles";

    [DBus (name = "net.hadess.PowerProfiles")]
    interface PowerProfile : Object {
        public signal void changed ();
        public abstract HashTable<string, Variant>[] profiles { owned get; }
        public abstract string active_profile { owned get; set; }
    }
}
