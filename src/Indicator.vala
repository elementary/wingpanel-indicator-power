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
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class Power.Indicator : Wingpanel.Indicator {
    private bool is_in_session = false;

    private Widgets.DisplayWidget? display_widget = null;

    private Widgets.PopoverWidget? popover_widget = null;

    private Services.Device primary_battery;

    public Indicator (bool is_in_session) {
        Object (code_name : Wingpanel.Indicator.POWER,
                display_name : _("Power"),
                description: _("Power indicator"));

        this.is_in_session = is_in_session;
    }

    public override Gtk.Widget get_display_widget () {
        if (display_widget == null) {
            display_widget = new Widgets.DisplayWidget ();
        }

        return display_widget;
    }

    public override Gtk.Widget? get_widget () {
        if (popover_widget == null) {
            popover_widget = new Widgets.PopoverWidget (is_in_session);
            popover_widget.settings_shown.connect (() => this.close ());

            var dm = Services.DeviceManager.get_default ();

            /* No need to display the indicator when the device is completely in AC mode */
            if (dm.has_battery || dm.backlight.present) {
                update_visibility ();
                if (dm.primary_battery != null) {
                    update_primary_battery ();
                    /* No need to display the indicator when the device is completely in AC mode */
                    dm.notify["has-battery"].connect (update_visibility);
                    dm.notify["primary-battery"].connect (update_primary_battery);
                } else if (dm.backlight.present) {
                    show_backlight_data ();
                }
            }
        }

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
        if (dm.has_battery || dm.backlight.present) {
            visible = true;
        } else {
            visible = false;
        }
    }

    private void update_primary_battery () {
        primary_battery = Services.DeviceManager.get_default ().primary_battery;

        show_battery_data (primary_battery);

        primary_battery.properties_updated.connect (() => {
            show_battery_data (primary_battery);
        });
    }

    private void show_battery_data (Services.Device battery) {
        if (display_widget != null) {
            var icon_name = Utils.get_symbolic_icon_name_for_battery (battery);

            display_widget.set_icon_name (icon_name);

            /* Debug output for designers */
            debug ("Icon changed to \"%s\"", icon_name);

            display_widget.set_percent ((int)Math.round (battery.percentage));
    	}
    }

    private void show_backlight_data () {
        if (display_widget != null) {
	    var icon_name = Utils.get_symbolic_icon_name_for_backlight ();

	    display_widget.set_icon_name (icon_name);

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
