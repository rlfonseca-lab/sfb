# CKAN SFB Custom

Repositório local da camada de customização do CKAN SFB, extraída por comparação entre:

- instalação customizada atual;
- instalação vanilla CKAN 2.10.7 em Ubuntu 24.04 LTS.

## Estrutura

- `rootfs/`: arquivos customizados espelhados a partir da raiz do servidor.
- `manifests/`: relatórios da comparação e listas de inclusão/exclusão.
- `requirements-custom.txt`: dependências externas que devem ser instaladas, mas não foram copiadas inteiras.
- `REVIEW_NOTES.md`: arquivos incluídos que exigem revisão/migração futura.
- `rootfs/etc/ckan/ckan.ini.example`: versão sanitizada do `ckan.ini`.

## Arquivos não versionados

Este repositório não deve conter:

- senhas reais;
- tokens;
- certificados privados;
- uploads;
- dumps de banco;
- índice Solr;
- logs;
- backups `.bak`/`.bkp`;
- arquivos gerados por `pip install -e`, como `*.egg-info`;
- arquivos `.mo`, que devem ser gerados a partir dos `.po`.

## Atenção

O `ckan.ini` real foi excluído. Use apenas `ckan.ini.example` como referência e preencha os segredos no servidor.
