#!/usr/bin/env bash
set -Eeuo pipefail
umask 022

# ============================================================
# INSTALAÇÃO DA CUSTOMIZAÇÃO CKAN SFB A PARTIR DO GIT
# Ubuntu 24.04 LTS + CKAN 2.10.7 já instalado
# ============================================================

VARS_FILE="${1:-/root/ckan-sfb-custom.vars}"

if [ ! -f "$VARS_FILE" ]; then
  echo "ERRO: arquivo de variáveis não encontrado: $VARS_FILE"
  exit 1
fi

# shellcheck disable=SC1090
source "$VARS_FILE"

STAMP="$(date +%F_%H-%M-%S)"
LOG_DIR="/var/log/ckan-sfb-custom"
LOG_FILE="$LOG_DIR/install_${STAMP}.log"
REPO_DIR="$WORKDIR/repo"
BACKUP_DIR="/root/ckan-sfb-custom-backups/backup_${STAMP}"

mkdir -p "$LOG_DIR" "$BACKUP_DIR"

exec > >(tee -a "$LOG_FILE") 2>&1

step() {
  echo
  echo "----------[$1/$2] $3 ----------"
}

fail() {
  echo
  echo "ERRO: $*"
  echo "Log: $LOG_FILE"
  exit 1
}

backup_file() {
  local f="$1"
  if [ -e "$f" ]; then
    cp -a "$f" "${f}$(date +%F_%H-%M-%S).bak"
    echo "Backup: ${f}$(date +%F_%H-%M-%S).bak"
  fi
}

require_file() {
  local f="$1"
  [ -f "$f" ] || fail "arquivo obrigatório ausente: $f"
}

require_dir() {
  local d="$1"
  [ -d "$d" ] || fail "diretório obrigatório ausente: $d"
}

run_as_ckan() {
  sudo -u "$CKAN_USER" -H bash -lc "$*"
}

SITE_SCHEME="http"
if [ "${ENABLE_HTTPS,,}" = "true" ]; then
  SITE_SCHEME="https"
fi
SITE_URL="${SITE_SCHEME}://${DOMAIN}"

TOTAL=22

step 1 "$TOTAL" "INÍCIO E VARIÁVEIS"
echo "Data: $(date)"
echo "Host: $(hostname)"
echo "VARS_FILE=$VARS_FILE"
echo "LOG_FILE=$LOG_FILE"
echo "REPO=$GIT_REPO_URL"
echo "BRANCH=$GIT_BRANCH"
echo "DOMAIN=$DOMAIN"
echo "SITE_URL=$SITE_URL"
echo "WORKDIR=$WORKDIR"
echo "BACKUP_DIR=$BACKUP_DIR"

step 2 "$TOTAL" "VALIDANDO AMBIENTE CKAN"
require_file "$CKAN_INI"
require_dir "$CKAN_VENV"
require_file "$CKAN_VENV/bin/python"
require_file "$CKAN_VENV/bin/pip"

if ! id "$CKAN_USER" >/dev/null 2>&1; then
  fail "usuário CKAN não existe: $CKAN_USER"
fi

"$CKAN_VENV/bin/python" --version
"$CKAN_VENV/bin/pip" --version

if systemctl list-unit-files | grep -q "^${CKAN_SERVICE}.service"; then
  echo "OK: serviço CKAN encontrado: $CKAN_SERVICE"
else
  fail "serviço CKAN não encontrado: $CKAN_SERVICE"
fi

step 3 "$TOTAL" "INSTALANDO DEPENDÊNCIAS DO SISTEMA"
export DEBIAN_FRONTEND=noninteractive

apt update
apt install -y \
  git \
  rsync \
  curl \
  ca-certificates \
  gettext \
  nginx \
  certbot \
  python3-certbot-nginx \
  ufw \
  dnsutils \
  jq

step 4 "$TOTAL" "CHECANDO DNS DO DOMÍNIO"
echo "Domínio: $DOMAIN"

