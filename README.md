# Instalação do CKAN SFB

Este repositório contém um script único para instalar o CKAN e aplicar a customização do projeto SFB.

O processo instala:

- CKAN
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
install_ckan_sfb_full.sh
```

O arquivo de parâmetros é:

```text
install_ckan_sfb_full.vars
```

Os dois arquivos devem ficar na mesma pasta. O script procura automaticamente o arquivo `.vars` com o mesmo nome-base do `.sh`.

---

## 1. Quando usar este instalador

Use este instalador para uma instalação nova do CKAN SFB em uma máquina limpa.

Ele é recomendado para:

- VM nova
- ambiente de homologação
- ambiente de produção recém-criado
- reinstalação completa do CKAN SFB

Evite rodar este script diretamente em um servidor CKAN já em uso, com dados reais, sem antes fazer backup completo.

O script instala e altera serviços importantes do servidor, incluindo PostgreSQL, Solr, Redis, Nginx, Certbot e firewall.

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
- 8 GB de RAM
- 100 GB de disco ou mais

### Domínio

Para instalação com HTTPS, o domínio precisa apontar para o IP público do servidor antes da execução do script.

Exemplo:

```text
custom.ckan.exemplo.com.br -> IP_PUBLICO_DA_VM
```

Se o domínio ainda não estiver apontando corretamente, o Certbot não conseguirá emitir o certificado HTTPS.

---

## 3. Baixar o repositório no servidor

Acesse a VM via SSH e clone este repositório.

```bash
clear
echo '===============INÍCIO==============='
cd /root
git clone <URL_DO_REPOSITORIO>
cd <PASTA_DO_REPOSITORIO>
echo '===============FIM=================='
```

Exemplo:

```bash
clear
echo '===============INÍCIO==============='
cd /root
git clone https://github.com/usuario/repositorio_sfb.git
cd repositorio_sfb
echo '===============FIM=================='
```

---

## 4. Conferir os arquivos do instalador

Dentro da pasta do repositório, confira se os dois arquivos existem:

```bash
clear
echo '===============INÍCIO==============='
ls -lh install_ckan_sfb_full.sh install_ckan_sfb_full.vars
echo '===============FIM=================='
```

Resultado esperado:

```text
install_ckan_sfb_full.sh
install_ckan_sfb_full.vars
```

---

## 5. Editar o arquivo `.vars`

Antes de rodar a instalação, edite o arquivo de variáveis:

```bash
clear
echo '===============INÍCIO==============='
nano install_ckan_sfb_full.vars
echo '===============FIM=================='
```

Esse arquivo concentra os dados que podem mudar de uma instalação para outra.

Atenção especial para estes campos:

```bash
DOMAIN="custom.ckan.exemplo.gov.br"
ENABLE_HTTPS="true"
CERTBOT_EMAIL="email@exemplo.gov.br"
EXPECTED_DNS_IP="IP_PUBLICO_DA_VM"
```

Também revise os usuários e senhas:

```bash
CKAN_DB_NAME="ckan_default"
CKAN_DB_USER="ckan_default"
CKAN_DB_PASSWORD="troque_esta_senha"

