#!/usr/bin/env bash
set -Eeuo pipefail
umask 022

# ============================================================
# SCRIPT ÚNICO: CKAN SFB FULL EM DOCKER
# CKAN 2.10.7 EXATO + PostgreSQL + Redis + Solr + Nginx + Certbot
# ============================================================

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
SCRIPT_BASE="install_ckan_sfb_docker_full"
VARS_FILE="${SCRIPT_DIR}/install_ckan_sfb_docker_full.vars"
SECRETS_FILE="${SCRIPT_DIR}/install_ckan_sfb_docker_full.secrets"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERRO: rode este script como root. Exemplo: sudo ./install_ckan_sfb_docker_full.sh"
  exit 1
fi

if [[ "$#" -gt 0 ]]; then
  echo "ERRO: este script não aceita parâmetros."
  echo "Coloque os arquivos abaixo no mesmo diretório do .sh:"
  echo "  - install_ckan_sfb_docker_full.vars"
  echo "  - install_ckan_sfb_docker_full.secrets"
  exit 1
fi

if [[ ! -f "$VARS_FILE" ]]; then
  echo "ERRO: arquivo de variáveis não encontrado: $VARS_FILE"
  echo "Esperado: ${SCRIPT_DIR}/install_ckan_sfb_docker_full.vars"
  exit 1
fi

if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "ERRO: arquivo de segredos não encontrado: $SECRETS_FILE"
  echo "Esperado: ${SCRIPT_DIR}/install_ckan_sfb_docker_full.secrets"
  exit 1
fi

chmod 600 "$SECRETS_FILE" 2>/dev/null || true

# shellcheck disable=SC1090
source "$VARS_FILE"
# shellcheck disable=SC1090
source "$SECRETS_FILE"

STAMP="$(date +%F_%H-%M-%S)"
LOG_DIR="${LOG_DIR:-/var/log/ckan-sfb-docker-install}"
BACKUP_ROOT="${BACKUP_ROOT:-/root/ckan-sfb-docker-backups}"
LOG_FILE="$LOG_DIR/${SCRIPT_BASE}_${STAMP}.log"
BACKUP_DIR="$BACKUP_ROOT/backup_${STAMP}"

PROJECT_DIR="$INSTALL_DIR"
REPO_DIR="$PROJECT_DIR/repo"
REPO_SFB_DIR="$REPO_DIR/sfb"
CKAN_BUILD_DIR="$PROJECT_DIR/ckan"
SOLR_BUILD_DIR="$PROJECT_DIR/solr"
NGINX_DIR="$PROJECT_DIR/nginx"
CERTBOT_WWW_DIR="$PROJECT_DIR/certbot-www"
LETSENCRYPT_DIR="$PROJECT_DIR/letsencrypt"
CKAN_CONFIG_DIR="$PROJECT_DIR/ckan-config"
PROJECT_SECRETS_DIR="$PROJECT_DIR/secrets"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"
ENV_FILE="$PROJECT_DIR/.env"

SITE_SCHEME="http"
if [[ "${ENABLE_HTTPS,,}" == "true" ]]; then
  SITE_SCHEME="https"
fi
SITE_URL="${SITE_SCHEME}://${DOMAIN}"

mkdir -p "$LOG_DIR" "$BACKUP_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

trap 'rc=$?; echo; echo "ERRO: falha na linha ${LINENO}. Código: ${rc}"; echo "Log: ${LOG_FILE}"; exit ${rc}' ERR

TOTAL=26

step() {
  echo
  echo "----------[$1/$TOTAL]---------- $2 ----------"
}

fail() {
  echo
  echo "ERRO: $*"
  echo "Log: $LOG_FILE"
  exit 1
}

require_var() {
  local name="$1"
  local value="${!name:-}"
  [[ -n "$value" ]] || fail "variável obrigatória vazia ou ausente: $name"
}

require_secret_var() {
  local name="$1"
  local value="${!name:-}"
  [[ -n "$value" ]] || fail "segredo obrigatório vazio ou ausente no arquivo .secrets: $name"
}

write_one_secret_file() {
  local var_name="$1"
  local target_name="$2"
  local target_file="$PROJECT_SECRETS_DIR/$target_name"

  mkdir -p "$PROJECT_SECRETS_DIR"
  local old_umask
  old_umask="$(umask)"
  umask 077
  printf '%s\n' "${!var_name}" > "$target_file"
  umask "$old_umask"
  chmod 644 "$target_file"
  echo "OK: segredo preparado para Docker: $target_name"
}

write_secret_files() {
  mkdir -p "$PROJECT_SECRETS_DIR"
  chmod 700 "$PROJECT_SECRETS_DIR"
  write_one_secret_file "CKAN_DB_PASSWORD" "ckan_db_password"
  write_one_secret_file "CKAN_SYSADMIN_PASSWORD" "ckan_sysadmin_password"
}

backup_file() {
  local f="$1"
  if [[ -e "$f" ]]; then
    local bak="${f}$(date +%F_%H-%M-%S).bak"
    cp -a "$f" "$bak"
    echo "Backup: $bak"
  fi
}

backup_project_file() {
  local f="$1"
  local label
  if [[ -e "$f" ]]; then
    label="$(echo "$f" | sed 's#/#_#g' | sed 's#^_##')"
    cp -a "$f" "$BACKUP_DIR/${label}.${STAMP}.bak"
    echo "Backup em: $BACKUP_DIR/${label}.${STAMP}.bak"
  fi
}

install_docker() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    echo "OK: Docker e Docker Compose plugin já instalados."
    docker --version
    docker compose version
    return
  fi

  echo "Instalando Docker Engine e Docker Compose plugin..."
  apt update -y
  apt install -y ca-certificates curl gnupg lsb-release

  install -m 0755 -d /etc/apt/keyrings

  if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
  fi

  local codename
  codename="$(. /etc/os-release && echo "${VERSION_CODENAME}")"

  cat >/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${codename} stable