echo "--- DNS Cloudflare:"
dig @1.1.1.1 +short "$DOMAIN" A || true

echo "--- DNS Google:"
dig @8.8.8.8 +short "$DOMAIN" A || true

if [ -n "${EXPECTED_DNS_IP:-}" ]; then
  DNS_CF="$(dig @1.1.1.1 +short "$DOMAIN" A | tail -1 || true)"
  if [ "$DNS_CF" = "$EXPECTED_DNS_IP" ]; then
    echo "OK: DNS público aponta para EXPECTED_DNS_IP=$EXPECTED_DNS_IP"
  else
    echo "AVISO: DNS Cloudflare retornou '$DNS_CF', esperado '$EXPECTED_DNS_IP'"
    echo "Continuando, pois pode ser IP direto, cache ou teste controlado."
  fi
fi

step 5 "$TOTAL" "CLONANDO OU ATUALIZANDO REPOSITÓRIO GIT"
mkdir -p "$WORKDIR"

if [ -d "$REPO_DIR/.git" ]; then
  echo "Repo já existe. Atualizando."
  cd "$REPO_DIR"
  git fetch origin
  git checkout "$GIT_BRANCH"
  git pull origin "$GIT_BRANCH"
else
  rm -rf "$REPO_DIR"
  git clone --branch "$GIT_BRANCH" "$GIT_REPO_URL" "$REPO_DIR"
  cd "$REPO_DIR"
fi

echo "--- Commit usado:"
git log --oneline -1

require_dir "$REPO_DIR/rootfs"

step 6 "$TOTAL" "BACKUP DOS ARQUIVOS QUE SERÃO SOBREPOSTOS"
cd "$REPO_DIR"

find rootfs -type f | sed 's#^rootfs##' | sort > "$BACKUP_DIR/arquivos-rootfs.txt"

: > "$BACKUP_DIR/alvos-existentes.txt"
while IFS= read -r rel; do
  target="$rel"
  if [ -e "$target" ]; then
    echo "$target" >> "$BACKUP_DIR/alvos-existentes.txt"
  fi
done < "$BACKUP_DIR/arquivos-rootfs.txt"

echo "Arquivos no rootfs:"
wc -l "$BACKUP_DIR/arquivos-rootfs.txt"

echo "Arquivos existentes que serão sobrescritos:"
wc -l "$BACKUP_DIR/alvos-existentes.txt"

if [ -s "$BACKUP_DIR/alvos-existentes.txt" ]; then
  tar -czf "$BACKUP_DIR/alvos-existentes-${STAMP}.tar.gz" -T "$BACKUP_DIR/alvos-existentes.txt"
  ls -lh "$BACKUP_DIR/alvos-existentes-${STAMP}.tar.gz"
fi

cp -a "$CKAN_INI" "$BACKUP_DIR/ckan.ini.original"
cp -a "$CKAN_INI" "${CKAN_INI}$(date +%F_%H-%M-%S).bak"

if [ -f "$NGINX_SITE" ]; then
  cp -a "$NGINX_SITE" "$BACKUP_DIR/nginx-site.original"
  cp -a "$NGINX_SITE" "${NGINX_SITE}$(date +%F_%H-%M-%S).bak"
fi

step 7 "$TOTAL" "APLICANDO ROOTFS DO REPOSITÓRIO"
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

step 8 "$TOTAL" "AJUSTANDO PERMISSÕES"
chown -R "$CKAN_USER:$CKAN_GROUP" /etc/ckan 2>/dev/null || true
chown -R "$CKAN_USER:$CKAN_GROUP" "$CKAN_STORAGE_PATH" 2>/dev/null || true
chown -R "$CKAN_USER:$CKAN_GROUP" /opt/ckan 2>/dev/null || true
chown -R "$CKAN_USER:$CKAN_GROUP" "$CKAN_VENV/src" 2>/dev/null || true

