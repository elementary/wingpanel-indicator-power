public class Power.Utils {

    public double total_y_delta = 0;
    public double total_x_delta = 0;

    /* Smooth scrolling vertical support. Accumulate delta_y until threshold exceeded before actioning */
    public bool handle_scroll_event (Gdk.EventScroll e, out double dir, bool natural_scroll_mouse, bool natural_scroll_touchpad) {
        dir = 0.0;
        bool natural_scroll;
        var event_source = e.get_source_device ().input_source;
        if (event_source == Gdk.InputSource.MOUSE) {
            natural_scroll = natural_scroll_mouse;
        } else if (event_source == Gdk.InputSource.TOUCHPAD) {
            natural_scroll = natural_scroll_touchpad;
        } else {
            natural_scroll = false;
        }

        switch (e.direction) {
            case Gdk.ScrollDirection.SMOOTH:
                var abs_x = double.max (e.delta_x.abs (), 0.0001);
                var abs_y = double.max (e.delta_y.abs (), 0.0001);

                if (abs_y / abs_x > 2.0) {
                    total_y_delta += e.delta_y;
                } else if (abs_x / abs_y > 2.0) {
                    total_x_delta += e.delta_x;
                }

                break;
            case Gdk.ScrollDirection.UP:
                total_y_delta = -1.0;
                break;
            case Gdk.ScrollDirection.DOWN:
                total_y_delta = 1.0;
                break;
            case Gdk.ScrollDirection.LEFT:
                total_x_delta = -1.0;
                break;
            case Gdk.ScrollDirection.RIGHT:
                total_x_delta = 1.0;
                break;
            default:
                break;
        }

        if (total_y_delta.abs () > 0.5) {
            dir = natural_scroll ? total_y_delta : -total_y_delta;
        } else if (total_x_delta.abs () > 0.5) {
            dir = natural_scroll ? -total_x_delta : total_x_delta;
        }

        if (dir.abs () > 0.0) {
            total_y_delta = 0.0;
            total_x_delta = 0.0;
            return true;
        }

        return false;
    }
}