EOF

  apt update -y
  apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable --now docker

  docker --version
  docker compose version
}

write_env_file() {
  cat > "$ENV_FILE" <<EOF
CKAN_VERSION=${CKAN_VERSION}
CKAN_GIT_URL=${CKAN_GIT_URL}
PYTHON_VERSION=${PYTHON_VERSION}

DOMAIN=${DOMAIN}
SITE_URL=${SITE_URL}

CKAN_SITE_ID=${CKAN_SITE_ID}
CKAN_SITE_TITLE=${CKAN_SITE_TITLE}
CKAN_INTERNAL_PORT=${CKAN_INTERNAL_PORT}
CKAN_INI=${CKAN_INI}
CKAN_STORAGE_PATH=${CKAN_STORAGE_PATH}
CKAN_UPLOADS_ENABLED=${CKAN_UPLOADS_ENABLED}
CKAN_MAX_RESOURCE_SIZE_MB=${CKAN_MAX_RESOURCE_SIZE_MB}
CKAN_MAX_IMAGE_SIZE_MB=${CKAN_MAX_IMAGE_SIZE_MB}
CKAN_RESOURCE_PROXY_MAX_FILE_SIZE_BYTES=${CKAN_RESOURCE_PROXY_MAX_FILE_SIZE_BYTES}

CKAN_SYSADMIN_NAME=${CKAN_SYSADMIN_NAME}
CKAN_SYSADMIN_EMAIL=${CKAN_SYSADMIN_EMAIL}
CKAN_SYSADMIN_PASSWORD_FILE=/run/secrets/ckan_sysadmin_password

CKAN_DB_HOST=${CKAN_DB_HOST}
CKAN_DB_PORT=${CKAN_DB_PORT}
CKAN_DB_NAME=${CKAN_DB_NAME}
CKAN_DB_USER=${CKAN_DB_USER}
CKAN_DB_PASSWORD_FILE=/run/secrets/ckan_db_password

REDIS_HOST=${REDIS_HOST}
REDIS_PORT=${REDIS_PORT}
REDIS_URL=${REDIS_URL}

SOLR_HOST=${SOLR_HOST}
SOLR_PORT=${SOLR_PORT}
SOLR_CORE=${SOLR_CORE}
SOLR_URL=http://${SOLR_HOST}:${SOLR_PORT}/solr/${SOLR_CORE}

CKAN_PLUGINS=${CKAN_PLUGINS}
CKAN_EXTRA_TEMPLATE_PATHS=${CKAN_EXTRA_TEMPLATE_PATHS}
CKAN_EXTRA_PUBLIC_PATHS=${CKAN_EXTRA_PUBLIC_PATHS}
CKAN_THEME=${CKAN_THEME}

SCHEMING_PRESETS=${SCHEMING_PRESETS}
SCHEMING_DATASET_SCHEMAS=${SCHEMING_DATASET_SCHEMAS}
SCHEMING_DATASET_FALLBACK=${SCHEMING_DATASET_FALLBACK}

CKAN_LOCALE_DEFAULT=${CKAN_LOCALE_DEFAULT}
CKAN_LOCALES_OFFERED=${CKAN_LOCALES_OFFERED}
CKAN_LOCALE_ORDER=${CKAN_LOCALE_ORDER}
CKAN_I18N_EXTRA_DIRECTORY=${CKAN_I18N_EXTRA_DIRECTORY}
CKAN_I18N_EXTRA_GETTEXT_DOMAIN=${CKAN_I18N_EXTRA_GETTEXT_DOMAIN}
CKAN_I18N_EXTRA_LOCALES=${CKAN_I18N_EXTRA_LOCALES}

SFB_EXTS=${SFB_EXTS}
SFB_IMPORT_MODULES=${SFB_IMPORT_MODULES}
SCHEMING_GIT_URL=${SCHEMING_GIT_URL}
SCHEMING_GIT_BRANCH=${SCHEMING_GIT_BRANCH}

CLEAR_UI_CUSTOM_CSS=${CLEAR_UI_CUSTOM_CSS}
COMPILE_TRANSLATIONS=${COMPILE_TRANSLATIONS}
REINDEX_SEARCH=${REINDEX_SEARCH}
EOF

  chmod 600 "$ENV_FILE"
}