find /etc/ckan -type d -exec chmod 755 {} \; 2>/dev/null || true
find /etc/ckan -type f -exec chmod 644 {} \; 2>/dev/null || true

step 9 "$TOTAL" "INSTALANDO CKANEXT-SCHEMING"
SRC_DIR="$CKAN_VENV/src"
SCHEMING_DIR="$SRC_DIR/ckanext-scheming"
CUSTOM_PRESET="$SCHEMING_DIR/ckanext/scheming/scheming_presets_custom.json"
TMP_PRESET="/tmp/scheming_presets_custom_${STAMP}.json"

mkdir -p "$SRC_DIR"
chown -R "$CKAN_USER:$CKAN_GROUP" "$SRC_DIR"

if [ -f "$CUSTOM_PRESET" ]; then
  cp -a "$CUSTOM_PRESET" "$TMP_PRESET"
  echo "Preset custom preservado em $TMP_PRESET"
fi

run_as_ckan "
set -e
source '$CKAN_VENV/bin/activate'
cd '$SRC_DIR'
if [ ! -d '$SCHEMING_DIR/.git' ]; then
  rm -rf '$SCHEMING_DIR'
  git clone https://github.com/ckan/ckanext-scheming.git '$SCHEMING_DIR'
fi
cd '$SCHEMING_DIR'
pip install -e .
"

if [ -f "$TMP_PRESET" ]; then
  cp -a "$TMP_PRESET" "$CUSTOM_PRESET"
  chown "$CKAN_USER:$CKAN_GROUP" "$CUSTOM_PRESET"
fi

if [ ! -f "$CUSTOM_PRESET" ]; then
  echo "AVISO: preset custom não encontrado em $CUSTOM_PRESET"
  echo "Se o YAML depender de preset customizado, o validate vai falhar."
fi

step 10 "$TOTAL" "INSTALANDO EXTENSÕES SFB EM MODO EDITABLE"
SFB_EXTS=(
  "ckanext-sfb_access"
  "ckanext-sfb_facets_multi"
  "ckanext-sfb_geo_facet"
  "ckanext-sfb_group_sync"
  "ckanext-sfbdraftsearch"
  "ckanext-sfbgroups"
)

for ext in "${SFB_EXTS[@]}"; do
  echo
  echo ">>> $ext"
  if [ -d "$SRC_DIR/$ext" ]; then
    chown -R "$CKAN_USER:$CKAN_GROUP" "$SRC_DIR/$ext"
    run_as_ckan "
      set -e
      source '$CKAN_VENV/bin/activate'
      cd '$SRC_DIR/$ext'
      pip install -e .
    "
  else
    fail "extensão ausente: $SRC_DIR/$ext"
  fi
done

step 11 "$TOTAL" "CONFIGURANDO CKAN.INI NA SEÇÃO APP:MAIN"
python3 <<PY
from pathlib import Path
import re

ini = Path("$CKAN_INI")
lines = ini.read_text(errors="replace").splitlines()

settings = {
    "ckan.site_url": "$SITE_URL",
    "ckan.plugins": "$CKAN_PLUGINS",
    "ckan.storage_path": "$CKAN_STORAGE_PATH",
    "ckan.max_resource_size": "300",
    "ckan.resource_proxy.max_file_size": "314572800",
    "ckan.theme": "css/main",
    "extra_template_paths": "/etc/ckan/custom/templates",
    "extra_public_paths": "/etc/ckan/custom/public, /etc/ckan/public",
    "ckan.locale_default": "$CKAN_LOCALE_DEFAULT",
    "ckan.locales_offered": "$CKAN_LOCALES_OFFERED",
    "ckan.locale_order": "$CKAN_LOCALE_ORDER",
    "ckan.i18n.extra_directory": "$CKAN_I18N_EXTRA_DIRECTORY",
    "ckan.i18n.extra_gettext_domain": "$CKAN_I18N_EXTRA_GETTEXT_DOMAIN",
    "ckan.i18n.extra_locales": "$CKAN_I18N_EXTRA_LOCALES",
    "scheming.presets": "$SCHEMING_PRESETS",
    "scheming.dataset_schemas": "$SCHEMING_DATASET_SCHEMAS",
    "scheming.dataset_fallback": "$SCHEMING_DATASET_FALLBACK",
    "ckanext.sfb_group_sync.fields": "sfb_grupo,grupos,grupo,grupo_de_usuarios",
}

