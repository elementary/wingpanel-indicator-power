i18n.merge_file(
    input: 'power.appdata.xml.in',
    output: 'io.elementary.wingpanel.power.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'xml',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo'),
)

install_data(
    'io.elementary.desktop.wingpanel.power.gschema.xml',
    install_dir: join_paths(datadir, 'glib-2.0', 'schemas')
)
