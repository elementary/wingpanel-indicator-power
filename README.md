# Wingpanel Power Indicator
[![l10n](https://l10n.elementary.io/widgets/wingpanel/wingpanel-indicator-power/svg-badge.svg)](https://l10n.elementary.io/projects/wingpanel/wingpanel-indicator-power)

## Building and Installation

You'll need the following dependencies:

* cmake
* libbamf3-dev
* libgranite-dev
* libgtop2-dev
* libudev-dev
* libwingpanel-2.0-dev
* valac

It's recommended to create a clean build environment

    mkdir build
    cd build/
    
Run `cmake` to configure the build environment and then `make` to build

    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    make
    
To install, use `make install`

    sudo make install