def is_target(line):
    s = line.strip()
    return any(s.startswith(k + " ") or s.startswith(k + "=") for k in settings)

clean = [line for line in lines if not is_target(line)]

app_start = None
for i, line in enumerate(clean):
    if line.strip() == "[app:main]":
        app_start = i
        break

if app_start is None:
    raise SystemExit("ERRO: seção [app:main] não encontrada em $CKAN_INI")

insert_at = app_start + 1

block = [
    "",
    "## SFB custom settings - instalado por install_ckan_sfb_custom_from_git.sh",
]
for key, value in settings.items():
    block.append(f"{key} = {value}")

new_lines = clean[:insert_at] + block + clean[insert_at:]
ini.write_text("\\n".join(new_lines) + "\\n")
PY

grep -nE '^[[:space:]]*(ckan\.site_url|ckan\.plugins|extra_template_paths|extra_public_paths|ckan\.locale_default|ckan\.i18n\.extra_|scheming\.|ckanext\.sfb_group_sync)' "$CKAN_INI" || true

step 12 "$TOTAL" "COMPILANDO TRADUÇÕES"
if [ "${COMPILE_TRANSLATIONS,,}" = "true" ]; then
  find /opt/ckan/extra_translations -type f -name '*.po' 2>/dev/null | while read -r po; do
    mo="${po%.po}.mo"
    echo "Compilando: $po -> $mo"
    msgfmt "$po" -o "$mo"
    chown "$CKAN_USER:$CKAN_GROUP" "$po" "$mo"
  done

  CORE_PO="/usr/lib/ckan/ckan/ckan/i18n/pt_BR/LC_MESSAGES/ckan.po"
  CORE_MO="/usr/lib/ckan/ckan/ckan/i18n/pt_BR/LC_MESSAGES/ckan.mo"

  if [ -f "$CORE_PO" ]; then
    echo "Compilando tradução principal CKAN: $CORE_PO -> $CORE_MO"
    msgfmt "$CORE_PO" -o "$CORE_MO"
    chown "$CKAN_USER:$CKAN_GROUP" "$CORE_PO" "$CORE_MO"
  fi
else
  echo "COMPILE_TRANSLATIONS=false. Pulando compilação."
fi

step 13 "$TOTAL" "LIMPANDO CSS DE FACHADA DA UI DO CKAN"
if [ "${CLEAR_UI_CUSTOM_CSS,,}" = "true" ]; then
  run_as_ckan "
  source '$CKAN_VENV/bin/activate'
  ckan -c '$CKAN_INI' shell <<'PY'
from ckan import model
from sqlalchemy import text

keys = [
    'ckan.site_custom_css',
]

for key in keys:
    try:
        model.Session.execute(
            text('UPDATE system_info SET value = :value WHERE key = :key'),
            {'value': '', 'key': key}
        )
        print('OK limpo:', key)
    except Exception as e:
        print('AVISO ao limpar', key, repr(e))

model.Session.commit()
PY
  " || echo "AVISO: não foi possível limpar ckan.site_custom_css via shell."
else
  echo "CLEAR_UI_CUSTOM_CSS=false. Pulando limpeza."
fi

step 14 "$TOTAL" "CONFIGURANDO SYSTEMD: CKAN LOCALHOST E ESPERA DO SOLR"
mkdir -p "/etc/systemd/system/${CKAN_SERVICE}.service.d"

