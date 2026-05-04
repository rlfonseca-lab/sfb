# Instalação do CKAN SFB em Docker

Este repositório contém um instalador único para subir o CKAN SFB em containers Docker e aplicar a customização do projeto SFB.

O processo instala e configura:

- CKAN 2.10.7
- PostgreSQL
- Solr
- Redis
- Nginx
- Certbot/HTTPS
- Firewall UFW
- Extensões customizadas do SFB
- Tema, templates, traduções e configurações específicas do projeto

O script principal é:

```text
install_ckan_sfb_docker_full.sh
```

O arquivo de variáveis não sensíveis é:

```text
install_ckan_sfb_docker_full.vars
```

O arquivo de segredos editável é:

```text
install_ckan_sfb_docker_full.secrets
```

Os três arquivos devem ficar na mesma pasta. O script **não recebe parâmetros** e procura automaticamente os arquivos `.vars` e `.secrets` no mesmo diretório onde o `.sh` está.

---

## 0. Resumo rápido da instalação

Fluxo completo:

```text
1. Criar uma VM Ubuntu 24.04 LTS
2. Apontar o DNS do domínio para o IP da VM
3. Clonar este repositório
4. Editar install_ckan_sfb_docker_full.vars
5. Editar install_ckan_sfb_docker_full.secrets
6. Dar permissão de execução ao script
7. Rodar sudo ./install_ckan_sfb_docker_full.sh
8. Acessar https://SEU_DOMINIO
9. Entrar com o usuário administrador definido no .vars e no .secrets
```

Comandos principais:

```bash
cd /root
git clone https://github.com/rlfonseca-lab/sfb.git
cd sfb
nano install_ckan_sfb_docker_full.vars # Preencha os parâmetros gerais de instalação
nano install_ckan_sfb_docker_full.secrets # Preencha as senhas e outros parâmetros sensíveis de instalação
chmod 700 install_ckan_sfb_docker_full.sh
chmod 644 install_ckan_sfb_docker_full.vars
chmod 600 install_ckan_sfb_docker_full.secrets
sudo ./install_ckan_sfb_docker_full.sho
```

---

## 1. Quando usar este instalador

Use este instalador para uma instalação nova do CKAN SFB em uma máquina limpa.

Ele é recomendado para:

- VM nova
- ambiente de homologação
- ambiente de produção recém-criado
- reinstalação completa do CKAN SFB em Docker

Evite rodar este script diretamente em um servidor CKAN já em uso, com dados reais, sem antes fazer backup completo.

O script instala e altera serviços importantes do servidor, incluindo Docker, containers de PostgreSQL, Solr, Redis, CKAN, Nginx, Certbot e regras de firewall.

---

## 2. Requisitos mínimos

### Servidor

Recomendado:

- Ubuntu 24.04 LTS
- 2 vCPU
- 4 GB de RAM
- 25 GB de disco ou mais
- acesso SSH com usuário `root` ou usuário com `sudo`

Para produção, recomenda-se pelo menos:

- 2 vCPU
- 4 GB a 8 GB de RAM
- 40 GB de disco ou mais

### Domínio

Para instalação com HTTPS, o domínio precisa apontar para o IP público do servidor antes da execução do script.

Exemplo:

```text
custom.ckan.exemplo.br -> IP_PUBLICO_DA_VM
```

Se o domínio ainda não estiver apontando corretamente, o Certbot não conseguirá emitir o certificado HTTPS.

---

## 3. Baixar o repositório no servidor

Acesse a VM via SSH e clone este repositório.

```bash

cd /root
git clone <URL_DO_REPOSITORIO>
cd <PASTA_DO_REPOSITORIO>

```

Exemplo:

```bash

cd /root
git clone https://github.com/usuario/repositorio_sfb.git
cd repositorio_sfb

```

---

## 4. Conferir os arquivos do instalador

Dentro da pasta do repositório, confira se os três arquivos existem:

```bash

ls -lh \
  install_ckan_sfb_docker_full.sh \
  install_ckan_sfb_docker_full.vars \
  install_ckan_sfb_docker_full.secrets

```

Resultado esperado:

```text
install_ckan_sfb_docker_full.sh
install_ckan_sfb_docker_full.vars
install_ckan_sfb_docker_full.secrets
```

Também é importante confirmar que o repositório contém a pasta `rootfs`, pois é dela que vêm as customizações do SFB.

```bash

ls -ld rootfs
find rootfs -maxdepth 3 -type d | sort | sed -n '1,80p'

```

---

