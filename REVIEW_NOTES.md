# Itens que exigem revisão técnica

Estes arquivos foram incluídos porque existem na instalação customizada atual, mas estão em locais que merecem migração futura.

## Alterações diretas no core do CKAN

- `rootfs/usr/lib/ckan/ckan/ckan/public/base/images/ckan-logo.png`
- `rootfs/usr/lib/ckan/ckan/ckan/templates/home/snippets/promoted.html`
- `rootfs/usr/lib/ckan/ckan/ckan/templates/package/snippets/package_basic_fields.html`

Recomendação:
migrar essas alterações para `/etc/ckan/custom/templates/` ou para uma extensão própria, evitando editar o core do CKAN.

## Customização dentro de dependência externa

- `rootfs/usr/lib/ckan/venv/src/ckanext-scheming/ckanext/scheming/scheming_presets_custom.json`

Recomendação:
mover esse preset custom para `/etc/ckan/schemas/`, `/etc/ckan/custom/` ou uma extensão própria, e ajustar `ckan.ini`.
