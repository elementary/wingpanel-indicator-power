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

public class Power.Services.AppManager : Object {
    public struct PowerEater {
        Bamf.Application application;
        int cpu_usage;
    }

    private static AppManager? instance = null;

    public AppManager () {
    }

    public Gee.List<PowerEater? > get_top_power_eaters (int count) {
        var list = new Gee.ArrayList<PowerEater? > ();

        var matcher = Bamf.Matcher.get_default ();
        var applications = matcher.get_running_applications ();

        applications.@foreach ((app) => {
            /* cpu-usage in percent */
            var cpu_usage = (int)(get_cpu_usage_for_app (app) * 100);

            if (cpu_usage >= 10) {
                list.add ({ app, cpu_usage });
            }
        });

        list.sort ((a, b) => {
            if (a.cpu_usage < b.cpu_usage) {
                return 1;
            }

            if (a.cpu_usage > b.cpu_usage) {
                return -1;
            }

            return 0;
        });

        return count < list.size ? list.slice (0, count) : list;
    }

    private double get_cpu_usage_for_app (Bamf.Application app) {
        double cpu_usage_sum = 0;

        foreach (var window in app.get_windows ()) {
            var window_type = window.get_window_type ();

            if (window_type != Bamf.WindowType.DOCK && window_type != Bamf.WindowType.MENU) {
                cpu_usage_sum += get_sub_process_cpu_usage_sum ((int)window.get_pid ());
            }
        }

        return cpu_usage_sum;
    }

    private double get_sub_process_cpu_usage_sum (int parent_pid) {
        var sub_processes = ProcessMonitor.Monitor.get_default ().get_sub_processes (parent_pid);

        double cpu_usage_sum = get_process_cpu_usage (parent_pid);

        foreach (int sp_pid in sub_processes) {
            cpu_usage_sum += get_sub_process_cpu_usage_sum (sp_pid);
        }

        return cpu_usage_sum;
    }

    private double get_process_cpu_usage (int pid) {
        var process = ProcessMonitor.Monitor.get_default ().get_process (pid);

        if (process != null) {
            return process.cpu_usage;
        }

        return 0;
    }

    public static AppManager get_default () {
        if (instance == null) {
            instance = new AppManager ();
        }

        return instance;
    }
}