CKAN_SYSADMIN_NAME="ckanadmin"
CKAN_SYSADMIN_EMAIL="admin@exemplo.gov.br"
CKAN_SYSADMIN_PASSWORD="troque_esta_senha"
```

E confira o repositório Git usado para aplicar a customização:

```bash
GIT_REPO_URL="https://github.com/usuario/repositorio_sfb.git"
GIT_BRANCH="main"
```

---

## 6. Principais variáveis do `.vars`

### Domínio e HTTPS

| Variável | Para que serve |
|---|---|
| `DOMAIN` | Domínio público do CKAN |
| `ENABLE_HTTPS` | Ativa ou desativa HTTPS com Certbot |
| `CERTBOT_EMAIL` | E-mail usado no Let's Encrypt |
| `EXPECTED_DNS_IP` | IP esperado no DNS, usado para conferência |

### Banco de dados

| Variável | Para que serve |
|---|---|
| `CKAN_DB_NAME` | Nome do banco PostgreSQL do CKAN |
| `CKAN_DB_USER` | Usuário PostgreSQL do CKAN |
| `CKAN_DB_PASSWORD` | Senha do usuário PostgreSQL |

### Usuário administrador do CKAN

| Variável | Para que serve |
|---|---|
| `CKAN_SYSADMIN_NAME` | Nome do usuário administrador |
| `CKAN_SYSADMIN_EMAIL` | E-mail do administrador |
| `CKAN_SYSADMIN_PASSWORD` | Senha inicial do administrador |

### CKAN

| Variável | Para que serve |
|---|---|
| `CKAN_USER` | Usuário Linux que executará o CKAN |
| `CKAN_GROUP` | Grupo Linux do CKAN |
| `CKAN_INSTALL_DIR` | Diretório principal da instalação |
| `CKAN_INI` | Caminho do arquivo `ckan.ini` |
| `CKAN_STORAGE_PATH` | Diretório de armazenamento de arquivos |
| `CKAN_HOST` | Endereço local onde o CKAN escuta |
| `CKAN_PORT` | Porta local do CKAN |

Por segurança, mantenha:

```bash
CKAN_HOST="127.0.0.1"
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

### Opções perigosas

Estas opções devem ser usadas com cuidado:

```bash
FORCE_RECREATE_CKAN_DB="false"
FORCE_RECREATE_SOLR_CORE="false"
FORCE_OVERWRITE_CKAN_INI="true"
```

Significado:

| Variável | Efeito |
|---|---|
| `FORCE_RECREATE_CKAN_DB` | Apaga e recria o banco do CKAN |
| `FORCE_RECREATE_SOLR_CORE` | Apaga e recria o core Solr |
| `FORCE_OVERWRITE_CKAN_INI` | Recria o arquivo principal de configuração do CKAN |

Em servidor novo, os valores padrão podem ser usados.

Em servidor com dados importantes, não use:

```bash
FORCE_RECREATE_CKAN_DB="true"
```

---

## 7. Conferir DNS antes de instalar

Antes de ativar HTTPS, confira se o domínio aponta para o IP da VM.

```bash
clear
echo '===============INÍCIO==============='
dig +short <SEU_DOMINIO>
echo '===============FIM=================='
```

Exemplo:

```bash
clear
echo '===============INÍCIO==============='
dig +short custom.ckan.exemplo.gov.br
echo '===============FIM=================='
```

O resultado deve mostrar o IP público da VM.

Se não mostrar, ajuste o DNS antes de continuar.

---

## 8. Dar permissão de execução ao script

Depois de editar o `.vars`, ajuste as permissões:

```bash
clear
echo '===============INÍCIO==============='
chmod 700 install_ckan_sfb_full.sh
chmod 600 install_ckan_sfb_full.vars
echo '===============FIM=================='
```

---

## 9. Rodar a instalação

Execute o script como `root` ou com `sudo`:

```bash
clear
echo '===============INÍCIO==============='
sudo ./install_ckan_sfb_full.sh
echo '===============FIM=================='
```

O script exibirá várias etapas no terminal.

Cada etapa aparece neste formato:

```text
----------[1/31]---------- INÍCIO, LOG E VARIÁVEIS ----------
```

Isso ajuda a saber em qual ponto da instalação o processo está.

---

## 10. Rodar usando outro arquivo `.vars`

Normalmente, o script usa automaticamente:

```text
install_ckan_sfb_full.vars
```

Mas também é possível informar outro arquivo de variáveis:

```bash
clear
echo '===============INÍCIO==============='
sudo ./install_ckan_sfb_full.sh /caminho/para/outro-arquivo.vars
echo '===============FIM=================='
```

---

## 11. O que o script faz