write_ckan_dockerfile() {
  cat > "$CKAN_BUILD_DIR/Dockerfile" <<'EOF'
ARG PYTHON_VERSION=3.10
FROM python:${PYTHON_VERSION}-slim-bookworm

ARG CKAN_VERSION=ckan-2.10.7
ARG CKAN_GIT_URL=https://github.com/ckan/ckan.git
ARG SCHEMING_GIT_URL=https://github.com/ckan/ckanext-scheming.git
ARG SCHEMING_GIT_BRANCH=master
ARG SFB_EXTS=""

ENV CKAN_INI=/etc/ckan/ckan.ini
ENV CKAN_HOME=/usr/lib/ckan
ENV CKAN_VENV=/usr/lib/ckan/venv
ENV CKAN_SRC=/usr/lib/ckan/ckan
ENV PATH="/usr/lib/ckan/venv/bin:${PATH}"
ENV PYTHONUNBUFFERED=1

USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    gcc \
    g++ \
    gettext \
    postgresql-client \
    netcat-openbsd \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libjpeg-dev \
    libffi-dev \
    libyaml-dev \
    libmagic1 \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash ckan \
  && mkdir -p /usr/lib/ckan /etc/ckan /var/lib/ckan /opt/ckan/extra_translations \
  && chown -R ckan:ckan /usr/lib/ckan /etc/ckan /var/lib/ckan /opt/ckan

USER ckan

RUN python -m venv "$CKAN_VENV" \
  && . "$CKAN_VENV/bin/activate" \
  && pip install --upgrade pip \
  && pip install "setuptools<82" wheel

RUN git clone --branch "$CKAN_VERSION" "$CKAN_GIT_URL" "$CKAN_SRC" \
  && . "$CKAN_VENV/bin/activate" \
  && cd "$CKAN_SRC" \
  && pip install -r requirements.txt \
  && pip install -e '.[requirements]'

RUN mkdir -p "$CKAN_VENV/src" \
  && git clone --branch "$SCHEMING_GIT_BRANCH" "$SCHEMING_GIT_URL" "$CKAN_VENV/src/ckanext-scheming"

USER root

COPY repo/sfb/rootfs/ /

RUN chown -R ckan:ckan /usr/lib/ckan /etc/ckan /var/lib/ckan /opt/ckan || true

USER ckan

RUN . "$CKAN_VENV/bin/activate" \
  && cd "$CKAN_VENV/src/ckanext-scheming" \
  && pip install -e .

RUN . "$CKAN_VENV/bin/activate" \
  && for ext in $SFB_EXTS; do \
      echo "Instalando extensão SFB: $ext"; \
      if [ ! -d "$CKAN_VENV/src/$ext" ]; then \
        echo "ERRO: extensão ausente em $CKAN_VENV/src/$ext"; \
        exit 1; \
      fi; \
      cd "$CKAN_VENV/src/$ext"; \
      pip install -e .; \
    done

USER root

COPY ckan/entrypoint.sh /usr/local/bin/ckan-sfb-entrypoint.sh
RUN chmod +x /usr/local/bin/ckan-sfb-entrypoint.sh \
  && chown -R ckan:ckan /usr/lib/ckan /etc/ckan /var/lib/ckan /opt/ckan || true

USER ckan
WORKDIR /usr/lib/ckan/ckan

EXPOSE 5000

ENTRYPOINT ["/usr/local/bin/ckan-sfb-entrypoint.sh"]
CMD ["serve"]
EOF
}