cat > "/etc/systemd/system/${CKAN_SERVICE}.service.d/20-wait-solr.conf" <<EOF
[Unit]
Wants=${SOLR_SERVICE}.service
After=${SOLR_SERVICE}.service

[Service]
ExecStartPre=/bin/bash -lc 'for i in {1..60}; do curl -fsS http://${SOLR_HOST}:${SOLR_PORT}/solr/${SOLR_CORE}/admin/ping >/dev/null && exit 0; sleep 1; done; echo "Solr core ${SOLR_CORE} não respondeu em 60s" >&2; exit 1'
EOF

cat > "/etc/systemd/system/${CKAN_SERVICE}.service.d/99-bind-local.conf" <<EOF
[Service]
ExecStart=
ExecStart=${CKAN_VENV}/bin/ckan -c ${CKAN_INI} run --host ${CKAN_HOST} --port ${CKAN_PORT}
EOF

systemctl daemon-reload

step 15 "$TOTAL" "CONFIGURANDO NGINX"
mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled

cat > "$NGINX_SITE" <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    client_max_body_size ${NGINX_CLIENT_MAX_BODY_SIZE};

    location / {
        proxy_pass         http://${CKAN_HOST}:${CKAN_PORT}/;
        proxy_set_header   Host              \$host;
        proxy_set_header   X-Real-IP         \$remote_addr;
        proxy_set_header   X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}
EOF

ln -sf "$NGINX_SITE" "$NGINX_SITE_ENABLED"
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl enable nginx
systemctl reload nginx || systemctl restart nginx

step 16 "$TOTAL" "CONFIGURANDO FIREWALL LOCAL"
if [ "${ENABLE_UFW,,}" = "true" ]; then
  ufw allow "${SSH_PORT}/tcp"
  ufw allow 80/tcp

  if [ "${ENABLE_HTTPS,,}" = "true" ]; then
    ufw allow 443/tcp
  fi

  ufw deny "${CKAN_PORT}/tcp" || true
  ufw deny "${SOLR_PORT}/tcp" || true
  ufw deny 5432/tcp || true
  ufw deny 6379/tcp || true

  ufw --force enable
  ufw status verbose
else
  echo "ENABLE_UFW=false. Pulando UFW."
fi

step 17 "$TOTAL" "VALIDANDO CKAN ANTES DO RESTART"
run_as_ckan "
source '$CKAN_VENV/bin/activate'
ckan -c '$CKAN_INI' config validate
"
echo "OK: ckan config validate retornou sucesso."

step 18 "$TOTAL" "TESTANDO SCHEMING E IMPORTS"
run_as_ckan "
source '$CKAN_VENV/bin/activate'
python - <<'PY'
mods = [
    'ckanext.scheming.plugins',
    'ckanext.sfb_access.plugin',
    'ckanext.sfb_facets_multi.plugin',
    'ckanext.sfb_geo_facet.plugin',
    'ckanext.sfb_group_sync.plugin',
    'ckanext.sfbdraftsearch.plugin',
    'ckanext.sfbgroups.plugin',
]
for mod in mods:
    __import__(mod)
    print('OK import:', mod)
PY
"

run_as_ckan "
source '$CKAN_VENV/bin/activate'
ckan -c '$CKAN_INI' shell <<'PY'
import ckanext.scheming.helpers as sh
schema = sh.scheming_get_dataset_schema('dataset')
print('SCHEMA_OK =', bool(schema))
print('dataset_type =', schema.get('dataset_type'))
print('dataset_fields =', len(schema.get('dataset_fields', [])))
PY
"

step 19 "$TOTAL" "REINICIANDO SERVIÇOS"
systemctl daemon-reload
systemctl enable "$SOLR_SERVICE" "$CKAN_SERVICE" nginx || true

systemctl restart "$SOLR_SERVICE"