## 5. Entender os três arquivos principais

### `install_ckan_sfb_docker_full.sh`

É o instalador. Ele:

- instala Docker e Docker Compose, se necessário;
- baixa ou atualiza o repositório de customização SFB;
- gera os arquivos Docker necessários;
- cria os containers;
- configura Nginx e HTTPS;
- valida CKAN, plugins, schema e API.

O script deve ser executado sem parâmetros:

```bash

sudo ./install_ckan_sfb_docker_full.sh

```

### `install_ckan_sfb_docker_full.vars`

Guarda configurações não sensíveis, como domínio, imagens Docker, caminhos, nome do banco, usuário do banco, plugins e opções de comportamento.

Ele **não deve conter senhas, tokens ou chaves reais**.

### `install_ckan_sfb_docker_full.secrets`

Guarda os segredos da instalação.

Esse arquivo vai junto no Git como modelo editável para o cliente, mas no repositório ele deve conter apenas placeholders. Antes de rodar o instalador na VM, troque os valores de exemplo por senhas reais.

---

## 6. Editar o arquivo `.vars`

Antes de rodar a instalação, edite o arquivo de variáveis:

```bash

nano install_ckan_sfb_docker_full.vars

```

Atenção especial para estes campos:

```bash
DOMAIN="custom.ckan.exemplo.br"
ENABLE_HTTPS="true"
CERTBOT_EMAIL="email@exemplo.br"
EXPECTED_DNS_IP="IP_PUBLICO_DA_VM"
```

Confira também o diretório onde o projeto Docker será criado:

```bash
INSTALL_DIR="/opt/ckan-sfb-docker"
```

E confira o repositório Git usado para aplicar a customização:

```bash
GIT_REPO_URL="https://github.com/usuario/repositorio_sfb.git"
GIT_BRANCH="main"
```

---

## 7. Editar o arquivo `.secrets`

Agora edite o arquivo de segredos:

```bash

nano install_ckan_sfb_docker_full.secrets

```

Troque obrigatoriamente os placeholders:

```bash
CKAN_DB_PASSWORD="TROQUE_ESTA_SENHA_DO_BANCO"
CKAN_SYSADMIN_PASSWORD="TROQUE_ESTA_SENHA_DO_SYSADMIN"
```

Por exemplo:

```bash
CKAN_DB_PASSWORD="uma_senha_forte_para_o_banco"
CKAN_SYSADMIN_PASSWORD="uma_senha_forte_para_o_admin"
```

Atenção: não deixe senhas reais salvas no Git. O arquivo `.secrets` entregue no repositório deve funcionar como modelo. A versão editada com senhas reais deve ficar apenas na VM de instalação.

---

## 8. Principais variáveis do `.vars`

### Execução e firewall

| Variável | Para que serve |
|---|---|
| `RUN_APT_UPGRADE` | Define se o script fará `apt upgrade` antes da instalação |
| `ENABLE_UFW` | Ativa ou desativa configuração de firewall |
| `SSH_PORT` | Porta SSH que será liberada no firewall |
| `FORCE_OVERWRITE_PROJECT_DIR` | Permite sobrescrever arquivos do kit em `INSTALL_DIR` |

### Diretórios

| Variável | Para que serve |
|---|---|
| `INSTALL_DIR` | Diretório do projeto Docker gerado pelo instalador |
| `LOG_DIR` | Diretório dos logs da instalação |
| `BACKUP_ROOT` | Diretório base dos backups |

### Domínio e HTTPS

| Variável | Para que serve |
|---|---|
| `DOMAIN` | Domínio público do CKAN |
| `ENABLE_HTTPS` | Ativa ou desativa HTTPS com Certbot |
| `CERTBOT_EMAIL` | E-mail usado no Let's Encrypt |
| `EXPECTED_DNS_IP` | IP esperado no DNS, usado para conferência informativa |

### CKAN

| Variável | Para que serve |
|---|---|
| `CKAN_VERSION` | Versão do CKAN exigida pelo projeto |
| `CKAN_SITE_ID` | Identificador interno do site CKAN |
| `CKAN_SITE_TITLE` | Título do portal |
| `CKAN_INTERNAL_PORT` | Porta interna do container CKAN |
| `PUBLISH_CKAN_LOCAL_PORT` | Publica a porta do CKAN apenas no localhost do host |
| `CKAN_LOCAL_BIND` | Bind local para debug, normalmente `127.0.0.1:5000` |

Por segurança, mantenha a porta local presa em `127.0.0.1`:

```bash
PUBLISH_CKAN_LOCAL_PORT="true"
CKAN_LOCAL_BIND="127.0.0.1:5000"
```

Assim, o CKAN não fica exposto diretamente na internet. O acesso público será feito pelo Nginx.

### Upload de arquivos

| Variável | Para que serve |
|---|---|
| `CKAN_MAX_RESOURCE_SIZE_MB` | Tamanho máximo de upload de recursos |
| `CKAN_MAX_IMAGE_SIZE_MB` | Tamanho máximo de imagens |
| `CKAN_RESOURCE_PROXY_MAX_FILE_SIZE_BYTES` | Tamanho máximo para proxy/preview de recursos |
| `NGINX_CLIENT_MAX_BODY_SIZE` | Limite de upload no Nginx |

Exemplo:

```bash
CKAN_MAX_RESOURCE_SIZE_MB="300"
CKAN_RESOURCE_PROXY_MAX_FILE_SIZE_BYTES="314572800"
NGINX_CLIENT_MAX_BODY_SIZE="300M"
```

### Banco de dados

| Variável | Para que serve |
|---|---|
| `POSTGRES_IMAGE` | Imagem Docker do PostgreSQL |
| `CKAN_DB_HOST` | Host interno do banco na rede Docker |
| `CKAN_DB_PORT` | Porta interna do banco |
| `CKAN_DB_NAME` | Nome do banco PostgreSQL do CKAN |
| `CKAN_DB_USER` | Usuário PostgreSQL do CKAN |

A senha do banco não fica no `.vars`. Ela fica no `.secrets`.

### Usuário administrador do CKAN

| Variável | Para que serve |
|---|---|
| `CKAN_SYSADMIN_NAME` | Nome do usuário administrador |
| `CKAN_SYSADMIN_EMAIL` | E-mail do administrador |

A senha do administrador não fica no `.vars`. Ela fica no `.secrets`.

### Imagens Docker

| Variável | Para que serve |
|---|---|
| `POSTGRES_IMAGE` | Imagem do PostgreSQL |
| `REDIS_IMAGE` | Imagem do Redis |
| `SOLR_IMAGE` | Imagem do Solr |
| `NGINX_IMAGE` | Imagem do Nginx |
| `CERTBOT_IMAGE` | Imagem do Certbot |

### Customização SFB

| Variável | Para que serve |
|---|---|
| `GIT_REPO_URL` | Repositório Git da customização SFB |
| `GIT_BRANCH` | Branch usada na instalação |
| `SFB_EXTS` | Lista das extensões SFB esperadas no `rootfs` |
| `SFB_IMPORT_MODULES` | Módulos Python usados na validação final |
| `CKAN_PLUGINS` | Plugins habilitados no CKAN |

### Scheming e idioma

| Variável | Para que serve |
|---|---|
| `SCHEMING_PRESETS` | Presets usados pelo `ckanext-scheming` |
| `SCHEMING_DATASET_SCHEMAS` | Caminho do schema YAML do dataset |
| `SCHEMING_DATASET_FALLBACK` | Ativa ou desativa fallback do schema |
| `CKAN_LOCALE_DEFAULT` | Idioma padrão |
| `CKAN_LOCALES_OFFERED` | Idiomas oferecidos |
| `CKAN_I18N_EXTRA_DIRECTORY` | Diretório de traduções extras |

### Reindexação

| Variável | Para que serve |
|---|---|
| `REINDEX_SEARCH` | Define se o índice de busca será reconstruído ao final |

Para instalação nova, pode ficar assim:

```bash
REINDEX_SEARCH="false"
```

Para reinstalação ou mudança de campos/facets, pode ser útil usar:

```bash
REINDEX_SEARCH="true"
```

---

## 9. Principais variáveis do `.secrets`

| Variável | Para que serve |
|---|---|
| `CKAN_DB_PASSWORD` | Senha do usuário PostgreSQL do CKAN |
| `CKAN_SYSADMIN_PASSWORD` | Senha inicial do usuário administrador do CKAN |
| `GIT_TOKEN` | Reservado para uso futuro, não usado na versão atual |
| `API_TOKEN` | Reservado para uso futuro, não usado na versão atual |
| `SECRET_KEY` | Reservado para uso futuro, não usado na versão atual |

Na versão atual, os segredos obrigatórios são:

```bash
CKAN_DB_PASSWORD="..."
CKAN_SYSADMIN_PASSWORD="..."
```

O instalador para com erro se essas variáveis estiverem vazias ou ainda estiverem com os placeholders originais.

