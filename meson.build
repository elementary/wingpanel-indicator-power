project('power', 'vala', 'c')

gettext_name = meson.project_name() + '-indicator'
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(gettext_name), language:'c')
add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], 
                      language: 'vala')

subdir('data')
subdir('po')
subdir('src')

meson.add_install_script('meson/post_install.py')
