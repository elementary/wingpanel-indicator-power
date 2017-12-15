# Wingpanel Power Indicator
[![l10n](https://l10n.elementary.io/widgets/wingpanel/wingpanel-indicator-power/svg-badge.svg)](https://l10n.elementary.io/projects/wingpanel/wingpanel-indicator-power)

![Screenshot](data/screenshot.png?raw=true)

## Building and Installation

You'll need the following dependencies:

* libbamf3-dev
* libgranite-dev
* libgtop2-dev
* libudev-dev
* libwingpanel-2.0-dev
* meson
* valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install