---

## 10. Como o `rootfs` é usado

O repositório de customização deve conter uma pasta chamada:

```text
rootfs
```

O instalador usa essa pasta de duas formas:

1. copia o conteúdo de `rootfs/` para dentro da imagem Docker do CKAN;
2. copia `rootfs/etc/ckan/` para o volume persistente Docker `ckan-config`.

Esse segundo ponto é importante porque o container monta o volume:

```text
/opt/ckan-sfb-docker/ckan-config -> /etc/ckan
```

Então os arquivos de schema, templates e assets customizados precisam estar também no volume persistente.

O instalador valida a presença de pelo menos:

```text
rootfs/etc/ckan/schemas/sfb_dataset.yaml
rootfs/etc/ckan/custom/templates
rootfs/etc/ckan/custom/public
```

Também espera encontrar as extensões SFB dentro de caminhos compatíveis com:

```text
rootfs/usr/lib/ckan/venv/src/ckanext-sfb_access
rootfs/usr/lib/ckan/venv/src/ckanext-sfb_facets_multi
rootfs/usr/lib/ckan/venv/src/ckanext-sfb_geo_facet
rootfs/usr/lib/ckan/venv/src/ckanext-sfb_group_sync
rootfs/usr/lib/ckan/venv/src/ckanext-sfbdraftsearch
rootfs/usr/lib/ckan/venv/src/ckanext-sfbgroups
```

---

## 11. Conferir DNS antes de instalar

Antes de ativar HTTPS, confira se o domínio aponta para o IP da VM.

```bash

dig +short <SEU_DOMINIO>

```

Exemplo:

```bash

dig +short custom.ckan.exemplo.br

```

O resultado deve mostrar o IP público da VM.

Se não mostrar, ajuste o DNS antes de continuar.

---

## 12. Dar permissão de execução ao script

Depois de editar o `.vars` e o `.secrets`, ajuste as permissões:

```bash

chmod 700 install_ckan_sfb_docker_full.sh
chmod 644 install_ckan_sfb_docker_full.vars
chmod 600 install_ckan_sfb_docker_full.secrets

```

---

## 13. Rodar a instalação

Execute o script como `root` ou com `sudo`:

```bash

sudo ./install_ckan_sfb_docker_full.sh

```

O script exibirá várias etapas no terminal.

Cada etapa aparece neste formato:

```text
----------[1/26]---------- INÍCIO, LOG E VARIÁVEIS ----------
```

Isso ajuda a saber em qual ponto da instalação o processo está.

Atenção: este script não aceita parâmetros. Se você tentar passar um `.vars` manualmente, ele encerrará com erro.

---

## 14. O que o script faz

De forma resumida, o instalador executa estas ações:

1. Localiza automaticamente o `.vars` e o `.secrets` no diretório do script
2. Cria arquivo de log
3. Cria pasta de backup
4. Valida variáveis obrigatórias
5. Valida segredos obrigatórios
6. Atualiza a lista de pacotes do sistema
7. Instala dependências básicas
8. Instala Docker e Docker Compose plugin
9. Confere DNS do domínio
10. Cria a estrutura do projeto Docker em `INSTALL_DIR`
11. Clona ou atualiza o repositório de customização SFB
12. Valida a existência de `rootfs`
13. Semeia `rootfs/etc/ckan` no volume persistente `ckan-config`
14. Baixa o schema Solr compatível com CKAN 2.10.7
15. Cria arquivos locais de segredos para o Docker
16. Gera `.env` sem gravar senhas diretamente
17. Gera Dockerfile do CKAN
18. Gera entrypoint do CKAN
19. Gera Dockerfile do Solr
20. Gera configuração inicial HTTP do Nginx
21. Gera `docker-compose.yml`
22. Configura firewall local
23. Faz build das imagens
24. Sobe os containers
25. Ativa HTTPS com Certbot, se habilitado
26. Valida configuração, imports, schema, API, domínio, containers e portas

---

## 15. Logs, backups e arquivos gerados

O script grava logs em:

```text
/var/log/ckan-sfb-docker-install/
```

Também cria backups em:

```text
/root/ckan-sfb-docker-backups/
```

O projeto Docker é criado em:

```text
/opt/ckan-sfb-docker
```

Dentro dele ficam arquivos como:

```text
/opt/ckan-sfb-docker/docker-compose.yml
/opt/ckan-sfb-docker/.env
/opt/ckan-sfb-docker/ckan-config/
/opt/ckan-sfb-docker/secrets/
/opt/ckan-sfb-docker/nginx/default.conf
/opt/ckan-sfb-docker/letsencrypt/
```

