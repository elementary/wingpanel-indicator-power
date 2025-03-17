wingpanel_dep = dependency('wingpanel')
wingpanel_indicatorsdir = wingpanel_dep.get_variable('indicatorsdir', pkgconfig_define: ['libdir', libdir])

conf_data = configuration_data()
conf_data.set('GETTEXT_PACKAGE', gettext_name)
conf_data.set('LOCALEDIR', prefix / get_option('localedir'))

config_in = configure_file(
    input: 'config.vala.in',
    output: '@BASENAME@',
    configuration: conf_data
)

files = files(
    'ddc/ddc.h',
    'ddc/ddc.c',
    'Indicator.vala',
    'Utils.vala',
    'Services/Backlight/Backlight.vala',
    'Services/DBusInterfaces/Device.vala',
    'Services/DBusInterfaces/Properties.vala',
    'Services/DBusInterfaces/Screen.vala',
    'Services/DBusInterfaces/UPower.vala',
    'Services/DBusInterfaces/PowerProfile.vala',
    'Services/Device.vala',
    'Services/DeviceManager.vala',
    'Widgets/DeviceList.vala',
    'Widgets/DeviceRow.vala',
    'Widgets/DisplayWidget.vala',
    'Widgets/PopoverWidget.vala',
    'Widgets/ScreenBrightness.vala',
    'Widgets/PowerModeList.vala'
)

ddc_dir = meson.current_source_dir() / 'ddc'

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('granite', version: '>=6.0.0'),
    dependency('gtk+-3.0'),
    dependency('libgtop-2.0'),
    dependency('libudev'),
    dependency('libnotify'),
    meson.get_compiler('vala').find_library('posix'),
    meson.get_compiler('vala').find_library('ddc', dirs: ddc_dir, required: true),
    wingpanel_dep
]

shared_module(
    meson.project_name(),
    files,
    indicator_resources,
    config_in,
    dependencies: dependencies,
    include_directories: ['ddc'],
    link_args: ['-lddcutil'],
    install: true,
    install_dir : wingpanel_indicatorsdir
)
