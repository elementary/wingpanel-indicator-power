wingpanel_dep = dependency('wingpanel-2.0')

conf_data = configuration_data()
conf_data.set('GETTEXT_PACKAGE', gettext_name)

config_in = configure_file(
    input: 'config.vala.in',
    output: '@BASENAME@',
    configuration: conf_data
)

files = files(
    'Indicator.vala',
    'Utils.vala',
    'Services/AppManager.vala',
    'Services/Backlight/Backlight.vala',
    'Services/DBusInterfaces/Device.vala',
    'Services/DBusInterfaces/Properties.vala',
    'Services/DBusInterfaces/Screen.vala',
    'Services/DBusInterfaces/UPower.vala',
    'Services/Device.vala',
    'Services/DeviceManager.vala',
    'Services/ProcessMonitor/Monitor.vala',
    'Services/ProcessMonitor/Process.vala',
    'Services/SettingsManager.vala',
    'Widgets/AppList.vala',
    'Widgets/DeviceList.vala',
    'Widgets/DisplayWidget.vala',
    'Widgets/PopoverWidget.vala',
    'Widgets/ScreenBrightness.vala'
)

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('granite'),
    dependency('gtk+-3.0'),
    dependency('libbamf3'),
    dependency('libgtop-2.0'),
    dependency('libudev'),
    meson.get_compiler('vala').find_library('posix'),
    wingpanel_dep
]

shared_module(
    meson.project_name(),
    files,
    config_in,
    dependencies: dependencies,
    install: true,
    install_dir : wingpanel_dep.get_pkgconfig_variable('indicatorsdir')
)
