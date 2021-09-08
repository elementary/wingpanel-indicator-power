# Wingpanel Power Indicator
[![Translation status](https://l10n.elementary.io/widgets/wingpanel/-/wingpanel-indicator-power/svg-badge.svg)](https://l10n.elementary.io/engage/wingpanel/?utm_source=widget)
![Screenshot](data/screenshot.png?raw=true)

## Building and Installation

You'll need the following dependencies:

* libbamf3-dev
* libgranite-dev
* libgtop2-dev
* libudev-dev
* libwingpanel-dev
* libnotify
* meson
* valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install
