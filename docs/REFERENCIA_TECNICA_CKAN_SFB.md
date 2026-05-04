# Manual de Referência Técnica do CKAN SFB

**Componentes, configurações, customizações e caminhos de manutenção**

> Documento complementar ao manual de operacionalização pela interface web.  
> Versão de referência do projeto: **CKAN 2.10.7 em Docker**.  
> Data: **2026-05-04**.

---

## Sumário

1. [Finalidade do documento](#1-finalidade-do-documento)
2. [Visão geral da arquitetura CKAN SFB](#2-visão-geral-da-arquitetura-ckan-sfb)
3. [Arquivos de instalação e configuração inicial](#3-arquivos-de-instalação-e-configuração-inicial)
4. [Mapa de diretórios do ambiente Docker](#4-mapa-de-diretórios-do-ambiente-docker)
5. [Docker e containers](#5-docker-e-containers)
6. [Nginx](#6-nginx)
7. [Certbot e HTTPS](#7-certbot-e-https)
8. [Firewall](#8-firewall)
9. [PostgreSQL](#9-postgresql)
10. [Redis](#10-redis)
11. [Solr e reindexação](#11-solr-e-reindexação)
12. [API do CKAN](#12-api-do-ckan)
13. [Arquivo `ckan.ini`](#13-arquivo-ckanini)
14. [Schema YAML do CKAN SFB](#14-schema-yaml-do-ckan-sfb)
15. [Templates, CSS, JavaScript e assets](#15-templates-css-javascript-e-assets)
16. [Traduções e idioma](#16-traduções-e-idioma)
17. [Plugins e extensões](#17-plugins-e-extensões)
18. [Logs, validações e diagnóstico](#18-logs-validações-e-diagnóstico)
19. [Rotina segura para alterações técnicas](#19-rotina-segura-para-alterações-técnicas)
20. [Referência rápida - Questões frequentes](#20-referência-rápida---questões-frequentes)
21. [Glossário rápido](#21-glossário-rápido)
22. [Referências técnicas](#22-referências-técnicas)

---

# 1. Finalidade do documento

Este manual é uma referência geral para entender os principais componentes técnicos do CKAN SFB e saber **onde procurar** quando uma operação não se enquadra no uso normal pela interface web.

Ele não substitui:

- o manual de uso da interface gráfica;
- o README de instalação;
- tutoriais específicos de desenvolvimento;
- documentação oficial do CKAN, Docker, Nginx, PostgreSQL, Solr ou Certbot.

Ele serve como uma bússola de manutenção: mostra o que cada componente faz, onde ficam os arquivos principais, quando mexer, o que validar e quais riscos observar.

## 1.1 Público-alvo

Este documento é voltado para:

- administradores técnicos do ambiente;
- equipe responsável pela manutenção do repositório Git;
- equipe de suporte do CKAN SFB;
- pessoas que precisam diagnosticar problemas de infraestrutura, configuração, busca, API, templates, YAML ou plugins.

## 1.2 Escopo

Este manual cobre:

- Docker;
- Nginx;
- Certbot/HTTPS;
- firewall;
- PostgreSQL;
- Redis;
- Solr;
- reindexação;
- API;
- `ckan.ini`;
- schema YAML;
- templates;
- CSS, JavaScript e imagens;
- traduções;
- plugins/extensões;
- logs e validações.

## 1.3 Fora do escopo

Este manual não ensina em detalhe:

- como cadastrar registros pela interface;
- como criar recursos pela interface;
- como criar usuários, unidades e projetos pela interface;
- como desenvolver plugins completos do zero;
- como administrar Linux ou Docker em nível avançado;
- como instalar o CKAN passo a passo do zero.

---

# 2. Visão geral da arquitetura CKAN SFB

A instalação atual do CKAN SFB usa uma arquitetura baseada em Docker. Cada serviço principal roda em seu próprio container.

## 2.1 Componentes principais

| Componente | Papel no CKAN SFB | Onde roda | Persistência principal | Quando costuma ser consultado |
|---|---|---|---|---|
| CKAN | Aplicação principal do portal | container `ckan` | volume de arquivos e configuração | erro 500, campos, API, plugins, templates |
| PostgreSQL | Banco de dados principal | container `db` | volume `db_data` | backup, restauração, dados inconsistentes |
| Redis | Cache/fila auxiliar | container `redis` | volume `redis_data` | problemas de cache/fila, raramente |
| Solr | Motor de busca e filtros | container `solr` | volume `solr_data` | busca, facets, registro não aparece |
| Nginx | Entrada pública HTTP/HTTPS | container `nginx` | config em `nginx/default.conf` | domínio, HTTPS, proxy, upload |
| Certbot | Emissão/renovação de certificados | container `certbot` | `letsencrypt/` | certificado, HTTPS, renovação |

## 2.2 Fluxo simplificado de acesso

```text
Usuário no navegador
        ↓
Domínio público
        ↓
Nginx nas portas 80/443
        ↓
CKAN no container ckan
        ↓
PostgreSQL / Solr / Redis
```

## 2.3 Exposição pública esperada

A entrada pública deve ocorrer pelo Nginx.

| Porta | Serviço | Deve ficar pública? | Observação |
|---:|---|---:|---|
| 22 | SSH | Sim, com controle | Usada para administração do servidor |
| 80 | HTTP/Nginx | Sim | Necessária para HTTP e desafio Certbot |
| 443 | HTTPS/Nginx | Sim | Acesso seguro ao portal |
| 5000 | CKAN | Não | Deve ficar interno/local |
| 8983 | Solr | Não | Nunca deve ser exposto publicamente |
| 5432 | PostgreSQL | Não | Banco deve ficar interno |
| 6379 | Redis | Não | Redis deve ficar interno |

> **Atenção:** se Solr, PostgreSQL, Redis ou a porta interna do CKAN aparecerem publicamente expostos, trate como problema de segurança.

---

# 3. Arquivos de instalação e configuração inicial

A instalação Docker do CKAN SFB usa três arquivos principais.

```text
install_ckan_sfb_docker_full.sh
install_ckan_sfb_docker_full.vars
install_ckan_sfb_docker_full.secrets
```

## 3.1 `install_ckan_sfb_docker_full.sh`

É o script principal de instalação.

Responsável por:

- validar variáveis;
- preparar o sistema;
- instalar Docker e Docker Compose;
- clonar ou atualizar o repositório de customização SFB;
- criar a estrutura do projeto Docker;
- gerar `.env`;
- preparar segredos para Docker;
- gerar Dockerfile do CKAN;
- gerar Dockerfile do Solr;
- gerar configuração do Nginx;
- gerar `docker-compose.yml`;
- configurar firewall;
- construir imagens;
- subir containers;
- ativar HTTPS com Certbot, se configurado;
- validar CKAN, plugins, schema, API, domínio e portas.

O script não aceita parâmetros. Ele espera que os arquivos `.vars` e `.secrets` estejam no mesmo diretório do `.sh`.

## 3.2 `install_ckan_sfb_docker_full.vars`

Arquivo de variáveis não sensíveis.

Define, entre outros itens:

- diretório de instalação;
- domínio;
- uso de HTTPS;
- versão CKAN;
- versão Python;
- imagens Docker;
- porta interna do CKAN;
- limites de upload;
- repositório Git da customização;
- plugins CKAN;
- paths de templates e arquivos públicos;
- schema YAML;
- idioma;
- flags como `REINDEX_SEARCH` e `COMPILE_TRANSLATIONS`.

Exemplos de variáveis importantes:

```bash
INSTALL_DIR="/opt/ckan-sfb-docker"
DOMAIN="custom.ckan.bt2.dev.br"
ENABLE_HTTPS="true"
CKAN_VERSION="ckan-2.10.7"
PYTHON_VERSION="3.10"
CKAN_INTERNAL_PORT="5000"
CKAN_MAX_RESOURCE_SIZE_MB="300"
NGINX_CLIENT_MAX_BODY_SIZE="300M"
REINDEX_SEARCH="false"
```

## 3.3 `install_ckan_sfb_docker_full.secrets`

Arquivo de segredos.

Contém valores sensíveis e **não deve ser versionado em repositório público**.

Variáveis esperadas:

```bash
CKAN_DB_PASSWORD="..."
CKAN_SYSADMIN_PASSWORD="..."
GIT_TOKEN="..."
API_TOKEN="..."
SECRET_KEY="..."
```

> **Atenção:** este manual cita apenas os nomes das variáveis. Os valores reais nunca devem ser copiados para documentação, Git, prints, tickets ou mensagens de suporte.

## 3.4 Separação recomendada

| Arquivo | Conteúdo | Pode ir para Git? | Observação |
|---|---|---:|---|
| `.sh` | lógica de instalação | Sim | Não deve conter senha real |
| `.vars` | parâmetros do ambiente | Sim, com revisão | Pode conter domínio, imagens e flags |
| `.secrets` | senhas e tokens | Não | Deve ficar protegido |
| `.env` | ambiente gerado para Docker | Evitar | Gerado pelo script |
| `secrets/` | arquivos de segredo para containers | Não | Deve ter permissão restrita |

---

# 4. Mapa de diretórios do ambiente Docker

O diretório base padrão é:

```text
/opt/ckan-sfb-docker
```

Esse caminho pode mudar se a variável `INSTALL_DIR` for alterada.

## 4.1 Diretórios principais

| Caminho | Função |
|---|---|
| `/opt/ckan-sfb-docker/docker-compose.yml` | Define os containers, redes, volumes e segredos |
| `/opt/ckan-sfb-docker/.env` | Variáveis consumidas pelo Docker Compose |
| `/opt/ckan-sfb-docker/ckan/` | Build da imagem do CKAN e entrypoint |
| `/opt/ckan-sfb-docker/solr/` | Build da imagem do Solr e schema CKAN |
| `/opt/ckan-sfb-docker/nginx/` | Configuração do Nginx dentro do ambiente Docker |
| `/opt/ckan-sfb-docker/ckan-config/` | Configuração persistente do CKAN, incluindo `ckan.ini` e schemas |
| `/opt/ckan-sfb-docker/secrets/` | Segredos usados pelos containers |
| `/opt/ckan-sfb-docker/repo/sfb/` | Clone do repositório Git de customização SFB |
| `/opt/ckan-sfb-docker/letsencrypt/` | Certificados HTTPS persistentes |
| `/opt/ckan-sfb-docker/certbot-www/` | Diretório usado no desafio HTTP do Certbot |

## 4.2 Relação com o `rootfs`

O repositório SFB contém uma pasta `rootfs/` que representa caminhos finais no sistema/container.

Exemplo:

```text
rootfs/etc/ckan/schemas/sfb_dataset.yaml
```

vira:

```text
/etc/ckan/schemas/sfb_dataset.yaml
```

No ambiente Docker, os arquivos de `/etc/ckan` são semeados no volume persistente:

```text
/opt/ckan-sfb-docker/ckan-config
```

---

# 5. Docker e containers

## 5.1 Papel do Docker

Docker isola os serviços do CKAN em containers. Isso evita instalar todas as dependências diretamente no sistema operacional do servidor.

Na prática, o Docker permite que CKAN, PostgreSQL, Redis, Solr, Nginx e Certbot rodem separados, mas conectados por uma rede interna.

## 5.2 Serviços esperados no `docker-compose.yml`

| Serviço | Container esperado | Função |
|---|---|---|
| `db` | `ckan_sfb_db` | PostgreSQL |
| `redis` | `ckan_sfb_redis` | Redis |
| `solr` | `ckan_sfb_solr` | Solr |
| `ckan` | `ckan_sfb_ckan` | Aplicação CKAN |
| `nginx` | `ckan_sfb_nginx` | Proxy público |
| `certbot` | `ckan_sfb_certbot` | Certificados HTTPS |

## 5.3 Volumes esperados

| Volume | Guarda |
|---|---|
| `db_data` | dados do PostgreSQL |
| `redis_data` | dados persistidos do Redis |
| `solr_data` | índice Solr |
| `ckan_storage` | arquivos enviados ao CKAN |

> **Atenção:** volumes guardam dados importantes. Derrubar containers não apaga necessariamente os dados. Apagar volumes pode destruir banco, arquivos enviados e índice.

## 5.4 Operações Docker comuns

### Ver status dos containers

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose ps
echo '===============FIM=================='
```

### Ver logs do CKAN

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose logs --tail=200 ckan
echo '===============FIM=================='
```

### Ver logs do Nginx

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose logs --tail=200 nginx
echo '===============FIM=================='
```

### Ver logs do Solr

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose logs --tail=200 solr
echo '===============FIM=================='
```

## 5.5 Restart, rebuild e recriação

| Operação | O que faz | Risco |
|---|---|---:|
| `docker compose restart` | reinicia containers existentes | Baixo |
| `docker compose up -d` | sobe/recria containers conforme necessário | Baixo/médio |
| `docker compose up -d --build` | reconstrói imagens e sobe containers | Médio |
| `docker compose build --no-cache` | reconstrói imagens sem cache | Médio/alto |
| `docker compose down` | derruba containers | Médio |
| `docker compose down -v` | derruba containers e apaga volumes | Altíssimo |

> **Regra prática:** não use `docker compose down -v` em ambiente com dados reais, salvo se o objetivo for apagar tudo e reconstruir do zero.

---

# 6. Nginx

## 6.1 Papel do Nginx

O Nginx é a porta de entrada pública do CKAN SFB.

Ele recebe requisições HTTP/HTTPS do navegador e encaminha para o container CKAN.

Fluxo:

```text
Navegador → Nginx → CKAN
```

## 6.2 Arquivo principal no Docker

No ambiente Docker:

```text
/opt/ckan-sfb-docker/nginx/default.conf
```

Na estrutura `rootfs` usada como referência de servidor tradicional:

```text
/etc/nginx/sites-available/ckan
```

## 6.3 Quando mexer no Nginx

Mexa ou revise Nginx quando houver:

- mudança de domínio;
- ativação ou correção de HTTPS;
- erro 502 Bad Gateway;
- erro 504 Gateway Timeout;
- erro 413 Request Entity Too Large;
- upload grande falhando;
- redirecionamento errado HTTP → HTTPS;
- necessidade de alterar headers de proxy.

## 6.4 Limite de upload

O limite de upload precisa estar coerente em duas camadas:

1. CKAN;
2. Nginx.

Exemplo no `.vars`:

```bash
CKAN_MAX_RESOURCE_SIZE_MB="300"
CKAN_RESOURCE_PROXY_MAX_FILE_SIZE_BYTES="314572800"
NGINX_CLIENT_MAX_BODY_SIZE="300M"
```

Se o CKAN aceitar 300 MB, mas o Nginx aceitar apenas 1 MB, o usuário receberá erro antes de a requisição chegar ao CKAN.

## 6.5 Sinais de problema no Nginx

| Sintoma | Causa provável |
|---|---|
| 502 Bad Gateway | CKAN parado ou porta interna errada |
| 504 Gateway Timeout | CKAN lento, timeout baixo ou processo travado |
| 413 Request Entity Too Large | `client_max_body_size` pequeno |
| HTTP abre, HTTPS falha | Certificado, porta 443 ou config SSL |
| Redirecionamento em loop | `ckan.site_url` ou `X-Forwarded-Proto` incoerente |

---

# 7. Certbot e HTTPS

## 7.1 Papel do Certbot

Certbot emite e renova certificados HTTPS do Let's Encrypt.

No CKAN SFB, ele é usado quando:

```bash
ENABLE_HTTPS="true"
```

## 7.2 Componentes envolvidos

| Item | Função |
|---|---|
| `certbot` | container que solicita/renova certificado |
| `letsencrypt/` | armazenamento persistente dos certificados |
| `certbot-www/` | diretório usado no desafio HTTP |
| Nginx porta 80 | responde ao desafio do Let's Encrypt |
| Nginx porta 443 | serve o CKAN com HTTPS |

## 7.3 Quando mexer em Certbot/HTTPS

- domínio mudou;
- certificado expirou;
- navegador acusa certificado inválido;
- Certbot não consegue emitir certificado;
- DNS ainda não aponta para o servidor;
- porta 80 bloqueada;
- container Nginx não responde ao desafio.

## 7.4 Problemas comuns

| Sintoma | Verificar |
|---|---|
| Certbot falha na emissão | DNS, porta 80, firewall, Nginx |
| HTTPS não abre | certificado, porta 443, Nginx |
| Certificado emitido para domínio errado | variável `DOMAIN` |
| Renovação falha | cron, container Certbot, Nginx, DNS |

## 7.5 Validação simples do domínio

```bash
clear
echo '===============INÍCIO==============='
dig +short SEU_DOMINIO
curl -I http://SEU_DOMINIO/
curl -I https://SEU_DOMINIO/
echo '===============FIM=================='
```

---

# 8. Firewall

## 8.1 Papel do firewall

O firewall limita quais portas do servidor ficam acessíveis externamente.

No projeto, o UFW é usado como firewall simples de host.

## 8.2 Regras esperadas

| Porta | Serviço | Regra esperada |
|---:|---|---|
| 22 | SSH | permitir |
| 80 | HTTP | permitir |
| 443 | HTTPS | permitir, se HTTPS ativo |
| 5000 | CKAN interno | bloquear externo |
| 8983 | Solr | bloquear externo |
| 5432 | PostgreSQL | bloquear externo |
| 6379 | Redis | bloquear externo |

## 8.3 Quando revisar firewall

- CKAN não abre externamente;
- Certbot falha;
- SSH não conecta;
- portas internas aparecem públicas;
- após migração de VM ou clone de droplet;
- após alteração de provedor ou painel de firewall externo.

## 8.4 Validação

```bash
clear
echo '===============INÍCIO==============='
ufw status verbose
ss -lntp | grep -E ':(22|80|443|5000|8983|5432|6379)\b' || true
echo '===============FIM=================='
```

---

# 9. PostgreSQL

## 9.1 Papel do PostgreSQL

PostgreSQL é o banco de dados principal do CKAN.

Ele armazena:

- usuários;
- organizações/unidades;
- grupos/projetos;
- registros/datasets;
- recursos/arquivos;
- metadados extras;
- permissões;
- configurações persistidas;
- histórico e atividades.

## 9.2 Quando consultar o banco

- diagnóstico de dados inconsistentes;
- conferência de campos que não aparecem na interface;
- auditoria de registros;
- backup e restauração;
- saneamento controlado;
- investigação de divergência entre interface e dado real.

## 9.3 Quando não mexer diretamente no banco

Evite alteração direta no banco quando a operação puder ser feita por:

- interface web;
- API CKAN;
- comando CKAN;
- ajuste de YAML;
- ajuste de plugin.

> **Atenção:** alterações diretas no banco podem deixar o PostgreSQL e o índice Solr em estados diferentes. Quando isso acontecer, pode ser necessário reindexar.

## 9.4 Tabelas úteis para diagnóstico

| Tabela | Uso típico |
|---|---|
| `package` | registros/datasets |
| `package_extra` | metadados extras de registros |
| `resource` | arquivos e links associados aos registros |
| `group` | organizações e grupos |
| `member` | associações entre usuários, grupos, organizações e datasets |
| `user` | usuários |
| `system_info` | configurações salvas em runtime |

## 9.5 Backup lógico de referência

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec db pg_dump -U ckan_default -d ckan_default --format=custom > ckan_default_$(date +%F_%H-%M-%S).dump
echo '===============FIM=================='
```

> **Atenção:** dump SQL pode conter dados pessoais, chaves, tokens e informações sensíveis. Proteja o arquivo.

---

# 10. Redis

## 10.1 Papel do Redis

Redis é usado pelo CKAN como serviço auxiliar de cache/fila, conforme configuração do ambiente.

No `.vars`, a URL padrão é:

```bash
REDIS_URL="redis://redis:6379/0"
```

## 10.2 Quando olhar Redis

Redis raramente é o primeiro suspeito. Consulte quando houver:

- erro explícito de conexão Redis;
- falhas em tarefas de background;
- comportamento de cache estranho;
- container `redis` reiniciando ou unhealthy.

## 10.3 Validação simples

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec redis redis-cli ping
echo '===============FIM=================='
```

Resultado esperado:

```text
PONG
```

---

# 11. Solr e reindexação

## 11.1 Papel do Solr

Solr é o motor de busca usado pelo CKAN.

Ele guarda um índice dos registros para permitir:

- busca textual;
- filtros/facets;
- ordenação;
- visibilidade em resultados;
- recuperação rápida.

Solr não substitui o PostgreSQL. Ele é um índice derivado do banco e dos plugins.

## 11.2 Quando o Solr entra no diagnóstico

Consulte Solr quando:

- um registro existe no banco, mas não aparece na busca;
- facets/filtros aparecem vazios;
- filtro mostra valores antigos;
- campo novo não aparece na busca;
- permissões/visibilidade mudaram;
- plugin de busca/facet foi alterado;
- houve alteração direta no banco;
- `search-index rebuild` falhou.

## 11.3 O que é reindexação

Reindexar é reconstruir o índice de busca a partir dos dados do CKAN.

Comando conceitual:

```bash
ckan -c /etc/ckan/ckan.ini search-index rebuild
```

No Docker, rode dentro do container CKAN:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec ckan ckan -c /etc/ckan/ckan.ini search-index rebuild
echo '===============FIM=================='
```

## 11.4 Quando reindexar

| Alteração | Reindexar? | Observação |
|---|---:|---|
| CSS | Não | Só aparência |
| Template de leitura | Normalmente não | A menos que dependa de dado indexado |
| Label visual no YAML | Normalmente não | Se não muda valor indexado |
| Campo novo usado na busca | Sim | Solr precisa conhecer os dados |
| Facet nova | Sim | Índice precisa ser reconstruído |
| Plugin de facet | Sim | Especialmente se muda `before_dataset_index` |
| Plugin de acesso/labels | Sim | Visibilidade depende do índice |
| Correção direta no banco | Frequentemente | Índice pode ficar desatualizado |

## 11.5 Diagnóstico rápido do Solr

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec solr wget -qO- 'http://localhost:8983/solr/ckan/admin/ping?wt=json'
echo '===============FIM=================='
```

Resultado esperado contém algo como:

```json
{
  "status": "OK"
}
```

---

# 12. API do CKAN

## 12.1 Papel da API

A API permite consultar e manipular dados do CKAN sem usar a interface web.

Ela é útil para:

- diagnóstico;
- automações;
- exportações;
- comparação entre dado real e tela;
- testes pós-alteração;
- integração com outros sistemas.

## 12.2 Endpoint geral

Formato:

```text
/api/3/action/NOME_DA_ACAO
```

Exemplos:

```text
/api/3/action/status_show
/api/3/action/package_show?id=NOME_OU_ID_DO_REGISTRO
/api/3/action/package_search?q=TERMO
/api/3/action/organization_show?id=NOME_DA_UNIDADE
/api/3/action/group_show?id=NOME_DO_PROJETO
```

## 12.3 Teste de disponibilidade

```bash
clear
echo '===============INÍCIO==============='
curl -fsS https://SEU_DOMINIO/api/3/action/status_show | python3 -m json.tool
echo '===============FIM=================='
```

## 12.4 Quando usar API no suporte

| Situação | Ação útil |
|---|---|
| Confirmar se CKAN está vivo | `status_show` |
| Ver dados crus de um registro | `package_show` |
| Ver se busca encontra o registro | `package_search` |
| Conferir unidade | `organization_show` |
| Conferir projeto/grupo | `group_show` |
| Comparar UI vs dado real | `package_show` + tela |

## 12.5 API autenticada

Ações de escrita, administração ou acesso a dados restritos exigem autenticação.

> **Atenção:** tokens de API são sensíveis. Não coloque tokens em prints, Git, documentação pública ou tickets.

---

# 13. Arquivo `ckan.ini`

## 13.1 Papel do `ckan.ini`

O `ckan.ini` é o arquivo central de configuração do CKAN.

No ambiente Docker, ele fica dentro do container em:

```text
/etc/ckan/ckan.ini
```

No host, a configuração persistente fica normalmente em:

```text
/opt/ckan-sfb-docker/ckan-config/ckan.ini
```

## 13.2 Principais chaves

| Chave | Função | Quando mexer |
|---|---|---|
| `ckan.site_id` | identificador interno do site | raramente |
| `ckan.site_url` | URL pública do portal | mudança de domínio/HTTPS |
| `ckan.site_title` | título do site | mudança institucional |
| `sqlalchemy.url` | conexão com PostgreSQL | mudança de banco |
| `solr_url` | URL do Solr | mudança de Solr/core |
| `ckan.redis.url` | URL do Redis | mudança de Redis |
| `ckan.storage_path` | local de arquivos enviados | storage/upload |
| `ckan.uploads_enabled` | habilita upload | upload de recursos |
| `ckan.max_resource_size` | limite de recurso em MB | erro de upload |
| `ckan.max_image_size` | limite de imagem em MB | imagens |
| `ckan.resource_proxy.max_file_size` | limite de proxy/preview | pré-visualização |
| `ckan.plugins` | plugins ativos | ativar/remover extensão |
| `extra_template_paths` | templates customizados | customização de interface |
| `extra_public_paths` | CSS/JS/imagens custom | identidade visual |
| `ckan.theme` | tema base | aparência |
| `ckan.locale_default` | idioma padrão | PT-BR/idioma |
| `scheming.presets` | presets do scheming | campos customizados |
| `scheming.dataset_schemas` | schema YAML | metadados |
| `scheming.dataset_fallback` | fallback do schema | comportamento do scheming |

## 13.3 Validação do `ckan.ini`

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec ckan ckan -c /etc/ckan/ckan.ini config validate
echo '===============FIM=================='
```

## 13.4 Riscos comuns

| Erro | Possível efeito |
|---|---|
| plugin inválido em `ckan.plugins` | CKAN não inicia |
| caminho de YAML errado | formulário quebra ou schema não carrega |
| `ckan.site_url` errado | links, login, HTTPS ou redirect quebrados |
| `solr_url` errado | busca falha |
| `sqlalchemy.url` errado | CKAN não conecta ao banco |
| limite de upload incoerente | upload falha |

---

# 14. Schema YAML do CKAN SFB

## 14.1 Papel do YAML

O arquivo YAML define os campos de metadados usados pelo `ckanext-scheming`.

Caminho conceitual:

```text
/etc/ckan/schemas/sfb_dataset.yaml
```

No host Docker:

```text
/opt/ckan-sfb-docker/ckan-config/schemas/sfb_dataset.yaml
```

## 14.2 O que o YAML controla

- campos do registro;
- campos do recurso;
- labels;
- placeholders;
- presets;
- snippets de formulário;
- snippets de exibição;
- validações;
- obrigatoriedade;
- vocabulários controlados;
- campos múltiplos;
- ordem dos campos.

## 14.3 Estrutura geral

```yaml
scheming_version: 2
dataset_type: dataset
about: Schema SFB
about_url: http://github.com/ckan/ckanext-scheming

dataset_fields:
  - field_name: title
    label: Título
    preset: title

resource_fields:
  - field_name: name
    label: Nome
```

## 14.4 Quando alterar YAML

Altere YAML quando for necessário:

- adicionar campo;
- remover campo do formulário;
- mudar texto de label;
- trocar opções de lista suspensa;
- tornar campo obrigatório;
- tornar campo opcional;
- mover campo entre registro e recurso;
- mudar widget de formulário;
- mudar snippet de exibição.

## 14.5 Quando YAML não resolve

YAML não é suficiente quando a alteração exige:

- regra de acesso;
- visibilidade por usuário;
- sincronização com grupos/projetos;
- lógica condicional complexa;
- alteração de busca/facets;
- preenchimento automático no servidor;
- ação customizada de API;
- comando customizado.

Nesses casos, o caminho provável é plugin Python.

## 14.6 Validação após alterar YAML

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec ckan ckan -c /etc/ckan/ckan.ini config validate
docker compose restart ckan
echo '===============FIM=================='
```

Se a alteração afetar busca ou filtros, reindexe:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec ckan ckan -c /etc/ckan/ckan.ini search-index rebuild
echo '===============FIM=================='
```

---

# 15. Templates, CSS, JavaScript e assets

## 15.1 Diferença entre camadas

| Camada | Altera o quê? | Exemplo |
|---|---|---|
| YAML | campos e formulários | adicionar campo `status_registro` |
| Template | estrutura HTML exibida | mostrar Unidade no card |
| CSS | aparência | cor, tamanho, espaçamento |
| JavaScript | comportamento no navegador | carrossel, interação visual |
| Plugin | comportamento no servidor | permissão, facet, helper |

## 15.2 Diretórios principais

```text
/etc/ckan/custom/templates
/etc/ckan/custom/public
/etc/ckan/public/images
```

No host Docker:

```text
/opt/ckan-sfb-docker/ckan-config/custom/templates
/opt/ckan-sfb-docker/ckan-config/custom/public
/opt/ckan-sfb-docker/ckan-config/public/images
```

## 15.3 Templates importantes

| Template | Função |
|---|---|
| `base.html` | base global das páginas |
| `header.html` | cabeçalho e navegação |
| `footer.html` | rodapé |
| `home/index.html` | página inicial |
| `home/snippets/search.html` | bloco de busca da home |
| `home/snippets/search_advanced.html` | busca avançada da home |
| `organization/read.html` | página de unidade/organização |
| `group/read_base.html` | página de projeto/grupo |
| `package/read.html` | página de leitura do registro |
| `package/resource_read.html` | página de leitura do recurso |
| `package/search.html` | busca/listagem de registros |
| `package/snippets/private.html` | badge de visibilidade |
| `package/snippets/resource_item.html` | item de recurso |
| `snippets/package_item.html` | card de registro na listagem |
| `snippets/facet_list.html` | filtros laterais |
| `scheming/package/snippets/additional_info.html` | exibição de metadados extras |
| `scheming/package/snippets/package_form.html` | formulário do schema |

## 15.4 CSS e assets importantes

| Arquivo | Função |
|---|---|
| `sfb-custom-global.css` | estilo global SFB |
| `sfb-home-hero.css` | estilo da página inicial |
| `sfb_facets_collapsible.css` | estilo dos filtros laterais |
| `sfb-home-carousel.js` | comportamento do carrossel/home |
| `home-hero.jpg` | imagem de destaque da home |
| `logo.png` | logotipo institucional |

## 15.5 Quando alterar template

Altere template quando precisar mudar:

- o que aparece em uma página;
- ordem visual de blocos;
- card de resultado;
- exibição de metadados;
- rótulo visual de uma seção;
- estrutura da home;
- cabeçalho ou rodapé.

## 15.6 Quando alterar CSS

Altere CSS quando precisar mudar:

- cor;
- fonte;
- margem;
- espaçamento;
- largura;
- alinhamento;
- responsividade;
- aparência de botão, card, formulário ou filtro.

## 15.7 Quando alterar JavaScript

Altere JavaScript apenas quando precisar mudar comportamento no navegador, por exemplo:

- abrir/fechar bloco;
- carrossel;
- botão dinâmico;
- interação visual que não depende do servidor.

> **Atenção:** se o problema envolve permissão, busca, salvamento ou API, não é CSS nem JavaScript. Comece por plugin, YAML, `ckan.ini`, banco ou Solr.

---

# 16. Traduções e idioma

## 16.1 Papel das traduções

As traduções ajustam textos globais da interface sem exigir que cada template seja alterado manualmente.

## 16.2 Arquivos de tradução

| Arquivo | Função |
|---|---|
| `ckan.po` | fonte textual de tradução |
| `ckan.mo` | tradução compilada usada em runtime |
| `sfb_ui.po` | traduções específicas da interface SFB |

Caminhos frequentes:

```text
/opt/ckan/extra_translations/pt_BR/LC_MESSAGES/sfb_ui.po
/opt/ckan/extra_translations/i18n/pt_BR/LC_MESSAGES/ckan.po
/usr/lib/ckan/ckan/ckan/i18n/pt_BR/LC_MESSAGES/ckan.po
```

## 16.3 Configurações relacionadas

No `ckan.ini`:

```ini
ckan.locale_default = pt_BR
ckan.locales_offered = pt_BR en
ckan.locale_order = pt_BR en
ckan.i18n.extra_directory = /opt/ckan/extra_translations
ckan.i18n.extra_gettext_domain = sfb_ui
ckan.i18n.extra_locales = pt_BR
```

## 16.4 Compilação de traduções

Arquivos `.po` precisam ser compilados para `.mo`.

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec ckan bash -lc "find /opt/ckan/extra_translations -type f -name '*.po' -print"
echo '===============FIM=================='
```

> **Observação:** o script de instalação já possui rotina de compilação quando `COMPILE_TRANSLATIONS="true"`.

---

# 17. Plugins e extensões

## 17.1 Papel dos plugins

Plugins são extensões Python que alteram o comportamento do CKAN.

Eles podem atuar em:

- autorização;
- busca;
- indexação;
- facets/filtros;
- helpers de templates;
- formulários;
- recursos;
- API;
- comandos de linha de comando;
- integração com outros sistemas.

## 17.2 Plugins SFB esperados

| Plugin/extensão | Função provável no projeto |
|---|---|
| `ckanext-sfb_access` | regras de acesso e visibilidade |
| `ckanext-sfb_facets_multi` | facets/filtros customizados e multivalor |
| `ckanext-sfb_geo_facet` | filtro geográfico |
| `ckanext-sfb_group_sync` | sincronização entre campo de projeto/grupo e grupo CKAN |
| `ckanext-sfbgroups` | helpers e choices para projetos/grupos |
| `ckanext-sfbdraftsearch` | comportamento relacionado a rascunhos/busca |

No `ckan.ini`, os plugins aparecem em:

```ini
ckan.plugins = activity scheming_datasets sfb_facets_multi sfb_geo_facet sfb_access sfb_group_sync sfbgroups sfb_drafts_search
```

## 17.3 Onde ficam os plugins

Dentro do container CKAN:

```text
/usr/lib/ckan/venv/src/ckanext-sfb_access
/usr/lib/ckan/venv/src/ckanext-sfb_facets_multi
/usr/lib/ckan/venv/src/ckanext-sfb_geo_facet
/usr/lib/ckan/venv/src/ckanext-sfb_group_sync
/usr/lib/ckan/venv/src/ckanext-sfbgroups
/usr/lib/ckan/venv/src/ckanext-sfbdraftsearch
```

No repositório `rootfs`, esses caminhos aparecem sob:

```text
rootfs/usr/lib/ckan/venv/src/ckanext-...
```

## 17.4 Quando desenvolver ou alterar plugin

Considere plugin quando a mudança exige:

- nova regra de acesso;
- nova regra de visibilidade;
- alteração em permission labels;
- alteração de facets;
- sincronização automática;
- helper para template;
- ação de API customizada;
- comando CKAN customizado;
- manipulação de dados antes de indexar;
- regra que YAML não consegue expressar.

## 17.5 Interfaces comuns do CKAN

| Interface | Uso típico |
|---|---|
| `IConfigurer` | registrar templates, assets e configurações |
| `ITemplateHelpers` | criar helpers usados em templates |
| `IPackageController` | interferir em datasets/registros |
| `IResourceController` | interferir em recursos/arquivos |
| `IAuthFunctions` | alterar autorização |
| `IPermissionLabels` | controlar labels de visibilidade no índice |
| `IActions` | criar ou substituir ações de API |
| `IClick` | criar comandos CLI |

## 17.6 Risco especial: acesso e visibilidade

Acesso é uma das áreas mais sensíveis do CKAN SFB.

No projeto, há pelo menos três camadas que podem interferir no resultado:

1. campo de negócio, como `sfb_acesso`;
2. flag nativa do CKAN, como `package.private`;
3. labels de permissão indexados no Solr.

Se essas camadas ficarem desalinhadas, pode ocorrer:

- registro público invisível;
- registro privado visível indevidamente;
- apenas admin conseguir ver tudo;
- badge visual errado;
- busca diferente da tela de detalhe.

> **Regra prática:** mexeu em plugin de acesso ou permission labels? Valide com usuários diferentes e reindexe.

---

# 18. Logs, validações e diagnóstico

## 18.1 Onde olhar primeiro

| Sintoma | Onde olhar primeiro |
|---|---|
| Página não abre | Nginx e container CKAN |
| Erro 500 | logs do CKAN |
| Erro 502 | Nginx e status do CKAN |
| Erro 413 | Nginx e limites de upload |
| Login falha | CKAN, banco e configuração de e-mail |
| Upload falha | Nginx, CKAN e storage |
| Registro não aparece | Solr, plugin de acesso, reindex |
| Facet errada | plugin de facets, Solr, reindex |
| Campo não aparece | YAML, template, plugin |
| HTTPS falha | Certbot, DNS, Nginx e firewall |
| API falha | CKAN e Nginx |

## 18.2 Validações essenciais

### Containers

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose ps
echo '===============FIM=================='
```

### API local pelo Nginx

```bash
clear
echo '===============INÍCIO==============='
curl -fsS -H "Host: SEU_DOMINIO" http://127.0.0.1/api/3/action/status_show | python3 -m json.tool
echo '===============FIM=================='
```

### Configuração CKAN

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec ckan ckan -c /etc/ckan/ckan.ini config validate
echo '===============FIM=================='
```

### Schema Scheming

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec ckan ckan -c /etc/ckan/ckan.ini shell <<'PY'
import ckanext.scheming.helpers as sh
schema = sh.scheming_get_dataset_schema('dataset')
print('SCHEMA_OK =', bool(schema))
print('dataset_type =', schema.get('dataset_type'))
print('dataset_fields =', len(schema.get('dataset_fields', [])))
print('resource_fields =', len(schema.get('resource_fields', [])))
PY
echo '===============FIM=================='
```

### Portas

```bash
clear
echo '===============INÍCIO==============='
ss -lntp | grep -E ':(22|80|443|5000|8983|5432|6379)\b' || true
echo '===============FIM=================='
```

---

# 19. Rotina segura para alterações técnicas

## 19.1 Regra geral

Antes de mexer em qualquer arquivo técnico:

1. identifique o arquivo exato;
2. faça backup;
3. registre a hipótese;
4. altere uma coisa por vez;
5. valide;
6. reinicie apenas o necessário;
7. reindexe se a alteração afetar busca, facets ou visibilidade;
8. documente o resultado.

## 19.2 Padrão de backup do projeto

Formato obrigatório:

```text
<nome>$(date +%F_%H-%M-%S).bak
```

Exemplo:

```bash
clear
echo '===============INÍCIO==============='
cp -a /caminho/arquivo /caminho/arquivo$(date +%F_%H-%M-%S).bak
echo '===============FIM=================='
```

## 19.3 Risco por tipo de alteração

| Alteração | Risco | Requer restart? | Requer rebuild? | Requer reindex? |
|---|---:|---:|---:|---:|
| CSS | Baixo | Às vezes | Não | Não |
| Imagem | Baixo | Às vezes | Não | Não |
| Template | Médio | Sim/às vezes | Às vezes | Não |
| Tradução `.po` | Médio | Sim/às vezes | Às vezes | Não |
| YAML: label | Médio | Sim | Às vezes | Normalmente não |
| YAML: campo novo | Médio/alto | Sim | Às vezes | Sim, se busca/facet |
| Plugin | Alto | Sim | Sim | Frequentemente |
| Banco direto | Alto | Não | Não | Frequentemente |
| Nginx | Médio/alto | Reload Nginx | Não | Não |
| Certbot | Médio | Reload Nginx | Não | Não |
| Dockerfile | Alto | Sim | Sim | Não |
| Compose | Alto | Sim | Às vezes | Não |

## 19.4 Ordem recomendada de diagnóstico

Quando a causa ainda não está clara, siga esta ordem:

1. reproduzir o problema;
2. olhar logs;
3. verificar configuração;
4. verificar dado real via API;
5. verificar banco, se necessário;
6. verificar Solr/indexação;
7. verificar templates;
8. verificar plugins;
9. aplicar correção mínima;
10. validar com usuário comum e admin.

---

# 20. Referência rápida - Questões frequentes

## 20.1 Quero alterar o domínio do CKAN. Onde mexo?

Verifique:

- `DOMAIN` no `.vars`;
- `ckan.site_url` no `ckan.ini`;
- configuração Nginx;
- Certbot/HTTPS;
- DNS;
- firewall.

Prováveis componentes:

```text
install_ckan_sfb_docker_full.vars
/opt/ckan-sfb-docker/nginx/default.conf
/opt/ckan-sfb-docker/ckan-config/ckan.ini
/opt/ckan-sfb-docker/letsencrypt
```

## 20.2 Quero aumentar o limite de upload. Onde mexo?

Verifique:

- `CKAN_MAX_RESOURCE_SIZE_MB`;
- `CKAN_RESOURCE_PROXY_MAX_FILE_SIZE_BYTES`;
- `NGINX_CLIENT_MAX_BODY_SIZE`;
- `ckan.max_resource_size`;
- `ckan.resource_proxy.max_file_size`.

Se o erro for 413, comece pelo Nginx.

## 20.3 Quero adicionar um campo no formulário de registro. Onde mexo?

Comece pelo YAML:

```text
/opt/ckan-sfb-docker/ckan-config/schemas/sfb_dataset.yaml
```

Depois valide:

- `ckan config validate`;
- formulário de criação;
- formulário de edição;
- página de leitura;
- API `package_show`;
- busca/facet, se aplicável.

## 20.4 Quero alterar as opções de uma lista suspensa. Onde mexo?

Normalmente no YAML, dentro de `choices`.

Se a lista for dinâmica, pode estar em plugin/helper.

## 20.5 Quero mudar a aparência da página inicial. Onde mexo?

Verifique:

```text
custom/templates/home/index.html
custom/templates/home/snippets/search.html
custom/public/css/sfb-home-hero.css
custom/public/js/sfb-home-carousel.js
custom/public/img/home-hero.jpg
```

## 20.6 Quero mudar o card de resultado na busca. Onde mexo?

Verifique:

```text
custom/templates/snippets/package_item.html
custom/templates/package/search.html
custom/public/css/sfb-custom-global.css
```

## 20.7 Quero mudar os filtros laterais. Onde mexo?

Verifique:

```text
custom/templates/snippets/facet_list.html
custom/public/sfb_facets_collapsible.css
ckanext-sfb_facets_multi/plugin.py
```

Se alterar campo/facet indexada, reindexe.

## 20.8 Quero que um campo apareça na busca/filtro. Onde mexo?

Possíveis camadas:

- YAML;
- plugin de indexação/facets;
- Solr;
- reindexação;
- template de facet.

Não basta criar o campo no YAML. O campo precisa ser indexado e incluído na facet, se for usado como filtro.

## 20.9 Um registro existe, mas não aparece na busca. O que olhar?

Verifique:

1. API `package_show`;
2. `package.private` e regra de acesso;
3. campo `sfb_acesso`;
4. plugin `sfb_access`;
5. índice Solr;
6. reindexação;
7. usuário usado no teste.

## 20.10 Um registro aparece para admin, mas não para usuário comum. O que olhar?

Verifique:

- regra de acesso;
- plugin `sfb_access`;
- permission labels;
- `package.private`;
- `sfb_acesso`;
- membership de organização/grupo;
- reindexação.

## 20.11 A API responde, mas a tela não mostra corretamente. O que olhar?

Se a API mostra o dado correto, mas a interface não:

- revise templates;
- revise helpers;
- revise CSS se for ocultação visual;
- revise traduções se for texto;
- revise browser/cache se for asset antigo.

## 20.12 A tela mostra, mas a API não traz o campo. O que olhar?

Se a tela mostra algo que a API não traz, pode ser:

- valor calculado em template/helper;
- label traduzido;
- campo não salvo no modelo;
- dado derivado de organização/grupo;
- customização apenas visual.

## 20.13 O HTTPS falhou. O que olhar?

Verifique:

- DNS do domínio;
- porta 80;
- porta 443;
- Nginx;
- Certbot;
- pasta `letsencrypt`;
- firewall;
- valor de `DOMAIN`.

## 20.14 O CKAN não sobe após mudar plugin. O que olhar?

Verifique:

- nome do plugin em `ckan.plugins`;
- erro de import Python;
- `setup.py`/instalação editable;
- logs do container CKAN;
- `ckan config validate`;
- rebuild da imagem, se o plugin foi alterado no rootfs/build.

## 20.15 Mudei YAML, mas nada mudou na tela. O que olhar?

Verifique:

- se o arquivo alterado é o arquivo realmente montado no container;
- se o CKAN foi reiniciado;
- se o schema carregou;
- se há template custom ignorando o campo;
- se o navegador está com cache antigo;
- se o campo é de `dataset_fields` ou `resource_fields`.

## 20.16 Mudei CSS, mas nada mudou. O que olhar?

Verifique:

- se o CSS está no path carregado pelo CKAN;
- se o arquivo está dentro de `extra_public_paths`;
- se o template base carrega o CSS;
- cache do navegador;
- especificidade CSS;
- se outro CSS sobrescreve depois.

## 20.17 Preciso criar uma regra nova de negócio. É YAML, template ou plugin?

Use esta regra:

| Tipo de mudança | Caminho provável |
|---|---|
| Novo campo simples | YAML |
| Nova opção de lista | YAML |
| Novo texto visual | Template ou tradução |
| Nova aparência | CSS |
| Novo comportamento no navegador | JavaScript |
| Nova regra de permissão | Plugin |
| Nova regra de busca/facet | Plugin + Solr + reindex |
| Nova ação de API | Plugin |
| Sincronização automática | Plugin |

---

# 21. Glossário rápido

| Termo | Definição |
|---|---|
| CKAN | Sistema principal de catálogo/repositório de dados |
| Registro/Dataset | Unidade principal cadastrada no CKAN |
| Recurso/Resource | Arquivo ou link associado a um registro |
| Organização/Unidade | Entidade responsável pelo registro |
| Grupo/Projeto | Agrupamento temático ou projeto, conforme customização SFB |
| YAML | Arquivo de definição de campos do `ckanext-scheming` |
| Template | Arquivo HTML/Jinja que controla a página exibida |
| CSS | Arquivo que controla aparência visual |
| JavaScript | Código executado no navegador |
| Plugin/extensão | Código Python que altera comportamento do CKAN |
| Docker | Plataforma que executa serviços isolados em containers |
| Container | Unidade isolada de execução de um serviço |
| Volume | Armazenamento persistente usado por container |
| Nginx | Servidor web/proxy reverso que recebe o acesso público |
| Certbot | Ferramenta de emissão e renovação de certificados HTTPS |
| PostgreSQL | Banco de dados principal do CKAN |
| Redis | Serviço auxiliar de cache/fila |
| Solr | Motor de busca e filtros do CKAN |
| Reindexação | Reconstrução do índice de busca Solr |
| API | Interface para consultar/manipular dados por HTTP |
| `ckan.ini` | Arquivo central de configuração do CKAN |
| `rootfs` | Estrutura do repositório que representa caminhos finais no sistema/container |

---

# 22. Referências técnicas

## 22.1 Documentação oficial CKAN

- CKAN 2.10 - Configuration Options: <https://docs.ckan.org/en/2.10/maintaining/configuration.html>
- CKAN 2.10 - Command Line Interface: <https://docs.ckan.org/en/2.10/maintaining/cli.html>
- CKAN 2.10 - Database Management: <https://docs.ckan.org/en/2.10/maintaining/database-management.html>
- CKAN 2.10 - API guide: <https://docs.ckan.org/en/2.10/api/>
- CKAN 2.10 - Theming guide: <https://docs.ckan.org/en/2.10/theming/>
- CKAN 2.10 - Plugin interfaces: <https://docs.ckan.org/en/2.10/extensions/plugin-interfaces.html>
- CKAN latest stable documentation: <https://docs.ckan.org/en/latest/>

## 22.2 Documentação de componentes externos

- Docker: <https://docs.docker.com/>
- Docker Compose: <https://docs.docker.com/compose/>
- Nginx: <https://nginx.org/en/docs/>
- Certbot: <https://eff-certbot.readthedocs.io/>
- PostgreSQL: <https://www.postgresql.org/docs/>
- Apache Solr: <https://solr.apache.org/guide/>
- Redis: <https://redis.io/docs/latest/>

## 22.3 Arquivos do projeto usados como referência

- `install_ckan_sfb_docker_full.sh`
- `install_ckan_sfb_docker_full.vars`
- `install_ckan_sfb_docker_full.secrets`
- `MANIFESTO_ROOTFS.md`
- `lista_arquivos_rootfs.txt`
- `README.md`
- `COSTA_CKAN_2017.pdf`

---

# 23. Observações finais

Este manual deve ser mantido junto ao repositório Git como documento de orientação técnica.

Recomendações de manutenção:

1. atualizar este manual sempre que o instalador Docker mudar;
2. atualizar a lista de plugins quando novos plugins forem incluídos;
3. atualizar a seção de templates quando arquivos do `rootfs` forem adicionados ou removidos;
4. registrar mudanças relevantes de YAML, facets e acesso;
5. manter segredos fora do Git;
6. nunca documentar senhas reais, tokens ou chaves privadas.