Para listar os logs:

```bash

ls -lh /var/log/ckan-sfb-docker-install/

```

Para acompanhar o log mais recente:

```bash

tail -f "$(ls -t /var/log/ckan-sfb-docker-install/*.log | head -n 1)"

```

Para listar backups:

```bash

ls -lh /root/ckan-sfb-docker-backups/

```

---

## 16. Validação após a instalação

Ao final, acesse no navegador:

```text
https://SEU_DOMINIO
```

Exemplo:

```text
https://custom.ckan.exemplo.br
```

Também é possível validar pelo terminal.

### Testar API via Nginx local

```bash

curl -fsS -H "Host: <SEU_DOMINIO>" http://127.0.0.1/api/3/action/status_show | python3 -m json.tool

```

Exemplo:

```bash

curl -fsS -H "Host: custom.ckan.exemplo.br" http://127.0.0.1/api/3/action/status_show | python3 -m json.tool

```

### Testar domínio HTTPS localmente

```bash

curl -I -k --resolve <SEU_DOMINIO>:443:127.0.0.1 https://<SEU_DOMINIO>/
curl -I -k --resolve <SEU_DOMINIO>:443:127.0.0.1 https://<SEU_DOMINIO>/dataset/

```

Exemplo:

```bash

curl -I -k --resolve custom.ckan.exemplo.br:443:127.0.0.1 https://custom.ckan.exemplo.br/
curl -I -k --resolve custom.ckan.exemplo.br:443:127.0.0.1 https://custom.ckan.exemplo.br/dataset/

```

### Conferir containers

```bash

cd /opt/ckan-sfb-docker
docker compose ps

```

### Conferir logs dos containers

```bash

cd /opt/ckan-sfb-docker
docker compose logs --tail=120 ckan
docker compose logs --tail=120 nginx
docker compose logs --tail=120 db
docker compose logs --tail=120 solr

```

### Conferir portas abertas

```bash

ss -lntp | grep -E ':(80|443|5000|8983|5432|6379)\b' || true

```

O esperado é:

- portas `80` e `443` acessíveis publicamente pelo Nginx;
- CKAN em `127.0.0.1:5000`, se `PUBLISH_CKAN_LOCAL_PORT="true"`;
- PostgreSQL, Redis e Solr sem portas públicas expostas no host;
- banco, Redis e Solr acessíveis apenas pela rede interna Docker.

---

## 17. Acessar como administrador

Use os dados definidos nos arquivos:

```bash
# install_ckan_sfb_docker_full.vars
CKAN_SYSADMIN_NAME="..."
CKAN_SYSADMIN_EMAIL="..."

# install_ckan_sfb_docker_full.secrets
CKAN_SYSADMIN_PASSWORD="..."
```

Depois acesse:

```text
https://SEU_DOMINIO/user/login
```

---

## 18. Comandos úteis depois da instalação

### Entrar na pasta do projeto Docker

```bash

cd /opt/ckan-sfb-docker
pwd

```

### Ver containers

```bash

cd /opt/ckan-sfb-docker
docker compose ps

```

### Reiniciar CKAN

```bash

cd /opt/ckan-sfb-docker
docker compose restart ckan

```

### Reiniciar Nginx

```bash

cd /opt/ckan-sfb-docker
docker compose restart nginx

```

### Validar configuração do CKAN

```bash

cd /opt/ckan-sfb-docker
docker compose exec -T ckan ckan -c /etc/ckan/ckan.ini config validate

```

### Reindexar busca

```bash

cd /opt/ckan-sfb-docker
docker compose exec -T ckan ckan -c /etc/ckan/ckan.ini search-index rebuild

```

---

## 19. Problemas comuns

### Erro: arquivo `.vars` não encontrado

Mensagem parecida:

```text
ERRO: arquivo de variáveis não encontrado
```

Causa provável:

- o arquivo `.vars` não está na mesma pasta do `.sh`;
- o nome do arquivo está diferente de `install_ckan_sfb_docker_full.vars`;
- o pacote foi copiado incompleto.

Conferir:

```bash

pwd
ls -lh \
  install_ckan_sfb_docker_full.sh \
  install_ckan_sfb_docker_full.vars \
  install_ckan_sfb_docker_full.secrets

```

---

### Erro: arquivo `.secrets` não encontrado

Mensagem parecida:

```text
ERRO: arquivo de segredos não encontrado
```

