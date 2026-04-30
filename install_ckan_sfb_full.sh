#!/usr/bin/env bash
set -Eeuo pipefail
umask 022

# ============================================================
# SCRIPT ÚNICO: INSTALAÇÃO CKAN VANILLA + CUSTOMIZAÇÃO CKAN SFB
# Base: instalação CKAN vanilla + customização SFB via Git + .vars SFB
# Ubuntu LTS, pensado para VM nova.
# ============================================================

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
SCRIPT_BASE="$(basename "$SCRIPT_PATH" .sh)"
VARS_FILE="${1:-${SCRIPT_DIR}/${SCRIPT_BASE}.vars}"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERRO: rode este script como root. Exemplo: sudo ./${SCRIPT_BASE}.sh"
  exit 1
fi

if [[ ! -f "$VARS_FILE" ]]; then
  echo "ERRO: arquivo de variáveis não encontrado: $VARS_FILE"
  echo "O arquivo deve ter o mesmo nome-base do script, por exemplo: ${SCRIPT_BASE}.vars"
  exit 1
fi

# shellcheck disable=SC1090
source "$VARS_FILE"

STAMP="$(date +%F_%H-%M-%S)"
LOG_DIR="${LOG_DIR:-/var/log/ckan-sfb-full-install}"
BACKUP_ROOT="${BACKUP_ROOT:-/root/ckan-sfb-full-backups}"
LOG_FILE="$LOG_DIR/${SCRIPT_BASE}_${STAMP}.log"
BACKUP_DIR="$BACKUP_ROOT/backup_${STAMP}"
REPO_DIR="${WORKDIR}/repo"
SITE_SCHEME="http"
if [[ "${ENABLE_HTTPS,,}" == "true" ]]; then
  SITE_SCHEME="https"
fi
SITE_URL="${SITE_SCHEME}://${DOMAIN}"
SOLR_URL="http://${SOLR_HOST}:${SOLR_PORT}/solr/${SOLR_CORE}"

mkdir -p "$LOG_DIR" "$BACKUP_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

trap 'rc=$?; echo; echo "ERRO: falha na linha ${LINENO}. Código: ${rc}"; echo "Log: ${LOG_FILE}"; exit ${rc}' ERR

TOTAL=31

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

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "comando obrigatório ausente: $1"
}

backup_file() {
  local f="$1"
  if [[ -e "$f" ]]; then
    local bak="${f}$(date +%F_%H-%M-%S).bak"
    cp -a "$f" "$bak"
    echo "Backup: $bak"
  fi
}

backup_dir_tar() {
  local d="$1"
  local label="$2"
  if [[ -d "$d" ]]; then
    local tarfile="$BACKUP_DIR/${label}_${STAMP}.tar.gz"
    tar -czf "$tarfile" -C "$(dirname "$d")" "$(basename "$d")"
    echo "Backup diretório: $tarfile"
  fi
}