echo "Aguardando Solr..."
for i in $(seq 1 60); do
  if curl -fsS "http://${SOLR_HOST}:${SOLR_PORT}/solr/${SOLR_CORE}/admin/ping" >/dev/null 2>&1; then
    echo "OK: Solr respondeu."
    break
  fi
  if [ "$i" -eq 60 ]; then
    systemctl --no-pager --full status "$SOLR_SERVICE" || true
    fail "Solr não respondeu em 60s."
  fi
  sleep 1
done

systemctl restart "$CKAN_SERVICE"

echo "Aguardando CKAN local..."
for i in $(seq 1 90); do
  if curl -fsS "http://${CKAN_HOST}:${CKAN_PORT}/api/3/action/status_show" >/dev/null 2>&1; then
    echo "OK: CKAN respondeu localmente."
    break
  fi
  if [ "$i" -eq 90 ]; then
    systemctl --no-pager --full status "$CKAN_SERVICE" || true
    journalctl -u "$CKAN_SERVICE" --no-pager -n 120 || true
    fail "CKAN não respondeu localmente em 90s."
  fi
  sleep 1
done

step 20 "$TOTAL" "ATIVANDO HTTPS COM CERTBOT"
if [ "${ENABLE_HTTPS,,}" = "true" ]; then
  sed -i "/[[:space:]]${DOMAIN}$/d" /etc/hosts || true

  if [ -n "${CERTBOT_EMAIL:-}" ]; then
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
  echo "ENABLE_HTTPS=false. Mantendo apenas HTTP."
fi

step 21 "$TOTAL" "REINDEX OPCIONAL"
if [ "${REINDEX_SEARCH,,}" = "true" ]; then
  run_as_ckan "
  source '$CKAN_VENV/bin/activate'
  ckan -c '$CKAN_INI' search-index rebuild
  "
else
  echo "REINDEX_SEARCH=false. Pulando reindex."
fi

step 22 "$TOTAL" "VALIDAÇÃO FINAL"
echo "--- Status API local:"
curl -fsS "http://${CKAN_HOST}:${CKAN_PORT}/api/3/action/status_show" | python3 -m json.tool | sed -n '1,120p'

echo
echo "--- Status via domínio:"
if [ "${ENABLE_HTTPS,,}" = "true" ]; then
  curl -I -k -s --connect-timeout 15 "https://${DOMAIN}/" | sed -n '1,16p'
  curl -I -k -s --connect-timeout 15 "https://${DOMAIN}/dataset/" | sed -n '1,16p'
else
  curl -I -s --connect-timeout 15 "http://${DOMAIN}/" | sed -n '1,16p'
  curl -I -s --connect-timeout 15 "http://${DOMAIN}/dataset/" | sed -n '1,16p'
fi

echo
echo "--- Assets principais:"
ASSET_SCHEME="$SITE_SCHEME"
for url in \
  "${ASSET_SCHEME}://${DOMAIN}/css/sfb-custom-global.css" \
  "${ASSET_SCHEME}://${DOMAIN}/css/sfb-home-hero.css" \
  "${ASSET_SCHEME}://${DOMAIN}/sfb_facets_collapsible.css"
do
  echo "--- $url"
  curl -I -k -s --connect-timeout 15 "$url" | sed -n '1,8p'
done

echo
echo "--- Portas:"
ss -lntp | grep -E ":(${CKAN_PORT}|${SOLR_PORT}|80|443|5432|6379)\b" || true

echo
echo "--- Serviços:"
systemctl --no-pager --full status "$SOLR_SERVICE" "$CKAN_SERVICE" nginx | sed -n '1,180p'

echo
echo "============================================================"
echo "CUSTOMIZAÇÃO CKAN SFB INSTALADA COM SUCESSO"
echo "URL: $SITE_URL"
echo "Log: $LOG_FILE"
echo "Backup: $BACKUP_DIR"
echo "============================================================"