Causa provável:

- o arquivo `.secrets` não está na mesma pasta do `.sh`;
- o nome do arquivo está diferente de `install_ckan_sfb_docker_full.secrets`.

Conferir:

```bash

ls -lh install_ckan_sfb_docker_full.secrets

```

---

### Erro: placeholder de senha não trocado

Mensagem parecida:

```text
Troque CKAN_DB_PASSWORD no arquivo .secrets antes de rodar.
```

Ou:

```text
Troque CKAN_SYSADMIN_PASSWORD no arquivo .secrets antes de rodar.
```

Abra o arquivo `.secrets` e troque os valores:

```bash

nano install_ckan_sfb_docker_full.secrets

```

---

### Erro no Certbot ou HTTPS

Causas comuns:

- domínio ainda não aponta para o IP da VM;
- porta 80 bloqueada;
- porta 443 bloqueada;
- DNS ainda não propagou;
- `CERTBOT_EMAIL` vazio, caso você queira registrar com e-mail.

Conferir DNS:

```bash

dig +short <SEU_DOMINIO>

```

Conferir firewall:

```bash

ufw status verbose

```

Conferir logs do Nginx e Certbot:

```bash

cd /opt/ckan-sfb-docker
docker compose logs --tail=120 nginx
docker compose logs --tail=120 certbot

```

---

### CKAN não responde

Conferir containers:

```bash

cd /opt/ckan-sfb-docker
docker compose ps
docker compose logs --tail=180 ckan

```

---

### Solr não responde

Conferir o container Solr:

```bash

cd /opt/ckan-sfb-docker
docker compose ps solr
docker compose logs --tail=180 solr

```

---

### Banco não responde

Conferir o container PostgreSQL:

```bash

cd /opt/ckan-sfb-docker
docker compose ps db
docker compose logs --tail=180 db

```

---

### Nginx não sobe

Testar a configuração dentro do container:

```bash

cd /opt/ckan-sfb-docker
docker compose exec -T nginx nginx -t
docker compose logs --tail=180 nginx

```

---

### Erro 413 ao enviar arquivo

Esse erro indica que o arquivo enviado é maior que o limite aceito pelo Nginx ou pelo CKAN.

Revise no `.vars`:

```bash
CKAN_MAX_RESOURCE_SIZE_MB="300"
CKAN_RESOURCE_PROXY_MAX_FILE_SIZE_BYTES="314572800"
NGINX_CLIENT_MAX_BODY_SIZE="300M"
```

Depois rode novamente o instalador ou ajuste manualmente os arquivos gerados em `/opt/ckan-sfb-docker`.

---

### Erro informando que `rootfs/etc/ckan` não existe

Causa provável:

- o repositório informado em `GIT_REPO_URL` não contém a estrutura esperada;
- a branch em `GIT_BRANCH` está errada;
- o pacote de customização foi reorganizado.

Conferir:

```bash

cd /opt/ckan-sfb-docker/repo/sfb
pwd
git status --short
git log --oneline -1
find rootfs/etc/ckan -maxdepth 3 -type d | sort | sed -n '1,120p'

```

---

## 20. Reexecutar o instalador

O script pode ser executado novamente para reaplicar a instalação/customização.

Antes de reexecutar, confira esta variável no `.vars`:

```bash
FORCE_OVERWRITE_PROJECT_DIR="true"
```

Atenção:

- essa opção permite sobrescrever arquivos do kit Docker em `INSTALL_DIR`;
- ela não apaga volumes Docker por padrão;
- os dados persistentes ficam em volumes Docker, como `db_data`, `solr_data`, `redis_data` e `ckan_storage`;
- mesmo assim, em ambiente com dados reais, faça backup antes de reexecutar.

Para reexecutar:

```bash

sudo ./install_ckan_sfb_docker_full.sh

```

---

## 21. Atualizar customizações a partir do Git

O script baixa a customização usando:

```bash
GIT_REPO_URL="..."
GIT_BRANCH="..."
```

Para aplicar uma versão nova da customização:

1. Atualize o repositório Git de customização.
2. Confira a branch no `.vars`.
3. Rode novamente o instalador.

```bash

sudo ./install_ckan_sfb_docker_full.sh

```

## Manifesto dos arquivos do rootfs

A lista dos arquivos incluídos no diretório `rootfs/`, com path e função específica de cada arquivo na customização CKAN SFB, está disponível em:

[`docs/MANIFESTO_ROOTFS.md`](docs/MANIFESTO_ROOTFS.md)