validate_simple_pg_ident() {
  local name="$1"
  local value="$2"
  if [[ ! "$value" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
    fail "$name deve usar apenas letras, números e underscore, começando por letra/underscore. Valor atual: $value"
  fi
}

sql_literal() {
  python3 - "$1" <<'PYSQL'
import sys
s = sys.argv[1]
print("'" + s.replace("'", "''") + "'")
PYSQL
}

run_as_ckan() {
  sudo -u "$CKAN_USER" -H bash -lc "$*"
}

set_sh_var() {
  local file="$1"
  local key="$2"
  local value="$3"
  if grep -qE "^[#[:space:]]*${key}=" "$file"; then
    sed -i "s|^[#[:space:]]*${key}=.*|${key}=\"${value}\"|" "$file"
  else
    echo "${key}=\"${value}\"" >> "$file"
  fi
}

wait_http() {
  local url="$1"
  local seconds="$2"
  local label="$3"
  for i in $(seq 1 "$seconds"); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      echo "OK: $label respondeu: $url"
      return 0
    fi
    sleep 1
  done
  return 1
}

write_ini_settings() {
  local mode="$1"
  MODE="$mode" \
  CKAN_INI="$CKAN_INI" \
  SITE_URL="$SITE_URL" \
  CKAN_SITE_ID="$CKAN_SITE_ID" \
  CKAN_DB_HOST="$CKAN_DB_HOST" \
  CKAN_DB_NAME="$CKAN_DB_NAME" \
  CKAN_DB_USER="$CKAN_DB_USER" \
  CKAN_DB_PASSWORD="$CKAN_DB_PASSWORD" \
  SOLR_URL="$SOLR_URL" \
  CKAN_STORAGE_PATH="$CKAN_STORAGE_PATH" \
  CKAN_UPLOADS_ENABLED="$CKAN_UPLOADS_ENABLED" \
  CKAN_MAX_RESOURCE_SIZE_MB="$CKAN_MAX_RESOURCE_SIZE_MB" \
  CKAN_MAX_IMAGE_SIZE_MB="$CKAN_MAX_IMAGE_SIZE_MB" \
  CKAN_RESOURCE_PROXY_MAX_FILE_SIZE_BYTES="$CKAN_RESOURCE_PROXY_MAX_FILE_SIZE_BYTES" \
  REDIS_URL="$REDIS_URL" \
  CKAN_PLUGINS="$CKAN_PLUGINS" \
  CKAN_EXTRA_TEMPLATE_PATHS="$CKAN_EXTRA_TEMPLATE_PATHS" \
  CKAN_EXTRA_PUBLIC_PATHS="$CKAN_EXTRA_PUBLIC_PATHS" \
  CKAN_THEME="$CKAN_THEME" \
  CKAN_LOCALE_DEFAULT="$CKAN_LOCALE_DEFAULT" \
  CKAN_LOCALES_OFFERED="$CKAN_LOCALES_OFFERED" \
  CKAN_LOCALE_ORDER="$CKAN_LOCALE_ORDER" \
  CKAN_I18N_EXTRA_DIRECTORY="$CKAN_I18N_EXTRA_DIRECTORY" \
  CKAN_I18N_EXTRA_GETTEXT_DOMAIN="$CKAN_I18N_EXTRA_GETTEXT_DOMAIN" \
  CKAN_I18N_EXTRA_LOCALES="$CKAN_I18N_EXTRA_LOCALES" \
  SCHEMING_PRESETS="$SCHEMING_PRESETS" \
  SCHEMING_DATASET_SCHEMAS="$SCHEMING_DATASET_SCHEMAS" \
  SCHEMING_DATASET_FALLBACK="$SCHEMING_DATASET_FALLBACK" \
  python3 <<'PY'
from pathlib import Path
import os

ini = Path(os.environ["CKAN_INI"])
text = ini.read_text(errors="replace") if ini.exists() else "[app:main]\n"
lines = text.splitlines()

mode = os.environ["MODE"]
base_settings = {
    "sqlalchemy.url": "postgresql://{u}:{p}@{h}/{d}".format(
        u=os.environ["CKAN_DB_USER"],
        p=os.environ["CKAN_DB_PASSWORD"],
        h=os.environ["CKAN_DB_HOST"],
        d=os.environ["CKAN_DB_NAME"],
    ),
    "solr_url": os.environ["SOLR_URL"],
    "ckan.redis.url": os.environ["REDIS_URL"],
    "ckan.site_id": os.environ["CKAN_SITE_ID"],
    "ckan.site_url": os.environ["SITE_URL"],
    "ckan.storage_path": os.environ["CKAN_STORAGE_PATH"],
    "ckan.uploads_enabled": os.environ["CKAN_UPLOADS_ENABLED"],
    "ckan.max_resource_size": os.environ["CKAN_MAX_RESOURCE_SIZE_MB"],
    "ckan.max_image_size": os.environ["CKAN_MAX_IMAGE_SIZE_MB"],
    "ckan.resource_proxy.max_file_size": os.environ["CKAN_RESOURCE_PROXY_MAX_FILE_SIZE_BYTES"],
}

custom_settings = {
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

settings = dict(base_settings)
if mode == "custom":
    settings.update(custom_settings)

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

block = ["", f"## SFB installer settings ({mode})"]
for key, value in settings.items():
    block.append(f"{key} = {value}")

new_lines = clean[:app_start + 1] + block + clean[app_start + 1:]
ini.write_text("\n".join(new_lines) + "\n")
PY
}

step 1 "INÍCIO, LOG E VARIÁVEIS"
echo "Data: $(date)"
echo "Host: $(hostname)"
echo "Script: $SCRIPT_PATH"
echo "Vars: $VARS_FILE"
echo "Log: $LOG_FILE"
echo "Backup: $BACKUP_DIR"
echo "URL final: $SITE_URL"

step 2 "VALIDANDO VARIÁVEIS OBRIGATÓRIAS"
for v in \
  PYTHON_BIN CKAN_VERSION CKAN_GIT_URL CKAN_INSTALL_DIR CKAN_SRC_DIR CKAN_CONFIG_DIR CKAN_INI CKAN_STORAGE_PATH \
  CKAN_USER CKAN_GROUP CKAN_SERVICE CKAN_HOST CKAN_PORT CKAN_DB_HOST CKAN_DB_NAME CKAN_DB_USER CKAN_DB_PASSWORD \
  CKAN_SYSADMIN_NAME CKAN_SYSADMIN_EMAIL CKAN_SYSADMIN_PASSWORD REDIS_URL SOLR_VERSION SOLR_TGZ_URL SOLR_SERVICE \
  SOLR_HOST SOLR_PORT SOLR_CORE CKAN_SOLR_SCHEMA_URL DOMAIN NGINX_SITE NGINX_SITE_ENABLED GIT_REPO_URL GIT_BRANCH WORKDIR; do
  require_var "$v"
done
validate_simple_pg_ident "CKAN_DB_NAME" "$CKAN_DB_NAME"
validate_simple_pg_ident "CKAN_DB_USER" "$CKAN_DB_USER"
[[ "$CKAN_HOST" == "127.0.0.1" || "$CKAN_HOST" == "localhost" ]] || fail "CKAN_HOST deve ser local: 127.0.0.1 ou localhost"
[[ "$SOLR_HOST" == "127.0.0.1" || "$SOLR_HOST" == "localhost" ]] || fail "SOLR_HOST deve ser local: 127.0.0.1 ou localhost"

echo "OK: variáveis obrigatórias validadas."

step 3 "PREPARAÇÃO DO SISTEMA"
export DEBIAN_FRONTEND=noninteractive
apt update -y
if [[ "${RUN_APT_UPGRADE,,}" == "true" ]]; then
  apt upgrade -y
else
  echo "RUN_APT_UPGRADE=false. Pulando apt upgrade."
fi
apt install -y software-properties-common git wget curl ca-certificates gnupg lsb-release apt-transport-https

step 4 "INSTALANDO PYTHON E DEPENDÊNCIAS GERAIS"
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1 && [[ "${ENABLE_DEADSNAKES,,}" == "true" ]]; then
  add-apt-repository ppa:deadsnakes/ppa -y
  apt update -y
fi
apt install -y \
  "$PYTHON_BIN" "${PYTHON_BIN}-venv" "${PYTHON_BIN}-dev" python3-dev python3-pip \
  libpq-dev libxml2-dev libxslt1-dev libjpeg-dev libffi-dev libyaml-dev \
  build-essential gettext rsync unzip jq dnsutils ufw
"$PYTHON_BIN" --version

step 5 "INSTALANDO E PROTEGENDO REDIS"
apt install -y redis-server
backup_file /etc/redis/redis.conf
sed -i 's/^#*\s*protected-mode .*/protected-mode yes/' /etc/redis/redis.conf || true
sed -i 's/^#*\s*bind .*/bind 127.0.0.1 ::1/' /etc/redis/redis.conf || true
systemctl enable --now redis-server
redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" ping

step 6 "INSTALANDO E PROTEGENDO POSTGRESQL"
apt install -y postgresql postgresql-contrib
systemctl enable --now postgresql
if command -v pg_conftool >/dev/null 2>&1; then
  pg_conftool set listen_addresses 'localhost' || true
  systemctl restart postgresql
fi
sudo -u postgres psql -tAc "SELECT version();"

step 7 "CRIANDO USUÁRIO E BANCO CKAN"
DB_PASS_SQL="$(sql_literal "$CKAN_DB_PASSWORD")"

if [[ "${FORCE_RECREATE_CKAN_DB,,}" == "true" ]]; then
  echo "FORCE_RECREATE_CKAN_DB=true. Apagando banco existente, se houver."
  sudo -u postgres psql -v ON_ERROR_STOP=1 -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${CKAN_DB_NAME}';" || true
  sudo -u postgres dropdb --if-exists "$CKAN_DB_NAME"
fi

if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${CKAN_DB_USER}'" | grep -q 1; then
  sudo -u postgres psql -v ON_ERROR_STOP=1 -c "CREATE ROLE ${CKAN_DB_USER} LOGIN PASSWORD ${DB_PASS_SQL};"
else
  sudo -u postgres psql -v ON_ERROR_STOP=1 -c "ALTER ROLE ${CKAN_DB_USER} WITH LOGIN PASSWORD ${DB_PASS_SQL};"
fi

if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='${CKAN_DB_NAME}'" | grep -q 1; then
  sudo -u postgres createdb -O "$CKAN_DB_USER" "$CKAN_DB_NAME" -E utf-8
else
  echo "Banco já existe: $CKAN_DB_NAME"
fi
sudo -u postgres psql -lqt | grep -E "^[[:space:]]*${CKAN_DB_NAME}[[:space:]]*\|" || true

step 8 "INSTALANDO JAVA E SOLR"
apt install -y openjdk-17-jre-headless
java -version
cd /tmp
if [[ ! -f "/tmp/solr-${SOLR_VERSION}.tgz" ]]; then
  wget -O "/tmp/solr-${SOLR_VERSION}.tgz" "$SOLR_TGZ_URL"
fi
if [[ ! -x /opt/solr/bin/solr ]]; then
  rm -f /tmp/install_solr_service.sh
  tar xzf "/tmp/solr-${SOLR_VERSION}.tgz" "solr-${SOLR_VERSION}/bin/install_solr_service.sh" --strip-components=2 -C /tmp
  bash /tmp/install_solr_service.sh "/tmp/solr-${SOLR_VERSION}.tgz"
else
  echo "Solr já instalado em /opt/solr/bin/solr."
fi

step 9 "CONFIGURANDO SOLR LOCALHOST"
if [[ -f /etc/default/solr.in.sh ]]; then
  backup_file /etc/default/solr.in.sh
  set_sh_var /etc/default/solr.in.sh SOLR_JETTY_HOST "$SOLR_HOST"
  set_sh_var /etc/default/solr.in.sh SOLR_PORT "$SOLR_PORT"
fi
systemctl enable --now "$SOLR_SERVICE"
systemctl restart "$SOLR_SERVICE"
sleep 5
/opt/solr/bin/solr status || true
ss -lntp | grep ":${SOLR_PORT}\b" || true

step 10 "CRIANDO CORE SOLR E APLICANDO SCHEMA CKAN"
if [[ "${FORCE_RECREATE_SOLR_CORE,,}" == "true" ]]; then
  sudo -u solr -H /opt/solr/bin/solr delete -c "$SOLR_CORE" || true
fi
if curl -fsS "http://${SOLR_HOST}:${SOLR_PORT}/solr/admin/cores?action=STATUS&core=${SOLR_CORE}&wt=json" | jq -e ".status[\"${SOLR_CORE}\"]" >/dev/null 2>&1; then
  echo "Core Solr já existe: $SOLR_CORE"
else
  sudo -u solr -H /opt/solr/bin/solr create -c "$SOLR_CORE" -d _default
fi
SOLR_CONF_DIR="/var/solr/data/${SOLR_CORE}/conf"
[[ -d "$SOLR_CONF_DIR" ]] || fail "diretório do core Solr não encontrado: $SOLR_CONF_DIR"
backup_file "$SOLR_CONF_DIR/managed-schema"
rm -f "$SOLR_CONF_DIR/schema.xml"
wget -O "$SOLR_CONF_DIR/managed-schema" "$CKAN_SOLR_SCHEMA_URL"
if [[ -f "/opt/solr-${SOLR_VERSION}/server/solr/configsets/_default/conf/synonyms.txt" ]]; then
  cp "/opt/solr-${SOLR_VERSION}/server/solr/configsets/_default/conf/synonyms.txt" "$SOLR_CONF_DIR/synonyms.txt"
fi
chown -R solr:solr "/var/solr/data/${SOLR_CORE}"
systemctl restart "$SOLR_SERVICE"
wait_http "http://${SOLR_HOST}:${SOLR_PORT}/solr/${SOLR_CORE}/admin/ping" 60 "Solr core ${SOLR_CORE}" || fail "Solr não respondeu ao ping."

step 11 "CRIANDO USUÁRIO E DIRETÓRIOS CKAN"
if ! id "$CKAN_USER" >/dev/null 2>&1; then
  if [[ "${CKAN_CREATE_USER_WITH_SUDO,,}" == "true" ]]; then
    adduser --disabled-password --gecos "" "$CKAN_USER"
    usermod -aG sudo "$CKAN_USER"
  else
    adduser --disabled-password --gecos "" "$CKAN_USER"
  fi
fi
mkdir -p "$CKAN_INSTALL_DIR" "$CKAN_CONFIG_DIR" "$CKAN_STORAGE_PATH" "$(dirname "$CKAN_SRC_DIR")"
chown -R "$CKAN_USER:$CKAN_GROUP" "$CKAN_INSTALL_DIR" "$CKAN_CONFIG_DIR" "$CKAN_STORAGE_PATH"
ls -ld "$CKAN_INSTALL_DIR" "$CKAN_CONFIG_DIR" "$CKAN_STORAGE_PATH"

step 12 "INSTALANDO CKAN VANILLA NO VENV"
run_as_ckan "
set -e
if [ ! -d '$CKAN_INSTALL_DIR/venv' ]; then
  '$PYTHON_BIN' -m venv '$CKAN_INSTALL_DIR/venv'
fi
source '$CKAN_INSTALL_DIR/venv/bin/activate'
pip install --upgrade pip setuptools wheel
if [ ! -d '$CKAN_SRC_DIR/.git' ]; then
  rm -rf '$CKAN_SRC_DIR'
  git clone -b '$CKAN_VERSION' '$CKAN_GIT_URL' '$CKAN_SRC_DIR'
else
  cd '$CKAN_SRC_DIR'
  git fetch --tags origin || true
  git checkout '$CKAN_VERSION'
fi
cd '$CKAN_SRC_DIR'
pip install -r requirements.txt
pip install -e '.[requirements]'
"
run_as_ckan "source '$CKAN_INSTALL_DIR/venv/bin/activate'; python -c 'import ckan; print(ckan.__version__)'"

step 13 "GERANDO CKAN.INI"
if [[ -f "$CKAN_INI" ]]; then
  backup_file "$CKAN_INI"
fi
if [[ ! -f "$CKAN_INI" || "${FORCE_OVERWRITE_CKAN_INI,,}" == "true" ]]; then
  rm -f "$CKAN_INI"
  run_as_ckan "source '$CKAN_INSTALL_DIR/venv/bin/activate'; ckan generate config '$CKAN_INI'"
else
  echo "CKAN_INI já existe e FORCE_OVERWRITE_CKAN_INI=false. Mantendo: $CKAN_INI"
fi
chown "$CKAN_USER:$CKAN_GROUP" "$CKAN_INI"
chmod 640 "$CKAN_INI"

step 14 "CONFIGURANDO CKAN.INI BASE"
write_ini_settings "base"
grep -nE '^[[:space:]]*(sqlalchemy.url|solr_url|ckan.site_url|ckan.storage_path|ckan.uploads_enabled|ckan.max_resource_size|ckan.resource_proxy.max_file_size)' "$CKAN_INI" || true

step 15 "INICIALIZANDO BANCO CKAN"
HAS_PACKAGE_TABLE="false"
if sudo -u postgres psql -d "$CKAN_DB_NAME" -tAc "SELECT to_regclass('public.package') IS NOT NULL;" 2>/dev/null | grep -q t; then
  HAS_PACKAGE_TABLE="true"
fi
if [[ "$HAS_PACKAGE_TABLE" == "true" ]]; then
  echo "Banco já tem tabelas CKAN. Pulando ckan db init."
else
  run_as_ckan "source '$CKAN_INSTALL_DIR/venv/bin/activate'; ckan -c '$CKAN_INI' db init"
fi
sudo -u postgres psql -d "$CKAN_DB_NAME" -c "SELECT COUNT(*) AS packages FROM package;" || true

step 16 "CRIANDO SYSADMIN CKAN"
run_as_ckan "
set -e
source '$CKAN_INSTALL_DIR/venv/bin/activate'
ckan -c '$CKAN_INI' sysadmin add '$CKAN_SYSADMIN_NAME' email='$CKAN_SYSADMIN_EMAIL' password='$CKAN_SYSADMIN_PASSWORD' || true
ckan -c '$CKAN_INI' sysadmin list || true
"

step 17 "CLONANDO CUSTOMIZAÇÃO SFB DO GIT"
mkdir -p "$WORKDIR"
if [[ -d "$REPO_DIR/.git" ]]; then
  cd "$REPO_DIR"
  git fetch origin
  git checkout "$GIT_BRANCH"
  git pull origin "$GIT_BRANCH"
else
  rm -rf "$REPO_DIR"
  git clone --branch "$GIT_BRANCH" "$GIT_REPO_URL" "$REPO_DIR"
  cd "$REPO_DIR"
fi
git log --oneline -1
[[ -d "$REPO_DIR/rootfs" ]] || fail "repositório não tem diretório rootfs: $REPO_DIR/rootfs"

step 18 "BACKUP DOS ALVOS DO ROOTFS"
cd "$REPO_DIR"
find rootfs -type f | sed 's#^rootfs##' | sort > "$BACKUP_DIR/arquivos-rootfs.txt"
: > "$BACKUP_DIR/alvos-existentes.txt"
while IFS= read -r rel; do
  target="$rel"
  if [[ -e "$target" ]]; then
    echo "$target" >> "$BACKUP_DIR/alvos-existentes.txt"
  fi
done < "$BACKUP_DIR/arquivos-rootfs.txt"
if [[ -s "$BACKUP_DIR/alvos-existentes.txt" ]]; then
  tar -czf "$BACKUP_DIR/alvos-existentes-${STAMP}.tar.gz" -T "$BACKUP_DIR/alvos-existentes.txt"
  ls -lh "$BACKUP_DIR/alvos-existentes-${STAMP}.tar.gz"
else
  echo "Nenhum alvo existente a empacotar."
fi
backup_file "$CKAN_INI"
backup_file "$NGINX_SITE"
backup_dir_tar /etc/ckan/custom etc_ckan_custom || true

step 19 "APLICANDO ROOTFS DA CUSTOMIZAÇÃO"
cd "$REPO_DIR"
rsync -aHv \
  --exclude='etc/ckan/ckan.ini' \
  --exclude='etc/letsencrypt/' \
  --exclude='*.bak' \
  --exclude='*.bkp' \
  --exclude='*.BKP' \
  --exclude='*.pyc' \
  --exclude='__pycache__/' \
  --exclude='*.egg-info/' \
  rootfs/ /
echo "OK: rootfs aplicado sem substituir o ckan.ini real."

step 20 "AJUSTANDO PERMISSÕES DA CUSTOMIZAÇÃO"
chown -R "$CKAN_USER:$CKAN_GROUP" /etc/ckan 2>/dev/null || true
chown -R "$CKAN_USER:$CKAN_GROUP" "$CKAN_STORAGE_PATH" 2>/dev/null || true
chown -R "$CKAN_USER:$CKAN_GROUP" /opt/ckan 2>/dev/null || true
chown -R "$CKAN_USER:$CKAN_GROUP" "$CKAN_INSTALL_DIR/venv/src" 2>/dev/null || true
find /etc/ckan -type d -exec chmod 755 {} \; 2>/dev/null || true
find /etc/ckan -type f -exec chmod 644 {} \; 2>/dev/null || true
chmod 640 "$CKAN_INI" || true

step 21 "INSTALANDO CKANEXT-SCHEMING"
SRC_DIR="$CKAN_INSTALL_DIR/venv/src"
SCHEMING_DIR="$SRC_DIR/ckanext-scheming"
CUSTOM_PRESET="$SCHEMING_DIR/ckanext/scheming/scheming_presets_custom.json"
TMP_PRESET="/tmp/scheming_presets_custom_${STAMP}.json"
mkdir -p "$SRC_DIR"
chown -R "$CKAN_USER:$CKAN_GROUP" "$SRC_DIR"
if [[ -f "$CUSTOM_PRESET" ]]; then
  cp -a "$CUSTOM_PRESET" "$TMP_PRESET"
  echo "Preset custom preservado em $TMP_PRESET"
fi
run_as_ckan "
set -e
source '$CKAN_INSTALL_DIR/venv/bin/activate'
cd '$SRC_DIR'
if [ ! -d '$SCHEMING_DIR/.git' ]; then
  rm -rf '$SCHEMING_DIR'
  git clone --branch '$SCHEMING_GIT_BRANCH' '$SCHEMING_GIT_URL' '$SCHEMING_DIR'
fi
cd '$SCHEMING_DIR'
git fetch origin || true
git checkout '$SCHEMING_GIT_BRANCH' || true
pip install -e .
"
if [[ -f "$TMP_PRESET" ]]; then
  cp -a "$TMP_PRESET" "$CUSTOM_PRESET"
  chown "$CKAN_USER:$CKAN_GROUP" "$CUSTOM_PRESET"
fi

step 22 "INSTALANDO EXTENSÕES SFB EM MODO EDITABLE"
for ext in $SFB_EXTS; do
  echo
  echo ">>> $ext"
  if [[ -d "$SRC_DIR/$ext" ]]; then
    chown -R "$CKAN_USER:$CKAN_GROUP" "$SRC_DIR/$ext"
    run_as_ckan "source '$CKAN_INSTALL_DIR/venv/bin/activate'; cd '$SRC_DIR/$ext'; pip install -e ."
  else
    fail "extensão ausente: $SRC_DIR/$ext"
  fi
done

step 23 "CONFIGURANDO CKAN.INI CUSTOMIZADO"
backup_file "$CKAN_INI"
write_ini_settings "custom"
chown "$CKAN_USER:$CKAN_GROUP" "$CKAN_INI"
chmod 640 "$CKAN_INI"
grep -nE '^[[:space:]]*(ckan.site_url|ckan.plugins|extra_template_paths|extra_public_paths|ckan.locale_default|ckan.i18n.extra_|scheming\.|ckanext.sfb_group_sync|ckan.max_resource_size)' "$CKAN_INI" || true

step 24 "COMPILANDO TRADUÇÕES"
if [[ "${COMPILE_TRANSLATIONS,,}" == "true" ]]; then
  find /opt/ckan/extra_translations -type f -name '*.po' 2>/dev/null | while read -r po; do
    mo="${po%.po}.mo"
    echo "Compilando: $po -> $mo"
    msgfmt "$po" -o "$mo"
    chown "$CKAN_USER:$CKAN_GROUP" "$po" "$mo"
  done
  CORE_PO="$CKAN_SRC_DIR/ckan/i18n/pt_BR/LC_MESSAGES/ckan.po"
  CORE_MO="$CKAN_SRC_DIR/ckan/i18n/pt_BR/LC_MESSAGES/ckan.mo"
  if [[ -f "$CORE_PO" ]]; then
    echo "Compilando tradução principal: $CORE_PO -> $CORE_MO"
    msgfmt "$CORE_PO" -o "$CORE_MO"
    chown "$CKAN_USER:$CKAN_GROUP" "$CORE_PO" "$CORE_MO"
  fi
else
  echo "COMPILE_TRANSLATIONS=false. Pulando."
fi

step 25 "LIMPANDO CSS CUSTOM DA UI, SE CONFIGURADO"
if [[ "${CLEAR_UI_CUSTOM_CSS,,}" == "true" ]]; then
  run_as_ckan "
  source '$CKAN_INSTALL_DIR/venv/bin/activate'
  ckan -c '$CKAN_INI' shell <<'PY'
from ckan import model
from sqlalchemy import text
for key in ['ckan.site_custom_css']:
    try:
        model.Session.execute(text('UPDATE system_info SET value = :value WHERE key = :key'), {'value': '', 'key': key})
        print('OK limpo:', key)
    except Exception as e:
        print('AVISO:', key, repr(e))
model.Session.commit()
PY
  " || echo "AVISO: limpeza de CSS via shell falhou. Continuando."
else
  echo "CLEAR_UI_CUSTOM_CSS=false. Pulando."
fi

step 26 "CONFIGURANDO SYSTEMD DO CKAN EM LOCALHOST"
backup_file "/etc/systemd/system/${CKAN_SERVICE}.service"
mkdir -p "/etc/systemd/system/${CKAN_SERVICE}.service.d"
cat > "/etc/systemd/system/${CKAN_SERVICE}.service" <<EOF2
[Unit]
Description=CKAN Web Application
After=network.target

[Service]
Type=simple
User=${CKAN_USER}
Group=${CKAN_GROUP}
WorkingDirectory=${CKAN_SRC_DIR}
Environment="CKAN_INI=${CKAN_INI}"
ExecStart=${CKAN_INSTALL_DIR}/venv/bin/ckan -c ${CKAN_INI} run --host ${CKAN_HOST} --port ${CKAN_PORT}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF2
cat > "/etc/systemd/system/${CKAN_SERVICE}.service.d/20-wait-solr.conf" <<EOF2
[Unit]
Wants=${SOLR_SERVICE}.service
After=${SOLR_SERVICE}.service

[Service]
ExecStartPre=/bin/bash -lc 'for i in {1..60}; do curl -fsS http://${SOLR_HOST}:${SOLR_PORT}/solr/${SOLR_CORE}/admin/ping >/dev/null && exit 0; sleep 1; done; echo "Solr core ${SOLR_CORE} não respondeu em 60s" >&2; exit 1'
EOF2
systemctl daemon-reload
systemctl enable "$CKAN_SERVICE"

step 27 "CONFIGURANDO NGINX"
apt install -y nginx certbot python3-certbot-nginx
backup_file "$NGINX_SITE"
mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled
cat > "$NGINX_SITE" <<EOF2
server {
    listen 80;
    server_name ${DOMAIN};

    client_max_body_size ${NGINX_CLIENT_MAX_BODY_SIZE};

    proxy_read_timeout ${NGINX_PROXY_READ_TIMEOUT};
    proxy_send_timeout ${NGINX_PROXY_SEND_TIMEOUT};
    proxy_connect_timeout ${NGINX_PROXY_CONNECT_TIMEOUT};

    location / {
        proxy_pass         http://${CKAN_HOST}:${CKAN_PORT}/;
        proxy_set_header   Host              \$host;
        proxy_set_header   X-Real-IP         \$remote_addr;
        proxy_set_header   X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}
EOF2
ln -sf "$NGINX_SITE" "$NGINX_SITE_ENABLED"
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl enable nginx
systemctl reload nginx || systemctl restart nginx

step 28 "CONFIGURANDO FIREWALL"
if [[ "${ENABLE_UFW,,}" == "true" ]]; then
  ufw allow "${SSH_PORT}/tcp"
  ufw allow 80/tcp
  if [[ "${ENABLE_HTTPS,,}" == "true" ]]; then
    ufw allow 443/tcp
  fi
  ufw deny "${CKAN_PORT}/tcp" || true
  ufw deny "${SOLR_PORT}/tcp" || true
  ufw deny 5432/tcp || true
  ufw deny "${REDIS_PORT}/tcp" || true
  ufw --force enable
  ufw status verbose
else
  echo "ENABLE_UFW=false. Pulando UFW."
fi

step 29 "VALIDANDO CONFIGURAÇÃO E IMPORTS"
run_as_ckan "source '$CKAN_INSTALL_DIR/venv/bin/activate'; ckan -c '$CKAN_INI' config validate"
run_as_ckan "
source '$CKAN_INSTALL_DIR/venv/bin/activate'
python - <<'PY'
mods = ['ckanext.scheming.plugins'] + '''$SFB_IMPORT_MODULES'''.split()
for mod in mods:
    __import__(mod)
    print('OK import:', mod)
PY
"
run_as_ckan "
source '$CKAN_INSTALL_DIR/venv/bin/activate'
ckan -c '$CKAN_INI' shell <<'PY'
import ckanext.scheming.helpers as sh
schema = sh.scheming_get_dataset_schema('dataset')
print('SCHEMA_OK =', bool(schema))
print('dataset_type =', schema.get('dataset_type'))
print('dataset_fields =', len(schema.get('dataset_fields', [])))
PY
"

step 30 "REINICIANDO SERVIÇOS E ATIVANDO HTTPS"
systemctl daemon-reload
systemctl enable "$SOLR_SERVICE" "$CKAN_SERVICE" nginx || true
systemctl restart "$SOLR_SERVICE"
wait_http "http://${SOLR_HOST}:${SOLR_PORT}/solr/${SOLR_CORE}/admin/ping" 60 "Solr" || fail "Solr não respondeu."
systemctl restart "$CKAN_SERVICE"
wait_http "http://${CKAN_HOST}:${CKAN_PORT}/api/3/action/status_show" 90 "CKAN local" || {
  systemctl --no-pager --full status "$CKAN_SERVICE" || true
  journalctl -u "$CKAN_SERVICE" --no-pager -n 160 || true
  fail "CKAN não respondeu localmente."
}

if [[ "${ENABLE_HTTPS,,}" == "true" ]]; then
  if [[ -n "${EXPECTED_DNS_IP:-}" ]]; then
    DNS_CF="$(dig @1.1.1.1 +short "$DOMAIN" A | tail -1 || true)"
    echo "DNS Cloudflare: ${DNS_CF:-vazio}; esperado: $EXPECTED_DNS_IP"
  fi
  if [[ -n "${CERTBOT_EMAIL:-}" ]]; then
    CERTBOT_ACCOUNT_ARGS=(--email "$CERTBOT_EMAIL")
  else
    CERTBOT_ACCOUNT_ARGS=(--register-unsafely-without-email)
  fi
  certbot --nginx \
    -d "$DOMAIN" \
    --redirect \
    --non-interactive \
    --agree-tos \
    "${CERTBOT_ACCOUNT_ARGS[@]}"
  nginx -t
  systemctl reload nginx
else
  echo "ENABLE_HTTPS=false. Mantendo HTTP."
fi

if [[ "${REINDEX_SEARCH,,}" == "true" ]]; then
  run_as_ckan "source '$CKAN_INSTALL_DIR/venv/bin/activate'; ckan -c '$CKAN_INI' search-index rebuild"
else
  echo "REINDEX_SEARCH=false. Pulando reindex."
fi

step 31 "VALIDAÇÃO FINAL"
echo "--- CKAN API local:"
curl -fsS "http://${CKAN_HOST}:${CKAN_PORT}/api/3/action/status_show" | python3 -m json.tool | sed -n '1,120p'

echo
echo "--- Teste via domínio:"
if [[ "${ENABLE_HTTPS,,}" == "true" ]]; then
  curl -I -k -s --connect-timeout 15 "https://${DOMAIN}/" | sed -n '1,16p'
  curl -I -k -s --connect-timeout 15 "https://${DOMAIN}/dataset/" | sed -n '1,16p'
else
  curl -I -s --connect-timeout 15 "http://${DOMAIN}/" | sed -n '1,16p'
  curl -I -s --connect-timeout 15 "http://${DOMAIN}/dataset/" | sed -n '1,16p'
fi

echo
echo "--- Assets principais:"
for url in \
  "${SITE_SCHEME}://${DOMAIN}/css/sfb-custom-global.css" \
  "${SITE_SCHEME}://${DOMAIN}/css/sfb-home-hero.css" \
  "${SITE_SCHEME}://${DOMAIN}/sfb_facets_collapsible.css"; do
  echo "--- $url"
  curl -I -k -s --connect-timeout 15 "$url" | sed -n '1,8p' || true
done

echo
echo "--- Portas relevantes:"
ss -lntp | grep -E ":(${CKAN_PORT}|${SOLR_PORT}|80|443|5432|${REDIS_PORT})\b" || true

echo
echo "--- Serviços:"
systemctl --no-pager --full status "$SOLR_SERVICE" "$CKAN_SERVICE" nginx | sed -n '1,220p' || true

echo
echo "============================================================"
echo "INSTALAÇÃO CKAN + CUSTOMIZAÇÃO SFB CONCLUÍDA COM SUCESSO"
echo "URL: $SITE_URL"
echo "Log: $LOG_FILE"
echo "Backup: $BACKUP_DIR"
echo "Vars: $VARS_FILE"
echo "============================================================"