De forma resumida, o instalador executa estas ações:

1. Carrega o arquivo `.vars`
2. Cria arquivo de log
3. Cria pasta de backup
4. Valida variáveis obrigatórias
5. Atualiza pacotes do sistema
6. Instala Python e dependências
7. Instala e protege Redis
8. Instala e protege PostgreSQL
9. Cria usuário e banco do CKAN
10. Instala Java e Solr
11. Cria o core Solr do CKAN
12. Instala o CKAN em ambiente virtual Python
13. Gera e configura o `ckan.ini`
14. Inicializa o banco do CKAN
15. Cria o usuário administrador
16. Baixa a customização SFB do Git
17. Aplica os arquivos da pasta `rootfs`
18. Instala `ckanext-scheming`
19. Instala extensões customizadas do SFB
20. Configura idioma, plugins, tema e schema
21. Compila traduções
22. Configura o CKAN para escutar apenas em `127.0.0.1`
23. Configura Nginx
24. Configura firewall
25. Valida a configuração do CKAN
26. Reinicia serviços
27. Ativa HTTPS com Certbot, se habilitado
28. Executa validações finais

---

## 12. Logs e backups

O script grava logs em:

```text
/var/log/ckan-sfb-full-install/
```

Também cria backups em:

```text
/root/ckan-sfb-full-backups/
```

Para listar os logs:

```bash
clear
echo '===============INÍCIO==============='
ls -lh /var/log/ckan-sfb-full-install/
echo '===============FIM=================='
```

Para acompanhar o log mais recente:

```bash
clear
echo '===============INÍCIO==============='
tail -f "$(ls -t /var/log/ckan-sfb-full-install/*.log | head -n 1)"
echo '===============FIM=================='
```

Para listar backups:

```bash
clear
echo '===============INÍCIO==============='
ls -lh /root/ckan-sfb-full-backups/
echo '===============FIM=================='
```

---

## 13. Validação após a instalação

Ao final, acesse no navegador:

```text
https://SEU_DOMINIO
```

Exemplo:

```text
https://custom.ckan.exemplo.gov.br
```

Também é possível validar pelo terminal.

### Testar API local

```bash
clear
echo '===============INÍCIO==============='
curl -fsS http://127.0.0.1:5000/api/3/action/status_show | python3 -m json.tool
echo '===============FIM=================='
```

### Testar domínio

```bash
clear
echo '===============INÍCIO==============='
curl -I https://<SEU_DOMINIO>/
curl -I https://<SEU_DOMINIO>/dataset/
echo '===============FIM=================='
```

Exemplo:

```bash
clear
echo '===============INÍCIO==============='
curl -I https://custom.ckan.exemplo.gov.br/
curl -I https://custom.ckan.exemplo.gov.br/dataset/
echo '===============FIM=================='
```

### Conferir serviços

```bash
clear
echo '===============INÍCIO==============='
systemctl status ckan --no-pager
systemctl status solr --no-pager
systemctl status nginx --no-pager
echo '===============FIM=================='
```

### Conferir portas abertas

```bash
clear
echo '===============INÍCIO==============='
ss -lntp | grep -E ':(80|443|5000|8983|5432|6379)\b' || true
echo '===============FIM=================='
```

O esperado é:

- portas `80` e `443` acessíveis publicamente pelo Nginx
- CKAN em `127.0.0.1:5000`
- Solr em `127.0.0.1:8983`
- PostgreSQL e Redis sem exposição pública

---

## 14. Acessar como administrador

Use os dados definidos no `.vars`:

```bash
CKAN_SYSADMIN_NAME="..."
CKAN_SYSADMIN_PASSWORD="..."
```

Depois acesse:

```text
https://SEU_DOMINIO/user/login
```

---

## 15. Problemas comuns

### Erro: arquivo `.vars` não encontrado

Mensagem parecida:

```text
ERRO: arquivo de variáveis não encontrado
```

