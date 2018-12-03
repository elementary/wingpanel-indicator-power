/*
 * Copyright 2011-2018 elementary, Inc. (https://elementary.io)
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

public class Power.Widgets.DeviceRow : Gtk.ListBoxRow {
    public Services.Device battery { get; construct; }

    private Gtk.Image battery_image;
    private Gtk.Image device_image;

    public DeviceRow (Services.Device battery) {
        Object (battery: battery);
    }

    construct {
        device_image = new Gtk.Image.from_icon_name ("battery", Gtk.IconSize.DIALOG);
        device_image.pixel_size = 48;
        device_image.margin_end = 3;

        battery_image = new Gtk.Image ();
        battery_image.pixel_size = 32;
        battery_image.halign = Gtk.Align.END;
        battery_image.valign = Gtk.Align.END;

        var overlay = new Gtk.Overlay ();
        overlay.add (device_image);
        overlay.add_overlay (battery_image);

        var title_label = new Gtk.Label (get_title ());
        title_label.use_markup = true;
        title_label.halign = Gtk.Align.START;
        title_label.valign = Gtk.Align.END;

        var info_label = new Gtk.Label (get_info ());
        info_label.halign = Gtk.Align.START;
        info_label.valign = Gtk.Align.START;

        var grid = new Gtk.Grid ();
        grid.column_spacing = 3;
        grid.margin = 3;
        grid.margin_start = 6;
        grid.margin_end = 12;
        grid.attach (overlay, 0, 0, 1, 2);
        grid.attach (title_label, 1, 0);
        grid.attach (info_label, 1, 1);

        add (grid);

        update_icons ();

        battery.properties_updated.connect (() => {
            update_icons ();
            title_label.set_markup (get_title ());
            info_label.label = get_info ();
        });
    }

    private void update_icons () {
        unowned string? icon_name = battery.device_type.get_icon_name ();
        if (icon_name != null) {
            device_image.icon_name = icon_name;
            battery_image.icon_name = battery.get_icon_name_for_battery ();
        } else {
            battery_image.clear ();
            device_image.icon_name = battery.get_icon_name_for_battery ();
        }
    }

    private string get_info () {
        var percent = (int)Math.round (battery.percentage);
        var charging = battery.is_charging;

        if (percent <= 0) {
            return _("Calculating…");
        }

        var info = "";

        if (charging) {
            info += _("%i%% charged").printf (percent);

            var seconds = battery.time_to_full;

            if (seconds > 0) {
                info += " - ";
                if (seconds >= 86400) {
                    var days = seconds/86400;
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld day until full", "%lld days until full", (ulong) days).printf (days);
                } else if (seconds >= 3600) {
                    var hours = seconds/3600;
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld hour until full", "%lld hours until full", (ulong) hours).printf (hours);
                } else if (seconds >= 60) {
                    var minutes = seconds/60;
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld minute until full", "%lld minutes until full", (ulong) minutes).printf (minutes);
                } else {
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld second until full", "%lld seconds until full", (ulong) seconds).printf (seconds);
                }
            }
        } else {
            info += _("%i%% remaining").printf (percent);

            var seconds = battery.time_to_empty;

            if (seconds > 0) {
                info += " - ";
                if (seconds >= 86400) {
                    var days = seconds/86400;
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld day until empty", "%lld days until empty", (ulong) days).printf (days);
                } else if (seconds >= 3600) {
                    var hours = seconds/3600;
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld hour until empty", "%lld hours until empty", (ulong) hours).printf (hours);
                } else if (seconds >= 60) {
                    var minutes = seconds/60;
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld minute until empty", "%lld minutes until empty", (ulong) minutes).printf (minutes);
                } else {
                    info += dngettext (Constants.GETTEXT_PACKAGE, "%lld second until empty", "%lld seconds until empty", (ulong) seconds).printf (seconds);
                }
            }
        }

        return info;
    }

    private string get_title () {
        unowned string? type_string = battery.device_type.get_name ();
        if (battery.model != "" && (
                battery.device_type == Power.Services.Device.Type.PHONE ||
                battery.device_type == Power.Services.Device.Type.TABLET)) {
            type_string = battery.model;
        }

        if (type_string != null) {
            return "<b>%s</b>".printf (type_string);
        } else {
            return "<b>%s %s</b>".printf (battery.vendor, _("Device"));
        }
    }
}

// TODO: Replace this and above with P_ when https://bugzilla.gnome.org/show_bug.cgi?id=758000 is fixed.
private void translations () {
    ngettext ("%lld day until full", "%lld days until full", 0);
    ngettext ("%lld hour until full", "%lld hours until full", 0);
    ngettext ("%lld minute until full", "%lld minutes until full", 0);
    ngettext ("%lld second until full", "%lld seconds until full", 0);
    ngettext ("%lld day until empty", "%lld days until empty", 0);
    ngettext ("%lld hour until empty", "%lld hours until empty", 0);
    ngettext ("%lld minute until empty", "%lld minutes until empty", 0);
    ngettext ("%lld second until empty", "%lld seconds until empty", 0);
}