write_ckan_entrypoint() {
  cat > "$CKAN_BUILD_DIR/entrypoint.sh" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

log() {
  echo
  echo "----------[CKAN CONTAINER]---------- $* ----------"
}

wait_tcp() {
  local host="$1"
  local port="$2"
  local label="$3"
  local max="${4:-90}"

  for i in $(seq 1 "$max"); do
    if nc -z "$host" "$port" >/dev/null 2>&1; then
      echo "OK: $label disponível em $host:$port"
      return 0
    fi
    sleep 1
  done

  echo "ERRO: $label não respondeu em $host:$port após ${max}s"
  exit 1
}

load_secret_var() {
  local var_name="$1"
  local file_var="${var_name}_FILE"
  local secret_file="${!file_var:-}"

  if [[ -n "$secret_file" && -f "$secret_file" ]]; then
    export "$var_name=$(cat "$secret_file")"
  fi

  if [[ -z "${!var_name:-}" ]]; then
    echo "ERRO: segredo obrigatório não carregado no container: $var_name"
    exit 1
  fi

  echo "OK: segredo carregado no container: $var_name"
}

write_ini_settings() {
  python <<'PY'
from pathlib import Path
import os

ini_path = Path(os.environ.get("CKAN_INI", "/etc/ckan/ckan.ini"))
text = ini_path.read_text(errors="replace") if ini_path.exists() else "[app:main]\n"
lines = text.splitlines()

settings = {
    "ckan.site_id": os.environ["CKAN_SITE_ID"],
    "ckan.site_url": os.environ["SITE_URL"],
    "ckan.site_title": os.environ.get("CKAN_SITE_TITLE", "CKAN SFB"),
    "sqlalchemy.url": "postgresql://{u}:{p}@{h}:{port}/{d}".format(
        u=os.environ["CKAN_DB_USER"],
        p=os.environ["CKAN_DB_PASSWORD"],
        h=os.environ["CKAN_DB_HOST"],
        port=os.environ["CKAN_DB_PORT"],
        d=os.environ["CKAN_DB_NAME"],
    ),
    "solr_url": os.environ["SOLR_URL"],
    "ckan.redis.url": os.environ["REDIS_URL"],
    "ckan.storage_path": os.environ["CKAN_STORAGE_PATH"],
    "ckan.uploads_enabled": os.environ["CKAN_UPLOADS_ENABLED"],
    "ckan.max_resource_size": os.environ["CKAN_MAX_RESOURCE_SIZE_MB"],
    "ckan.max_image_size": os.environ["CKAN_MAX_IMAGE_SIZE_MB"],
    "ckan.resource_proxy.max_file_size": os.environ["CKAN_RESOURCE_PROXY_MAX_FILE_SIZE_BYTES"],

    "ckan.plugins": os.environ["CKAN_PLUGINS"],
    "ckan.theme": os.environ["CKAN_THEME"],
    "extra_template_paths": os.environ["CKAN_EXTRA_TEMPLATE_PATHS"],
    "extra_public_paths": os.environ["CKAN_EXTRA_PUBLIC_PATHS"],

    "ckan.locale_default": os.environ["CKAN_LOCALE_DEFAULT"],
    "ckan.locales_offered": os.environ["CKAN_LOCALES_OFFERED"],
    "ckan.locale_order": os.environ["CKAN_LOCALE_ORDER"],
    "ckan.i18n.extra_directory": os.environ["CKAN_I18N_EXTRA_DIRECTORY"],
    "ckan.i18n.extra_gettext_domain": os.environ["CKAN_I18N_EXTRA_GETTEXT_DOMAIN"],
    "ckan.i18n.extra_locales": os.environ["CKAN_I18N_EXTRA_LOCALES"],

    "scheming.presets": os.environ["SCHEMING_PRESETS"],
    "scheming.dataset_schemas": os.environ["SCHEMING_DATASET_SCHEMAS"],
    "scheming.dataset_fallback": os.environ["SCHEMING_DATASET_FALLBACK"],

    "ckanext.sfb_group_sync.fields": "sfb_grupo,grupos,grupo,grupo_de_usuarios",
}

keys = set(settings)

def is_target(line: str) -> bool:
    s = line.strip()
    if not s or s.startswith("#"):
        return False
    return any(s.startswith(k + " ") or s.startswith(k + "=") for k in keys)

clean = [line for line in lines if not is_target(line)]

app_start = None
for i, line in enumerate(clean):
    if line.strip() == "[app:main]":
        app_start = i
        break

if app_start is None:
    clean.insert(0, "[app:main]")
    app_start = 0

block = ["", "## SFB Docker installer settings"]
for key, value in settings.items():
    block.append(f"{key} = {value}")

new_lines = clean[:app_start + 1] + block + clean[app_start + 1:]
ini_path.parent.mkdir(parents=True, exist_ok=True)
ini_path.write_text("\n".join(new_lines) + "\n")
PY
}

compile_translations() {
  if [[ "${COMPILE_TRANSLATIONS,,}" != "true" ]]; then
    echo "COMPILE_TRANSLATIONS=false. Pulando."
    return
  fi

  find /opt/ckan/extra_translations -type f -name '*.po' 2>/dev/null | while read -r po; do
    mo="${po%.po}.mo"
    echo "Compilando: $po -> $mo"
    msgfmt "$po" -o "$mo"
  done

  CORE_PO="/usr/lib/ckan/ckan/ckan/i18n/pt_BR/LC_MESSAGES/ckan.po"
  CORE_MO="/usr/lib/ckan/ckan/ckan/i18n/pt_BR/LC_MESSAGES/ckan.mo"

  if [[ -f "$CORE_PO" ]]; then
    echo "Compilando tradução principal CKAN: $CORE_PO -> $CORE_MO"
    msgfmt "$CORE_PO" -o "$CORE_MO"
  fi
}

db_has_ckan_tables() {
  PGPASSWORD="$CKAN_DB_PASSWORD" psql \
    -h "$CKAN_DB_HOST" \
    -p "$CKAN_DB_PORT" \
    -U "$CKAN_DB_USER" \
    -d "$CKAN_DB_NAME" \
    -tAc "SELECT to_regclass('public.package') IS NOT NULL;" 2>/dev/null | grep -q t
}

clear_ui_css() {
  if [[ "${CLEAR_UI_CUSTOM_CSS,,}" != "true" ]]; then
    echo "CLEAR_UI_CUSTOM_CSS=false. Pulando."
    return
  fi

  ckan -c "$CKAN_INI" shell <<'PY' || true
from ckan import model
from sqlalchemy import text

for key in ["ckan.site_custom_css"]:
    try:
        model.Session.execute(
            text("UPDATE system_info SET value = :value WHERE key = :key"),
            {"value": "", "key": key},
        )
        print("OK limpo:", key)
    except Exception as e:
        print("AVISO:", key, repr(e))

model.Session.commit()
PY
}

log "CARREGANDO SEGREDOS DOCKER"
load_secret_var CKAN_DB_PASSWORD
load_secret_var CKAN_SYSADMIN_PASSWORD

log "AGUARDANDO DEPENDÊNCIAS"
wait_tcp "$CKAN_DB_HOST" "$CKAN_DB_PORT" "PostgreSQL" 120
wait_tcp "$REDIS_HOST" "$REDIS_PORT" "Redis" 120
wait_tcp "$SOLR_HOST" "$SOLR_PORT" "Solr" 120

log "GERANDO CKAN.INI SE NECESSÁRIO"
if [[ ! -f "$CKAN_INI" ]]; then
  ckan generate config "$CKAN_INI"
fi

log "APLICANDO CONFIGURAÇÕES NO CKAN.INI"
write_ini_settings

log "COMPILANDO TRADUÇÕES"
compile_translations

log "VALIDANDO CONFIGURAÇÃO"
ckan -c "$CKAN_INI" config validate

log "INICIALIZANDO BANCO, SE NECESSÁRIO"
if db_has_ckan_tables; then
  echo "Banco já possui tabelas CKAN. Pulando db init."
else
  ckan -c "$CKAN_INI" db init
fi

log "CRIANDO USUÁRIO ADMINISTRADOR E MARCANDO COMO SYSADMIN"
if ckan -c "$CKAN_INI" user add "$CKAN_SYSADMIN_NAME" \
  email="$CKAN_SYSADMIN_EMAIL" \
  password="$CKAN_SYSADMIN_PASSWORD"; then
  echo "OK: usuário administrador criado: $CKAN_SYSADMIN_NAME"
else
  echo "AVISO: usuário administrador pode já existir. Tentando marcar como sysadmin."
fi

ckan -c "$CKAN_INI" sysadmin add "$CKAN_SYSADMIN_NAME"
ckan -c "$CKAN_INI" sysadmin list || true

log "LIMPANDO CSS CUSTOM DA UI, SE CONFIGURADO"
clear_ui_css

log "TESTANDO IMPORTS DAS EXTENSÕES"
python <<PY
mods = ["ckanext.scheming.plugins"] + """${SFB_IMPORT_MODULES}""".split()
for mod in mods:
    __import__(mod)
    print("OK import:", mod)
PY

log "TESTANDO SCHEMA SCHEMING"
ckan -c "$CKAN_INI" shell <<'PY'
import ckanext.scheming.helpers as sh
schema = sh.scheming_get_dataset_schema("dataset")
print("SCHEMA_OK =", bool(schema))
print("dataset_type =", schema.get("dataset_type"))
print("dataset_fields =", len(schema.get("dataset_fields", [])))
PY

if [[ "${REINDEX_SEARCH,,}" == "true" ]]; then
  log "REINDEXANDO BUSCA"
  ckan -c "$CKAN_INI" search-index rebuild
else
  echo "REINDEX_SEARCH=false. Pulando reindex."
fi

if [[ "${1:-serve}" == "serve" ]]; then
  log "INICIANDO CKAN"
  exec ckan -c "$CKAN_INI" run --host 0.0.0.0 --port "$CKAN_INTERNAL_PORT"
else
  exec "$@"
fi
EOF

  chmod +x "$CKAN_BUILD_DIR/entrypoint.sh"
}