Causa provável:

- o arquivo `.vars` não está na mesma pasta do `.sh`
- o nome do `.vars` não bate com o nome do script
- o script foi executado de outro local

Conferir:

```bash
clear
echo '===============INÍCIO==============='
pwd
ls -lh install_ckan_sfb_full.sh install_ckan_sfb_full.vars
echo '===============FIM=================='
```

---

### Erro no Certbot ou HTTPS

Causas comuns:

- domínio ainda não aponta para o IP da VM
- porta 80 bloqueada
- porta 443 bloqueada
- DNS ainda não propagou

Conferir DNS:

```bash
clear
echo '===============INÍCIO==============='
dig +short <SEU_DOMINIO>
echo '===============FIM=================='
```

Conferir firewall:

```bash
clear
echo '===============INÍCIO==============='
ufw status verbose
echo '===============FIM=================='
```

---

### CKAN não responde localmente

Conferir serviço:

```bash
clear
echo '===============INÍCIO==============='
systemctl status ckan --no-pager
journalctl -u ckan -n 120 --no-pager
echo '===============FIM=================='
```

---

### Solr não responde

Conferir serviço:

```bash
clear
echo '===============INÍCIO==============='
systemctl status solr --no-pager
journalctl -u solr -n 120 --no-pager
curl -fsS http://127.0.0.1:8983/solr/ckan/admin/ping
echo '===============FIM=================='
```

---

### Nginx não sobe

Testar configuração:

```bash
clear
echo '===============INÍCIO==============='
nginx -t
systemctl status nginx --no-pager
journalctl -u nginx -n 120 --no-pager
echo '===============FIM=================='
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

Depois rode novamente o instalador ou ajuste manualmente os arquivos de configuração.

---

## 16. Reexecutar o instalador

O script pode ser executado novamente para reaplicar a instalação/customização.

Antes de reexecutar, confira estas variáveis:

```bash
FORCE_RECREATE_CKAN_DB="false"
FORCE_RECREATE_SOLR_CORE="false"
FORCE_OVERWRITE_CKAN_INI="true"
```

Atenção:

- `FORCE_RECREATE_CKAN_DB="true"` apaga e recria o banco.
- `FORCE_RECREATE_SOLR_CORE="true"` recria o core Solr.
- `FORCE_OVERWRITE_CKAN_INI="true"` recria a configuração principal do CKAN.

Em ambiente com dados reais, mantenha:

```bash
FORCE_RECREATE_CKAN_DB="false"
FORCE_RECREATE_SOLR_CORE="false"
```

---

## 17. Atualizar customizações a partir do Git

O script baixa a customização usando:

```bash
GIT_REPO_URL="..."
GIT_BRANCH="..."
```

Para aplicar uma versão nova da customização:

1. Atualize o repositório Git.
2. Confira a branch no `.vars`.
3. Rode novamente o instalador.

```bash
clear
echo '===============INÍCIO==============='
sudo ./install_ckan_sfb_full.sh
echo '===============FIM=================='
```

---

## 18. Resumo rápido da instalação

Fluxo completo:

```text
1. Criar uma VM Ubuntu 24.04 LTS
2. Apontar o DNS do domínio para o IP da VM
3. Clonar este repositório
4. Editar install_ckan_sfb_full.vars
5. Dar permissão de execução ao script
6. Rodar sudo ./install_ckan_sfb_full.sh
7. Acessar https://SEU_DOMINIO
8. Entrar com o usuário administrador definido no .vars
```

Comandos principais:

```bash
clear
echo '===============INÍCIO==============='
cd /root
git clone <URL_DO_REPOSITORIO>
cd <PASTA_DO_REPOSITORIO>
nano install_ckan_sfb_full.vars
chmod 700 install_ckan_sfb_full.sh
chmod 600 install_ckan_sfb_full.vars
sudo ./install_ckan_sfb_full.sh
echo '===============FIM=================='
```
