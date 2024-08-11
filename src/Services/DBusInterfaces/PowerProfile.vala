/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2024 elementary, Inc. (https://elementary.io)
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
