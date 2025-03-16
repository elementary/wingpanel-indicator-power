project(
    'power',
    'vala', 'c',
    version: '8.0.2',
    meson_version: '>=0.58.0'
)

gettext_name = meson.project_name() + '-indicator'
gnome = import('gnome')
i18n = import('i18n')

prefix = get_option('prefix')
datadir = prefix / get_option('datadir')
libdir = prefix / get_option('libdir')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(gettext_name), language:'c')
add_project_arguments(['--vapidir', meson.current_source_dir() / 'vapi'], language: 'vala')
add_project_arguments('-DG_LOG_DOMAIN="io.elementary.wingpanel.power"', language:'c')

vapi_dir = meson.current_source_dir() / 'vapi'

indicator_resources = gnome.compile_resources (
    'indicator_resources',
    'data' / 'icons.gresource.xml',
    source_dir: 'data'
)

subdir('data')
subdir('po')
subdir('src')

gnome.post_install(glib_compile_schemas: true)
