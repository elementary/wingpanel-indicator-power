/*
 * Copyright (c) 2011-2018 elementary LLC. (https://elementary.io)
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
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 */

namespace Power {
    public class PowerModeButton : Granite.Widgets.ModeButton {
        Gtk.Image power_saving_icon;
        Gtk.Image balanced_icon;
        Gtk.Image high_performance_icon;

        public bool profiles_available = true;

        Services.DBusInterfaces.PowerProfile pprofile;

        List<string> available_profiles;

        public PowerModeButton () {
            try {
                pprofile = Bus.get_proxy_sync (BusType.SYSTEM, Services.DBusInterfaces.POWER_PROFILES_DAEMON_NAME, Services.DBusInterfaces.POWER_PROFILES_DAEMON_PATH, DBusProxyFlags.NONE);
                available_profiles = get_available_power_profiles (pprofile);
                if (available_profiles.length () > 1) {
                    for (int i = 0; i < available_profiles.length (); i++) {
                        switch (available_profiles.nth_data (i)) {
                            case "power-saver":
                            power_saving_icon = new Gtk.Image.from_icon_name ("battery-full-charged-symbolic", Gtk.IconSize.BUTTON);
                            power_saving_icon.tooltip_text = _("Power Saver");
                            append (power_saving_icon);
                            break;
                            case "balanced":
                            balanced_icon = new Gtk.Image.from_icon_name ("tools-timer-symbolic", Gtk.IconSize.BUTTON);
                            balanced_icon.tooltip_text = _("Balanced");
                            append (balanced_icon);
                            break;
                            case "performance":
                            high_performance_icon = new Gtk.Image.from_icon_name ("preferences-system-power-symbolic", Gtk.IconSize.BUTTON);
                            high_performance_icon.tooltip_text = _("High Performance");
                            append (high_performance_icon);
                            break;
                        }
                    }

                    this.mode_changed.connect (() => {
                        pprofile.active_profile = available_profiles.nth_data (this.selected);
                    });

                    update ();
                } else {
                    profiles_available = false;
                }
            } catch (Error e) {
                profiles_available = false;
                append (new Gtk.Label (_("Not Available!")));
            }
        }

        private List<string> get_available_power_profiles (Services.DBusInterfaces.PowerProfile pprofile) {
            List<string> profiles = new List<string> ();
            for (int j = 0; j < pprofile.profiles.length; j++) {
                profiles.append (pprofile.profiles[j].get ("Profile").get_string ());
            }
            return profiles;
        }

        public void update () {
            for (int i = 0; i < available_profiles.length (); i++) {
                if (pprofile != null && pprofile.active_profile == available_profiles.nth_data (i)) {
                    this.selected = i;
                    break;
                }
            }
        }
    }
}
