/*
 * Copyright (c) 2011-2015 elementary LLC. (https://elementary.io)
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

public class Power.Indicator : Wingpanel.Indicator {
    private bool is_in_session { get; construct set; }

    private Widgets.DisplayWidget? display_widget = null;

    private Widgets.PopoverWidget? popover_widget = null;

    private Services.Device primary_battery;
    private bool notify_battery = false;

    public Indicator (bool is_in_session) {
        Object (code_name : Wingpanel.Indicator.POWER,
                display_name : _("Power"),
                description: _("Power indicator"),
                is_in_session: is_in_session);
    }

    construct {
        popover_widget = new Widgets.PopoverWidget (is_in_session);
        display_widget = new Widgets.DisplayWidget (popover_widget);

        popover_widget.settings_shown.connect (() => close ());

        var dm = Services.DeviceManager.get_default ();

        /* No need to display the indicator when the device is completely in AC mode */
        if (dm.has_battery || dm.backlight.present) {
            update_visibility ();
        }
        dm.notify["has-battery"].connect (update_visibility);        
    }

    public override Gtk.Widget get_display_widget () {
        return display_widget;
    }

    public override Gtk.Widget? get_widget () {
        return popover_widget;
    }

    public override void opened () {
        Services.ProcessMonitor.Monitor.get_default ().update ();
        popover_widget.update_brightness_slider ();
    }

    public override void closed () {
        popover_widget.slim_down ();
    }

    private void update_visibility () {
        var dm = Services.DeviceManager.get_default ();

        bool should_be_visible = (dm.has_battery || dm.backlight.present);
        if (visible != should_be_visible) {
            /* NOTE: popover closes every time you set visibility, so change property only when needed */
            visible = should_be_visible;
        }
        
        if (visible) {
            if (dm.has_battery) {
                update_primary_battery ();
                if (!notify_battery) {
                    dm.notify["primary-battery"].connect (update_primary_battery);
                    notify_battery = true;
                }
            } else {
                show_backlight_data ();
                if (notify_battery) {
                    dm.notify["primary-battery"].disconnect (update_primary_battery);
                    notify_battery = false;
                }
            }
        }
    }

    private void update_primary_battery () {
        if (primary_battery != null) {
            primary_battery.properties_updated.disconnect (show_primary_battery_data);
        }

        primary_battery = Services.DeviceManager.get_default ().primary_battery;
        if (primary_battery != null) {
            show_primary_battery_data ();
            primary_battery.properties_updated.connect (show_primary_battery_data);
        }
    }

    private void show_primary_battery_data () {
        if (primary_battery != null && display_widget != null) {
            var icon_name = Utils.get_symbolic_icon_name_for_battery (primary_battery);
            
            display_widget.set_icon_name (icon_name, true);

            /* Debug output for designers */
            debug ("Icon changed to \"%s\"", icon_name);

            display_widget.set_percent ((int)Math.round (primary_battery.percentage));
        }
    }

    private void show_backlight_data () {
        if (display_widget != null) {
            var icon_name = Utils.get_symbolic_icon_name_for_backlight ();

            display_widget.set_icon_name (icon_name, false);

            /* Debug output for designers */
            debug ("Icon changed to \"%s\"", icon_name);
        }
    }
}

public Wingpanel.Indicator get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Power Indicator");

    var indicator = new Power.Indicator (server_type == Wingpanel.IndicatorManager.ServerType.SESSION);

    return indicator;
}