write_solr_dockerfile() {
  cat > "$SOLR_BUILD_DIR/Dockerfile" <<'EOF'
ARG SOLR_IMAGE=solr:8.11.2
FROM ${SOLR_IMAGE}

USER root

RUN cp -r /opt/solr/server/solr/configsets/_default /opt/solr/server/solr/configsets/ckan \
  && rm -f /opt/solr/server/solr/configsets/ckan/conf/managed-schema \
  && rm -f /opt/solr/server/solr/configsets/ckan/conf/schema.xml

COPY solr/managed-schema /opt/solr/server/solr/configsets/ckan/conf/managed-schema

RUN chown -R solr:solr /opt/solr/server/solr/configsets/ckan

USER solr
EOF
}

write_nginx_http_conf() {
  cat > "$NGINX_DIR/default.conf" <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    client_max_body_size ${NGINX_CLIENT_MAX_BODY_SIZE};

    proxy_read_timeout ${NGINX_PROXY_READ_TIMEOUT};
    proxy_send_timeout ${NGINX_PROXY_SEND_TIMEOUT};
    proxy_connect_timeout ${NGINX_PROXY_CONNECT_TIMEOUT};

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        proxy_pass http://ckan:${CKAN_INTERNAL_PORT}/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
}

write_nginx_https_conf() {
  cat > "$NGINX_DIR/default.conf" <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    client_max_body_size ${NGINX_CLIENT_MAX_BODY_SIZE};

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    client_max_body_size ${NGINX_CLIENT_MAX_BODY_SIZE};

    proxy_read_timeout ${NGINX_PROXY_READ_TIMEOUT};
    proxy_send_timeout ${NGINX_PROXY_SEND_TIMEOUT};
    proxy_connect_timeout ${NGINX_PROXY_CONNECT_TIMEOUT};

    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;

    location / {
        proxy_pass http://ckan:${CKAN_INTERNAL_PORT}/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
EOF
}

write_compose_file() {
  local ckan_ports_block=""
  if [[ "${PUBLISH_CKAN_LOCAL_PORT,,}" == "true" ]]; then
    ckan_ports_block="
    ports:
      - \"${CKAN_LOCAL_BIND}:${CKAN_INTERNAL_PORT}\""
  fi

  local nginx_ports_block="
    ports:
      - \"80:80\""
  if [[ "${ENABLE_HTTPS,,}" == "true" ]]; then
    nginx_ports_block="${nginx_ports_block}
      - \"443:443\""
  fi

  cat > "$COMPOSE_FILE" <<EOF
services:
  db:
    image: ${POSTGRES_IMAGE}
    container_name: ckan_sfb_db
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${CKAN_DB_NAME}
      POSTGRES_USER: ${CKAN_DB_USER}
      POSTGRES_PASSWORD_FILE: /run/secrets/ckan_db_password
    secrets:
      - ckan_db_password
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - ckan_sfb_net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${CKAN_DB_USER} -d ${CKAN_DB_NAME}"]
      interval: 10s
      timeout: 5s
      retries: 20

  redis:
    image: ${REDIS_IMAGE}
    container_name: ckan_sfb_redis
    restart: unless-stopped
    command: ["redis-server", "--appendonly", "yes", "--protected-mode", "no"]
    volumes:
      - redis_data:/data
    networks:
      - ckan_sfb_net
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 20

  solr:
    build:
      context: .
      dockerfile: solr/Dockerfile
      args:
        SOLR_IMAGE: ${SOLR_IMAGE}
    container_name: ckan_sfb_solr
    restart: unless-stopped
    command: ["solr-precreate", "${SOLR_CORE}", "/opt/solr/server/solr/configsets/ckan"]
    volumes:
      - solr_data:/var/solr
    networks:
      - ckan_sfb_net
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://localhost:8983/solr/${SOLR_CORE}/admin/ping?wt=json | grep -q OK"]
      interval: 15s
      timeout: 5s
      retries: 30

  ckan:
    build:
      context: .
      dockerfile: ckan/Dockerfile
      args:
        PYTHON_VERSION: "${PYTHON_VERSION}"
        CKAN_VERSION: "${CKAN_VERSION}"
        CKAN_GIT_URL: "${CKAN_GIT_URL}"
        SCHEMING_GIT_URL: "${SCHEMING_GIT_URL}"
        SCHEMING_GIT_BRANCH: "${SCHEMING_GIT_BRANCH}"
        SFB_EXTS: "${SFB_EXTS}"
    container_name: ckan_sfb_ckan
    restart: unless-stopped
    env_file:
      - .env
    secrets:
      - ckan_db_password
      - ckan_sysadmin_password
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
      solr:
        condition: service_healthy
    volumes:
      - ./ckan-config:/etc/ckan
      - ckan_storage:/var/lib/ckan
    networks:
      - ckan_sfb_net
${ckan_ports_block}

  nginx:
    image: ${NGINX_IMAGE}
    container_name: ckan_sfb_nginx
    restart: unless-stopped
    depends_on:
      - ckan
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ./certbot-www:/var/www/certbot
      - ./letsencrypt:/etc/letsencrypt
    networks:
      - ckan_sfb_net
${nginx_ports_block}

  certbot:
    image: ${CERTBOT_IMAGE}
    container_name: ckan_sfb_certbot
    volumes:
      - ./certbot-www:/var/www/certbot
      - ./letsencrypt:/etc/letsencrypt
    networks:
      - ckan_sfb_net

secrets:
  ckan_db_password:
    file: ./secrets/ckan_db_password
  ckan_sysadmin_password:
    file: ./secrets/ckan_sysadmin_password

networks:
  ckan_sfb_net:
    driver: bridge

volumes:
  db_data:
  redis_data:
  solr_data:
  ckan_storage:
EOF
}

configure_firewall() {
  if [[ "${ENABLE_UFW,,}" != "true" ]]; then
    echo "ENABLE_UFW=false. Pulando UFW."
    return
  fi

  ufw allow "${SSH_PORT}/tcp"
  ufw allow 80/tcp

  if [[ "${ENABLE_HTTPS,,}" == "true" ]]; then
    ufw allow 443/tcp
  fi

  ufw deny 5000/tcp || true
  ufw deny 8983/tcp || true
  ufw deny 5432/tcp || true
  ufw deny 6379/tcp || true

  ufw --force enable
  ufw status verbose
}

install_certbot_cron() {
  if [[ "${ENABLE_HTTPS,,}" != "true" ]]; then
    return
  fi

  cat >/etc/cron.d/ckan_sfb_docker_certbot <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

17 3 * * * root cd ${PROJECT_DIR} && docker compose run --rm certbot renew --webroot -w /var/www/certbot --quiet && docker compose exec -T nginx nginx -s reload >/dev/null 2>&1
EOF

  chmod 644 /etc/cron.d/ckan_sfb_docker_certbot
  echo "Cron de renovação criado: /etc/cron.d/ckan_sfb_docker_certbot"
}

step 1 "INÍCIO, LOG E VARIÁVEIS"
echo "Data: $(date)"
echo "Host: $(hostname)"
echo "Script: $SCRIPT_PATH"
echo "Vars: $VARS_FILE"
echo "Secrets: $SECRETS_FILE"
echo "Log: $LOG_FILE"
echo "Backup: $BACKUP_DIR"
echo "Projeto Docker: $PROJECT_DIR"
echo "URL final: $SITE_URL"

step 2 "VALIDANDO VARIÁVEIS OBRIGATÓRIAS"
for v in \
  INSTALL_DIR DOMAIN CKAN_VERSION CKAN_GIT_URL PYTHON_VERSION \
  CKAN_SYSADMIN_NAME CKAN_SYSADMIN_EMAIL \
  CKAN_DB_NAME CKAN_DB_USER \
  POSTGRES_IMAGE REDIS_IMAGE SOLR_IMAGE NGINX_IMAGE CERTBOT_IMAGE \
  SOLR_CORE CKAN_SOLR_SCHEMA_URL GIT_REPO_URL GIT_BRANCH \
  SCHEMING_GIT_URL SCHEMING_GIT_BRANCH SFB_EXTS CKAN_PLUGINS; do
  require_var "$v"
done

for v in CKAN_DB_PASSWORD CKAN_SYSADMIN_PASSWORD; do
  require_secret_var "$v"
done

[[ "$CKAN_VERSION" == "ckan-2.10.7" ]] || fail "Por exigência do cliente, CKAN_VERSION deve ser ckan-2.10.7. Atual: $CKAN_VERSION"

if [[ "$CKAN_DB_PASSWORD" == "TROQUE_ESTA_SENHA_DO_BANCO" ]]; then
  fail "Troque CKAN_DB_PASSWORD no arquivo .secrets antes de rodar."
fi

if [[ "$CKAN_SYSADMIN_PASSWORD" == "TROQUE_ESTA_SENHA_DO_SYSADMIN" ]]; then
  fail "Troque CKAN_SYSADMIN_PASSWORD no arquivo .secrets antes de rodar."
fi

echo "OK: variáveis obrigatórias validadas."

step 3 "PREPARAÇÃO DO SISTEMA"
export DEBIAN_FRONTEND=noninteractive
apt update -y

if [[ "${RUN_APT_UPGRADE,,}" == "true" ]]; then
  apt upgrade -y
else
  echo "RUN_APT_UPGRADE=false. Pulando apt upgrade."
fi

apt install -y \
  ca-certificates \
  curl \
  git \
  wget \
  jq \
  dnsutils \
  ufw \
  cron

step 4 "INSTALANDO DOCKER E DOCKER COMPOSE"
install_docker

step 5 "CHECANDO DNS DO DOMÍNIO"
echo "Domínio: $DOMAIN"
echo "--- DNS Cloudflare:"
dig @1.1.1.1 +short "$DOMAIN" A || true
echo "--- DNS Google:"
dig @8.8.8.8 +short "$DOMAIN" A || true

if [[ -n "${EXPECTED_DNS_IP:-}" ]]; then
  DNS_CF="$(dig @1.1.1.1 +short "$DOMAIN" A | tail -1 || true)"
  if [[ "$DNS_CF" == "$EXPECTED_DNS_IP" ]]; then
    echo "OK: DNS público aponta para EXPECTED_DNS_IP=$EXPECTED_DNS_IP"
  else
    echo "AVISO: DNS Cloudflare retornou '${DNS_CF:-vazio}', esperado '$EXPECTED_DNS_IP'"
  fi
fi

step 6 "CRIANDO ESTRUTURA DO PROJETO DOCKER"
if [[ -d "$PROJECT_DIR" && "${FORCE_OVERWRITE_PROJECT_DIR,,}" != "true" ]]; then
  fail "INSTALL_DIR já existe: $PROJECT_DIR. Ajuste FORCE_OVERWRITE_PROJECT_DIR=true para sobrescrever arquivos do kit."
fi

mkdir -p \
  "$PROJECT_DIR" \
  "$REPO_DIR" \
  "$CKAN_BUILD_DIR" \
  "$SOLR_BUILD_DIR" \
  "$NGINX_DIR" \
  "$CERTBOT_WWW_DIR" \
  "$LETSENCRYPT_DIR" \
  "$CKAN_CONFIG_DIR" \
  "$PROJECT_SECRETS_DIR"

backup_project_file "$COMPOSE_FILE"
backup_project_file "$ENV_FILE"
backup_project_file "$NGINX_DIR/default.conf"
backup_project_file "$CKAN_BUILD_DIR/Dockerfile"
backup_project_file "$CKAN_BUILD_DIR/entrypoint.sh"
backup_project_file "$SOLR_BUILD_DIR/Dockerfile"

step 7 "CLONANDO OU ATUALIZANDO CUSTOMIZAÇÃO SFB"
if [[ -d "$REPO_SFB_DIR/.git" ]]; then
  cd "$REPO_SFB_DIR"
  git fetch origin
  git checkout "$GIT_BRANCH"
  git pull origin "$GIT_BRANCH"
else
  rm -rf "$REPO_SFB_DIR"
  git clone --branch "$GIT_BRANCH" "$GIT_REPO_URL" "$REPO_SFB_DIR"
  cd "$REPO_SFB_DIR"
fi

git log --oneline -1
[[ -d "$REPO_SFB_DIR/rootfs" ]] || fail "repositório SFB não contém rootfs: $REPO_SFB_DIR/rootfs"

step 8 "SEMEANDO /ETC/CKAN DO ROOTFS NO VOLUME DOCKER"

if [[ -d "$REPO_SFB_DIR/rootfs/etc/ckan" ]]; then
  echo "Copiando rootfs/etc/ckan para o volume persistente: $CKAN_CONFIG_DIR"

  if [[ -d "$CKAN_CONFIG_DIR" ]] && find "$CKAN_CONFIG_DIR" -mindepth 1 -print -quit | grep -q .; then
    tar -czf "$BACKUP_DIR/ckan-config-before-seed-${STAMP}.tar.gz" -C "$CKAN_CONFIG_DIR" .
    echo "Backup do ckan-config atual: $BACKUP_DIR/ckan-config-before-seed-${STAMP}.tar.gz"
  fi

  rsync -aHv \
    --exclude='ckan.ini' \
    --exclude='*.bak' \
    --exclude='*.bkp' \
    --exclude='*.BKP' \
    --exclude='*.pyc' \
    --exclude='__pycache__/' \
    "$REPO_SFB_DIR/rootfs/etc/ckan/" \
    "$CKAN_CONFIG_DIR/"

  echo "OK: arquivos de /etc/ckan semeados no volume Docker."\necho "Ajustando permissões do ckan-config para o usuário interno do container CKAN..."
chown -R 1000:1000 "$CKAN_CONFIG_DIR"
find "$CKAN_CONFIG_DIR" -type d -exec chmod 755 {} \;
find "$CKAN_CONFIG_DIR" -type f -exec chmod 644 {} \;

else
  fail "rootfs/etc/ckan não encontrado em: $REPO_SFB_DIR/rootfs/etc/ckan"
fi

if [[ ! -f "$CKAN_CONFIG_DIR/schemas/sfb_dataset.yaml" ]]; then
  fail "schema SFB não encontrado após semeadura: $CKAN_CONFIG_DIR/schemas/sfb_dataset.yaml"
fi

if [[ ! -d "$CKAN_CONFIG_DIR/custom/templates" ]]; then
  fail "templates custom não encontrados após semeadura: $CKAN_CONFIG_DIR/custom/templates"
fi

if [[ ! -d "$CKAN_CONFIG_DIR/custom/public" ]]; then
  fail "public custom não encontrado após semeadura: $CKAN_CONFIG_DIR/custom/public"
fi

step 9 "BAIXANDO SCHEMA SOLR DO CKAN 2.10.7"
wget -O "$SOLR_BUILD_DIR/managed-schema" "$CKAN_SOLR_SCHEMA_URL"
ls -lh "$SOLR_BUILD_DIR/managed-schema"

step 10 "GERANDO SEGREDOS LOCAIS E .ENV DO DOCKER"
write_secret_files
write_env_file
ls -lh "$ENV_FILE"
echo "OK: arquivos secretos Docker criados em: $PROJECT_SECRETS_DIR"

step 11 "GERANDO DOCKERFILE DO CKAN"
write_ckan_dockerfile
write_ckan_entrypoint
ls -lh "$CKAN_BUILD_DIR/Dockerfile" "$CKAN_BUILD_DIR/entrypoint.sh"

step 12 "GERANDO DOCKERFILE DO SOLR"
write_solr_dockerfile
ls -lh "$SOLR_BUILD_DIR/Dockerfile"

step 13 "GERANDO NGINX HTTP INICIAL"
write_nginx_http_conf
nginx_preview="$(sed -n '1,120p' "$NGINX_DIR/default.conf")"
echo "$nginx_preview"

step 14 "GERANDO DOCKER-COMPOSE.YML"
write_compose_file
sed -n '1,240p' "$COMPOSE_FILE"

step 15 "CONFIGURANDO FIREWALL LOCAL"
configure_firewall

step 16 "BUILD DAS IMAGENS"
cd "$PROJECT_DIR"
docker compose build --no-cache

step 17 "SUBINDO CONTAINERS"
docker compose up -d

step 18 "AGUARDANDO CKAN PELO NGINX HTTP"
for i in $(seq 1 120); do
  if curl -fsS -H "Host: ${DOMAIN}" "http://127.0.0.1/api/3/action/status_show" >/dev/null 2>&1; then
    echo "OK: CKAN respondeu via Nginx HTTP."
    break
  fi

  if [[ "$i" -eq 120 ]]; then
    docker compose ps
    docker compose logs --tail=180 ckan
    fail "CKAN não respondeu via Nginx HTTP em 120s."
  fi

  sleep 2
done

step 19 "ATIVANDO HTTPS COM CERTBOT, SE CONFIGURADO"
if [[ "${ENABLE_HTTPS,,}" == "true" ]]; then
  if [[ -n "${CERTBOT_EMAIL:-}" ]]; then
    CERTBOT_ACCOUNT_ARGS=(--email "$CERTBOT_EMAIL")
  else
    CERTBOT_ACCOUNT_ARGS=(--register-unsafely-without-email)
  fi

  docker compose run --rm certbot certonly \
    --webroot \
    -w /var/www/certbot \
    -d "$DOMAIN" \
    --non-interactive \
    --agree-tos \
    "${CERTBOT_ACCOUNT_ARGS[@]}"

  write_nginx_https_conf

  docker compose exec -T nginx nginx -t

  echo "Reiniciando Nginx para renovar resolução do upstream CKAN..."
  docker compose restart nginx

  for i in $(seq 1 30); do
    if docker compose exec -T nginx nginx -t >/dev/null 2>&1; then
      echo "OK: Nginx reiniciado e configuração válida."
      break
    fi
    sleep 2
  done

  install_certbot_cron
else
  echo "ENABLE_HTTPS=false. Mantendo somente HTTP."
fi

step 20 "VALIDANDO CKAN CONFIG"
docker compose exec -T ckan ckan -c "$CKAN_INI" config validate

step 21 "VALIDANDO IMPORTS DAS EXTENSÕES"
docker compose exec -T ckan python <<PY
mods = ["ckanext.scheming.plugins"] + """${SFB_IMPORT_MODULES}""".split()
for mod in mods:
    __import__(mod)
    print("OK import:", mod)
PY

step 22 "VALIDANDO SCHEMA SCHEMING"
docker compose exec -T ckan ckan -c "$CKAN_INI" shell <<'PY'
import ckanext.scheming.helpers as sh
schema = sh.scheming_get_dataset_schema("dataset")
print("SCHEMA_OK =", bool(schema))
print("dataset_type =", schema.get("dataset_type"))
print("dataset_fields =", len(schema.get("dataset_fields", [])))
PY

step 23 "VALIDANDO API LOCAL"
API_TMP="$(mktemp)"

cleanup_api_tmp() {
  rm -f "$API_TMP"
}
trap cleanup_api_tmp EXIT

if [[ "${ENABLE_HTTPS,,}" == "true" ]]; then
  echo "HTTPS ativo: aguardando API local via domínio com --resolve..."
  for i in $(seq 1 90); do
    if curl -k -fsS --max-time 10 \
      --resolve "${DOMAIN}:443:127.0.0.1" \
      "https://${DOMAIN}/api/3/action/status_show" > "$API_TMP"; then
      if python3 -m json.tool "$API_TMP" | sed -n '1,120p'; then
        echo "OK: API local HTTPS respondeu com JSON válido."
        break
      fi
    fi

    if [[ "$i" -eq 90 ]]; then
      echo "ERRO: API local HTTPS não respondeu com JSON válido após 90 tentativas."
      echo "--- Última resposta capturada, se houver:"
      cat "$API_TMP" || true
      exit 1
    fi

    echo "Aguardando API local HTTPS... tentativa $i/90"
    sleep 2
  done
else
  echo "HTTPS desativado: aguardando API local via HTTP..."
  for i in $(seq 1 90); do
    if curl -fsS --max-time 10 \
      -H "Host: ${DOMAIN}" \
      "http://127.0.0.1/api/3/action/status_show" > "$API_TMP"; then
      if python3 -m json.tool "$API_TMP" | sed -n '1,120p'; then
        echo "OK: API local HTTP respondeu com JSON válido."
        break
      fi
    fi

    if [[ "$i" -eq 90 ]]; then
      echo "ERRO: API local HTTP não respondeu com JSON válido após 90 tentativas."
      echo "--- Última resposta capturada, se houver:"
      cat "$API_TMP" || true
      exit 1
    fi

    echo "Aguardando API local HTTP... tentativa $i/90"
    sleep 2
  done
fi

step 24 "VALIDANDO DOMÍNIO"
if [[ "${ENABLE_HTTPS,,}" == "true" ]]; then
  curl -I -k -s --connect-timeout 15 --resolve "${DOMAIN}:443:127.0.0.1" "https://${DOMAIN}/" | sed -n '1,20p'
  curl -I -k -s --connect-timeout 15 --resolve "${DOMAIN}:443:127.0.0.1" "https://${DOMAIN}/dataset/" | sed -n '1,20p'
else
  curl -I -s --connect-timeout 15 -H "Host: ${DOMAIN}" "http://127.0.0.1/" | sed -n '1,20p'
  curl -I -s --connect-timeout 15 -H "Host: ${DOMAIN}" "http://127.0.0.1/dataset/" | sed -n '1,20p'
fi

step 25 "STATUS DOS CONTAINERS E PORTAS"
docker compose ps
ss -lntp | grep -E ':(80|443|5000|5432|6379|8983)\b' || true

step 26 "FINALIZAÇÃO"
echo
echo "============================================================"
echo "INSTALAÇÃO DOCKER CKAN SFB CONCLUÍDA"
echo "CKAN: ${CKAN_VERSION}"
echo "URL: ${SITE_URL}"
echo "Projeto Docker: ${PROJECT_DIR}"
echo "Compose: ${COMPOSE_FILE}"
echo "Env: ${ENV_FILE}"
echo "Log: ${LOG_FILE}"
echo "Backup: ${BACKUP_DIR}"
echo "============================================================"