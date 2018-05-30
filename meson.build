project('power', 'vala', 'c')

gettext_name = meson.project_name() + '-indicator'
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(gettext_name), language:'c')
add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], 
                      language: 'vala')

wingpanel_dep = dependency('wingpanel-2.0')

conf_data = configuration_data()
conf_data.set('GETTEXT_PACKAGE', gettext_name)

config_in = configure_file(
    input: 'config.vala.in',
    output: '@BASENAME@',
    configuration: conf_data
)

shared_module(
    meson.project_name(),
    'src/Indicator.vala',
    'src/Utils.vala',
    'src/Services/AppManager.vala',
    'src/Services/Device.vala',
    'src/Services/DeviceManager.vala',
    'src/Services/SettingsManager.vala',
    'src/Services/Backlight/Backlight.vala',
    'src/Services/DBusInterfaces/Device.vala',
    'src/Services/DBusInterfaces/Properties.vala',
    'src/Services/DBusInterfaces/Screen.vala',
    'src/Services/DBusInterfaces/UPower.vala',
    'src/Services/ProcessMonitor/Monitor.vala',
    'src/Services/ProcessMonitor/Process.vala',
    'src/Widgets/AppList.vala',
    'src/Widgets/DeviceList.vala',
    'src/Widgets/DisplayWidget.vala',
    'src/Widgets/PopoverWidget.vala',
    'src/Widgets/ScreenBrightness.vala',
    config_in,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('libbamf3'),
        dependency('libgtop-2.0'),
        dependency('libudev'),
        wingpanel_dep,
        meson.get_compiler('vala').find_library('posix')
    ],
    install: true,
    install_dir : wingpanel_dep.get_pkgconfig_variable('indicatorsdir')
)

install_data(
    'schemas/org.pantheon.desktop.wingpanel.indicators.power.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

subdir('po')

meson.add_install_script('meson/post_install.py')
