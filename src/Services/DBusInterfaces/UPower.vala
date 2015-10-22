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

namespace Power.Services.DBusInterfaces {
    [DBus (name = "org.freedesktop.UPower")]
    public interface UPower : Object {
        public abstract string[] EnumerateDevices () throws IOError;

        public signal void Changed ();
        public signal void DeviceAdded (string device_path);
        public signal void DeviceChanged (string device_path);
        public signal void DeviceRemoved (string device_path);
    }
}