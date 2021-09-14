/*
 * Copyright (c) 2021 Justin Haygood (jhaygood86@gmail.com)
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
 * Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

public class Power.Services.PowerProfileManager : Object {
    private const string POWERPROFILE_INTERFACE = "net.hadess.PowerProfiles";
    private const string PROPERTIES_INTERFACE = "org.freedesktop.DBus.Properties";
    private const string POWERPROFILE_PATH = "/net/hadess/PowerProfiles";

    private static PowerProfileManager? instance = null;

    private DBusInterfaces.PowerProfiles? power_profile_bus = null;
    private DBusInterfaces.Properties? properties_bus = null;

    public Gee.Map<string, PowerProfile> profiles { get; private set; }

    public signal void profile_added (PowerProfile profile);
    public signal void profile_changed (PowerProfile profile);

    construct {
        profiles = new Gee.HashMap<string, PowerProfile> ();

        connect_to_bus.begin ((obj, res) => {
            if (connect_to_bus.end (res)) {
                read_profiles ();
            }
        });
    }

        // singleton one class object in memory. use instance to get data.
    public static unowned PowerProfileManager get_default () {
        if (instance == null) {
            instance = new PowerProfileManager ();
        }

        return instance;
    }

    private async bool connect_to_bus () {

        try {
            power_profile_bus = yield Bus.get_proxy (
                BusType.SYSTEM,
                POWERPROFILE_INTERFACE,
                POWERPROFILE_PATH,
                DBusProxyFlags.NONE
            );

            properties_bus = yield Bus.get_proxy (
                BusType.SYSTEM,
                PROPERTIES_INTERFACE,
                POWERPROFILE_PATH,
                DBusProxyFlags.NONE
            );

            properties_bus.PropertiesChanged.connect((changed, propertiesm, array) => {
               if (changed == POWERPROFILE_INTERFACE) {
                   if(propertiesm.contains ("ActiveProfile")) {
                        var active_profile_name = propertiesm["ActiveProfile"].get_string ();
                        var profile = profiles[active_profile_name];
                        profile_changed(profile);
                   }
               }
            });

            debug ("Connection to Power Profiles bus established");

            return true;
        } catch (Error e) {
            critical ("Connecting to Power Profiles bus failed: %s", e.message);

            return false;
        }
    }

    private void read_profiles () {

        if (power_profile_bus != null) {
            foreach(var profile in power_profile_bus.profiles) {
                var profile_name = profile["Profile"].get_string ();
                var driver_name = profile["Driver"].get_string ();

                var power_profile = new PowerProfile (profile_name, driver_name);
                profiles[profile_name] = power_profile;
                profile_added(power_profile);
            }
        }
    }

    public PowerProfile? active_profile {
        owned get {
            if (power_profile_bus != null) {
                var active_profile_from_bus = power_profile_bus.active_profile;
                return profiles[active_profile_from_bus];
            }

            return null;
        }

        set {
            var active_profile_name = value.profile;
            power_profile_bus.active_profile = active_profile_name;
        }
    }
}
