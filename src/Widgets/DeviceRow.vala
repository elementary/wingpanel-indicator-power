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

public class Power.Widgets.DeviceRow : Gtk.Grid {
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

        column_spacing = 3;
        margin = 3;
        margin_start = 6;
        margin_end = 12;
        attach (overlay, 0, 0, 1, 2);
        attach (title_label, 1, 0);
        attach (info_label, 1, 1);

        update_icons ();

        battery.properties_updated.connect (() => {
            update_icons ();
            title_label.set_markup (get_title ());
            info_label.label = get_info ();
        });
    }

    private void update_icons () {
        bool use_battery_image = true;

        switch (battery.device_type) {
            case DEVICE_TYPE_PHONE:
                device_image.icon_name = "phone";
                break;
            case DEVICE_TYPE_MOUSE:
                device_image.icon_name = "input-mouse";
                break;
            case DEVICE_TYPE_KEYBOARD:
                device_image.icon_name = "input-keyboard";
                break;
            case DEVICE_TYPE_TABLET:
                device_image.icon_name = "input-tablet";
                break;
            default:
                use_battery_image = false;
                battery_image.clear ();
                device_image.icon_name = Utils.get_icon_name_for_battery (battery);
                break;
        }

        if (use_battery_image) {
            battery_image.icon_name = Utils.get_icon_name_for_battery (battery);
        }
    }

    private string get_info () {
        var percent = (int)Math.round (battery.percentage);
        var charging = Utils.is_charging (battery.state);

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
        var title = "";

        switch (battery.device_type) {
            /* TODO: Do we want to differentiate between batteries and rechargeable batteries? (See German: Batterie <-> Akku) */
            case DEVICE_TYPE_BATTERY:
                title = _("Battery");
                break;
            case DEVICE_TYPE_UPS:
                title = _("UPS");
                break;
            case DEVICE_TYPE_MONITOR:
                title = _("Display");
                break;
            case DEVICE_TYPE_MOUSE:
                title = _("Mouse");
                break;
            case DEVICE_TYPE_KEYBOARD:
                title = _("Keyboard");
                break;
            case DEVICE_TYPE_PDA:
                title = _("PDA");
                break;
            case DEVICE_TYPE_PHONE:
                if (battery.model != "") {
                    title = battery.model;
                } else {
                    title = _("Phone");
                }
                break;
            case DEVICE_TYPE_MEDIA_PLAYER:
                title = _("Media Player");
                break;
            case DEVICE_TYPE_TABLET:
                if (battery.model != "") {
                    title = battery.model;
                } else {
                    title = _("Tablet");
                }
                break;
            case DEVICE_TYPE_COMPUTER:
                title = _("Computer");
                break;
            default:
                title = "%s %s".printf (battery.vendor, _("Device"));
                break;
        }

        return "<b>%s</b>".printf (title);
    }
}
