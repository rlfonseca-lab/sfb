# Guia de customização do CKAN SFB

Este documento explica como entender, alterar e validar as customizações do CKAN SFB a partir da estrutura de arquivos do repositório, especialmente do diretório `rootfs/`.

O foco aqui não é ensinar a instalar o CKAN do zero. A instalação já é feita pelos scripts do projeto. O objetivo é mostrar onde ficam as customizações, que tipo de mudança cada arquivo controla e como fazer alterações com segurança.

---

## 1. Visão geral

A customização do CKAN SFB é formada por quatro camadas principais:

| Camada | O que controla | Exemplos de arquivos |
|---|---|---|
| Metadados | Campos do formulário de registros e recursos | `sfb_dataset.yaml` |
| Interface visual | Cores, layout, cabeçalho, rodapé, home, cards e filtros | CSS, HTML/Jinja e imagens |
| Comportamento | Acesso, filtros, projetos, grupos, rascunhos e geofacet | `ckanext-sfb_*` |
| Configuração operacional | Plugins, idioma, Nginx, Solr, uploads e paths | `ckan.ini`, Nginx, systemd, Docker |

A maior parte da customização está organizada dentro de `rootfs/`. O prefixo `rootfs/` representa a raiz do sistema final. Por exemplo:

```text
rootfs/etc/ckan/schemas/sfb_dataset.yaml
```

vira, dentro do servidor ou container:

```text
/etc/ckan/schemas/sfb_dataset.yaml
```

No instalador Docker atual, os arquivos de `/etc/ckan` são semeados no volume persistente do projeto, normalmente em:

```text
/opt/ckan-sfb-docker/ckan-config
```

Dentro do container CKAN, esse mesmo conteúdo aparece como:

```text
/etc/ckan
```

A regra prática é simples:

> Para mudanças permanentes, altere o arquivo no `rootfs/` do repositório Git. Para teste rápido, é possível alterar o arquivo já aplicado no servidor, mas depois a alteração deve voltar para o Git.

---

## 2. Antes de alterar qualquer coisa

Antes de mexer em um arquivo, faça backup. Use sempre o padrão do projeto:

```bash
clear
echo '===============INÍCIO==============='
cp -a /caminho/arquivo /caminho/arquivo$(date +%F_%H-%M-%S).bak
echo '===============FIM=================='
```

Exemplo:

```bash
clear
echo '===============INÍCIO==============='
cp -a /opt/ckan-sfb-docker/ckan-config/schemas/sfb_dataset.yaml /opt/ckan-sfb-docker/ckan-config/schemas/sfb_dataset.yaml$(date +%F_%H-%M-%S).bak
echo '===============FIM=================='
```

Também é recomendável confirmar se os containers estão ativos antes e depois da mudança:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose ps
echo '===============FIM=================='
```

---

## 3. Mapa rápido das customizações

| Tema de customização | Arquivo ou pasta principal | Quando mexer |
|---|---|---|
| Campos de registros | `rootfs/etc/ckan/schemas/sfb_dataset.yaml` | Criar, remover, renomear ou reorganizar campos do cadastro principal |
| Campos de recursos | `rootfs/etc/ckan/schemas/sfb_dataset.yaml` e templates de recurso | Alterar metadados dos arquivos, links ou anexos de um registro |
| Formulário de cadastro | `rootfs/etc/ckan/custom/templates/scheming/package/snippets/package_form.html` | Alterar a aparência ou organização dos campos no formulário |
| Exibição de metadados | `rootfs/etc/ckan/custom/templates/scheming/package/snippets/additional_info.html` | Alterar como campos extras aparecem na página do registro |
| Página do registro | `rootfs/etc/ckan/custom/templates/package/read.html` | Alterar a tela pública de um registro |
| Página do recurso | `rootfs/etc/ckan/custom/templates/package/resource_read.html` | Alterar a tela de um arquivo ou link |
| Cards da busca | `rootfs/etc/ckan/custom/templates/snippets/package_item.html` | Alterar o resumo de cada registro na listagem |
| Filtros laterais | `rootfs/etc/ckan/custom/templates/snippets/facet_list.html` e `ckanext-sfb_facets_multi` | Alterar rótulos, ordem e comportamento dos filtros |
| Cores e layout geral | `rootfs/etc/ckan/custom/public/css/sfb-custom-global.css` | Alterar identidade visual geral |
| Página inicial | `home/index.html`, `sfb-home-hero.css`, `home-hero.jpg`, `sfb-home-carousel.js` | Alterar home, hero, imagem e busca inicial |
| Cabeçalho e rodapé | `header.html`, `footer.html`, `base.html` | Alterar menus, logo, scripts globais e footer |
| Acesso e visibilidade | `ckanext-sfb_access` e `private.html` | Alterar regras público, interno, privado ou badges |
| Projetos e grupos | `ckanext-sfb_group_sync`, `ckanext-sfbgroups`, `group/read_base.html` | Alterar vínculo entre registro e projeto |
| Traduções | Arquivos `.po` e `.mo` | Trocar termos da interface sem mexer diretamente em templates |
| Infra de apoio | Nginx, systemd, Solr | Upload, proxy, portas, inicialização e segurança |

---

## 4. Campos de metadados de registros

### 4.1 Arquivo principal

Os campos do formulário principal de registros ficam em:

```text
rootfs/etc/ckan/schemas/sfb_dataset.yaml
```

No ambiente Docker instalado, o caminho prático para teste costuma ser:

```text
/opt/ckan-sfb-docker/ckan-config/schemas/sfb_dataset.yaml
```

Dentro do container:

```text
/etc/ckan/schemas/sfb_dataset.yaml
```

Esse arquivo é o coração do perfil de aplicação do CKAN SFB. Ele define:

- campos do registro;
- rótulos exibidos ao usuário;
- textos de ajuda;
- tipos de campos;
- listas controladas;
- validações;
- obrigatoriedade;
- campos de recursos;
- ordem dos campos no formulário.

No `ckanext-scheming`, os campos do registro ficam normalmente dentro do bloco:

```yaml
dataset_fields:
```

Um campo típico tem formato parecido com este:

```yaml
- field_name: status_registro
  label: Status do registro
  preset: select
  choices:
  - value: em_elaboracao
    label: Em elaboração
  - value: em_revisao
    label: Em revisão
  - value: publicado
    label: Publicado
```

### 4.2 O que cada parte significa

| Chave | Função |
|---|---|
| `field_name` | Nome técnico salvo pelo CKAN. Evite mudar depois que houver dados reais. |
| `label` | Nome exibido para o usuário. Pode ser alterado com menos risco. |
| `preset` | Modelo de campo usado pelo `ckanext-scheming`, como texto, select ou múltipla escolha. |
| `choices` | Lista de opções quando o campo é controlado. |
| `validators` | Regras de validação e limpeza do valor. |
| `form_placeholder` | Texto de exemplo dentro do campo, quando aplicável. |
| `help_text` | Texto de ajuda para orientar o usuário. |

### 4.3 Como alterar o rótulo de um campo

Exemplo: trocar o rótulo de `Status do registro` para `Situação do registro`.

Antes:

```yaml
- field_name: status_registro
  label: Status do registro
```

Depois:

```yaml
- field_name: status_registro
  label: Situação do registro
```

Esse tipo de alteração normalmente não exige reindexação, porque o valor técnico salvo não mudou. Mesmo assim, valide a configuração e reinicie o CKAN.

### 4.4 Como adicionar opção a uma lista suspensa

Exemplo:

```yaml
choices:
- value: em_elaboracao
  label: Em elaboração
- value: em_revisao
  label: Em revisão
- value: publicado
  label: Publicado
- value: arquivado
  label: Arquivado
```

Cuidados:

- `value` é o valor técnico salvo no banco.
- `label` é o texto mostrado ao usuário.
- Não reutilize o mesmo `value` para significados diferentes.
- Evite acentos e espaços no `value`.
- Prefira valores técnicos estáveis, em minúsculas e com underscore.

Bom:

```yaml
value: em_revisao
```

Ruim:

```yaml
value: Em Revisão
```

### 4.5 Como remover um campo

Em projeto institucional, é melhor comentar primeiro, não apagar de imediato. Assim a alteração fica documentada.

```yaml
# Campo desativado em 2026-05-04. Motivo: removido do formulário do piloto.
# - field_name: id_arquivo_origem
#   label: ID do arquivo de origem
#   preset: text
```

Cuidados:

- Remover do YAML impede que o campo seja editado pelo formulário.
- Dados antigos podem continuar no banco como extras.
- Se o campo aparecia em busca/facet/card, também será necessário revisar templates e plugins.

### 4.6 Como validar alteração no schema

Depois de alterar `sfb_dataset.yaml`, rode:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec -T ckan ckan -c /etc/ckan/ckan.ini config validate
echo '===============FIM=================='
```

Depois teste se o schema carrega:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec -T ckan ckan -c /etc/ckan/ckan.ini shell <<'PY'
import ckanext.scheming.helpers as sh
schema = sh.scheming_get_dataset_schema('dataset')
print('SCHEMA_OK =', bool(schema))
print('dataset_type =', schema.get('dataset_type'))
print('dataset_fields =', len(schema.get('dataset_fields', [])))
print('resource_fields =', len(schema.get('resource_fields', [])))
PY
echo '===============FIM=================='
```

### 4.7 Quando reindexar

Reindexe quando a alteração afetar busca, listagem ou filtros. Exemplos:

- campo novo usado como facet;
- alteração de campo usado no card de busca;
- mudança em plugin de facets;
- saneamento de valores antigos;
- alteração em acesso/visibilidade que dependa do índice.

Comando:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec -T ckan ckan -c /etc/ckan/ckan.ini search-index rebuild
echo '===============FIM=================='
```

---

## 5. Campos de metadados de arquivos de registros, ou Recursos

No CKAN, um registro é o cadastro principal. Dentro dele podem existir um ou mais recursos. Um recurso pode ser:

- arquivo PDF;
- planilha;
- shapefile compactado;
- imagem;
- link externo;
- qualquer outro anexo aceito pela configuração.

### 5.1 Onde ficam os campos de recurso

No mesmo schema:

```text
rootfs/etc/ckan/schemas/sfb_dataset.yaml
```

Os campos de recurso ficam normalmente em:

```yaml
resource_fields:
```

Exemplo simplificado:

```yaml
resource_fields:
- field_name: name
  label: Nome do arquivo
  preset: resource_name
- field_name: description
  label: Descrição do arquivo
  preset: markdown
- field_name: format
  label: Formato
  preset: resource_format_autocomplete
```

### 5.2 Quando um campo deve ser do registro e quando deve ser do recurso

Use esta regra prática:

| Pergunta | Onde o campo deve ficar |
|---|---|
| A informação descreve o produto técnico como um todo? | Registro, em `dataset_fields` |
| A informação descreve apenas um arquivo específico? | Recurso, em `resource_fields` |
| O valor será igual para todos os arquivos do registro? | Registro |
| Cada arquivo pode ter um valor diferente? | Recurso |

Exemplo:

- `Unidade responsável`: registro.
- `Formato do arquivo`: recurso.
- `Licença do produto`: normalmente registro.
- `Escala de uma camada geográfica específica`: recurso, se variar por arquivo.

### 5.3 Templates envolvidos na exibição de recursos

Os principais arquivos são:

```text
rootfs/etc/ckan/custom/templates/package/resource_read.html
rootfs/etc/ckan/custom/templates/package/snippets/resource_item.html
rootfs/etc/ckan/custom/templates/scheming/package/resource_read.html
```

Uso típico:

| Arquivo | Função |
|---|---|
| `package/resource_read.html` | Tela principal de leitura de um recurso |
| `package/snippets/resource_item.html` | Item do recurso na lista de recursos do registro |
| `scheming/package/resource_read.html` | Exibição de metadados de recurso definidos pelo schema |

### 5.4 Cuidados ao alterar recursos

- Evite duplicar no recurso campos que já foram preenchidos no registro.
- Se o campo for obrigatório, teste criação e edição de recurso.
- Se alterar upload, revise limites do CKAN e do Nginx.
- Se a tela de edição de recurso ficar estranha, suspeite primeiro de template ou CSS.

---

## 6. Cores, design e layout geral

### 6.1 Arquivo principal de CSS

A identidade visual principal fica em:

```text
rootfs/etc/ckan/custom/public/css/sfb-custom-global.css
```

Esse arquivo controla, em geral:

- cabeçalho;
- menu;
- botões;
- cards;
- formulários;
- tabelas;
- filtros;
- rodapé;
- espaçamento;
- limpeza visual da interface.

### 6.2 CSS da página inicial

```text
rootfs/etc/ckan/custom/public/css/sfb-home-hero.css
```

Use este arquivo para alterar apenas a página inicial, principalmente:

- bloco hero;
- imagem de destaque;
- chamada de busca;
- textos de entrada;
- organização visual da home.

### 6.3 CSS dos filtros laterais

```text
rootfs/etc/ckan/custom/public/sfb_facets_collapsible.css
```

Use este arquivo para ajustes nos filtros laterais da busca:

- abrir e fechar blocos;
- espaçamento entre filtros;
- tamanho de fonte;
- rótulos longos;
- comportamento visual das facets.

### 6.4 Templates globais

```text
rootfs/etc/ckan/custom/templates/base.html
rootfs/etc/ckan/custom/templates/header.html
rootfs/etc/ckan/custom/templates/footer.html
```

| Arquivo | Função |
|---|---|
| `base.html` | Base geral de todas as páginas |
| `header.html` | Topo, logo, navegação, menu de usuário |
| `footer.html` | Rodapé, textos institucionais e links finais |

### 6.5 Imagens e logo

```text
rootfs/etc/ckan/public/images/logo.png
rootfs/usr/lib/ckan/ckan/ckan/public/base/images/ckan-logo.png
rootfs/etc/ckan/custom/public/img/home-hero.jpg
```

Cuidados:

- Mantenha nomes iguais se o template já aponta para eles.
- Otimize imagens para web.
- Evite imagens enormes na home, pois deixam o portal pesado.
- Se trocar uma imagem e ela não aparecer, teste cache do navegador e carregamento do asset.

### 6.6 Como validar CSS e imagens

Depois da mudança:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose restart ckan nginx
curl -I -k https://SEU_DOMINIO/css/sfb-custom-global.css
curl -I -k https://SEU_DOMINIO/css/sfb-home-hero.css
curl -I -k https://SEU_DOMINIO/sfb_facets_collapsible.css
echo '===============FIM=================='
```

Se estiver testando localmente pelo próprio servidor:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
curl -I -H 'Host: SEU_DOMINIO' http://127.0.0.1/css/sfb-custom-global.css
curl -I -H 'Host: SEU_DOMINIO' http://127.0.0.1/sfb_facets_collapsible.css
echo '===============FIM=================='
```

---

## 7. Página inicial

A página inicial é uma combinação de template, CSS, imagem e JavaScript.

### 7.1 Arquivos principais

```text
rootfs/etc/ckan/custom/templates/home/index.html
rootfs/etc/ckan/custom/templates/home/snippets/search.html
rootfs/etc/ckan/custom/templates/home/snippets/search_advanced.html
rootfs/etc/ckan/custom/public/css/sfb-home-hero.css
rootfs/etc/ckan/custom/public/img/home-hero.jpg
rootfs/etc/ckan/custom/public/js/sfb-home-carousel.js
rootfs/usr/lib/ckan/ckan/ckan/templates/home/snippets/promoted.html
```

### 7.2 O que mexer em cada arquivo

| Arquivo | Quando mexer |
|---|---|
| `home/index.html` | Alterar estrutura da home |
| `home/snippets/search.html` | Alterar bloco de busca simples |
| `home/snippets/search_advanced.html` | Alterar busca avançada ou links auxiliares |
| `sfb-home-hero.css` | Alterar visual da home |
| `home-hero.jpg` | Trocar imagem principal |
| `sfb-home-carousel.js` | Alterar comportamento de carrossel ou alternância visual |
| `promoted.html` | Controlar ou neutralizar bloco promovido nativo do CKAN |

### 7.3 Cuidados

- Evite colocar lógica complexa no template da home.
- Textos institucionais fixos podem ir no template, mas textos reutilizados devem preferir tradução ou configuração.
- Alterações visuais da home devem ir em `sfb-home-hero.css`, não no CSS global, sempre que possível.

---

## 8. Busca, listagem de registros e filtros

A página de busca é uma das áreas mais importantes do portal. Ela junta resultados, cards, ordenação e filtros laterais.

### 8.1 Arquivos principais

```text
rootfs/etc/ckan/custom/templates/package/search.html
rootfs/etc/ckan/custom/templates/snippets/package_item.html
rootfs/etc/ckan/custom/templates/snippets/facet_list.html
rootfs/etc/ckan/custom/public/sfb_facets_collapsible.css
rootfs/usr/lib/ckan/venv/src/ckanext-sfb_facets_multi/ckanext/sfb_facets_multi/plugin.py
rootfs/usr/lib/ckan/venv/src/ckanext-sfb_geo_facet/ckanext/sfb_geo_facet/plugin.py
```

### 8.2 Cards de registros

O card de cada registro na busca é controlado por:

```text
rootfs/etc/ckan/custom/templates/snippets/package_item.html
```

Use esse arquivo para alterar informações resumidas como:

- título;
- descrição;
- unidade;
- projeto;
- status;
- licença;
- acesso;
- CCD;
- escopo;
- abrangência.

Cuidados:

- O campo precisa estar disponível no objeto do pacote ou no índice.
- Se o campo novo não aparecer, talvez seja necessário reindexar.
- Não coloque consultas pesadas dentro do template. Template deve renderizar, não processar grandes regras.

### 8.3 Filtros laterais

A renderização visual dos filtros fica em:

```text
rootfs/etc/ckan/custom/templates/snippets/facet_list.html
```

O comportamento de quais campos viram filtros costuma ficar em:

```text
rootfs/usr/lib/ckan/venv/src/ckanext-sfb_facets_multi/ckanext/sfb_facets_multi/plugin.py
```

Use o plugin quando precisar:

- adicionar um campo como filtro;
- remover um filtro;
- mudar a ordem dos filtros;
- tratar campo de múltiplos valores;
- mudar rótulo técnico de facet;
- mapear valor interno para rótulo legível.

### 8.4 Quando reindexar filtros

Sempre que mexer na indexação, rode:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec -T ckan ckan -c /etc/ckan/ckan.ini search-index rebuild
echo '===============FIM=================='
```

Depois valide no navegador:

```text
https://SEU_DOMINIO/dataset
```

---

## 9. Projetos, grupos e unidades

O CKAN possui conceitos nativos chamados `organizations` e `groups`. No CKAN SFB, esses conceitos são adaptados na interface para ficar mais próximos da organização institucional.

### 9.1 Arquivos envolvidos

```text
rootfs/etc/ckan/custom/templates/group/read_base.html
rootfs/etc/ckan/custom/templates/organization/read.html
rootfs/usr/lib/ckan/venv/src/ckanext-sfb_group_sync/ckanext/sfb_group_sync/plugin.py
rootfs/usr/lib/ckan/venv/src/ckanext-sfbgroups/ckanext/sfbgroups/plugin.py
```

### 9.2 Função de cada parte

| Parte | Função |
|---|---|
| `group/read_base.html` | Apresentar grupos como projetos na interface |
| `organization/read.html` | Adaptar organizações como unidades responsáveis ou institucionais |
| `ckanext-sfb_group_sync` | Sincronizar campo de projeto/grupo com grupos internos do CKAN |
| `ckanext-sfbgroups` | Fornecer helpers para listar grupos como opções no formulário |

### 9.3 Cuidados

- Mudar texto de “Grupo” para “Projeto” na interface não muda a estrutura interna do CKAN.
- Se um registro aparece no projeto errado, revise tanto o valor salvo no schema quanto a sincronização feita pela extensão.
- Se o projeto aparece vazio, pode ser problema de valor legado, helper, template ou indexação.

---

## 10. Acesso, visibilidade e badges

Acesso é uma das partes mais sensíveis da customização. Não trate como simples CSS.

### 10.1 Arquivos principais

```text
rootfs/usr/lib/ckan/venv/src/ckanext-sfb_access/ckanext/sfb_access/plugin.py
rootfs/usr/lib/ckan/venv/src/ckanext-sfb_access/ckanext/sfb_access/managed_access_phase1.py
rootfs/etc/ckan/custom/templates/package/snippets/private.html
```

### 10.2 Diferença entre regra visual e regra real

| Elemento | O que faz |
|---|---|
| Badge | Mostra um aviso visual, como Público, Interno ou Privado |
| Campo `sfb_acesso` | Representa a regra de negócio do SFB |
| `package.private` | Flag nativa do CKAN para privacidade do dataset |
| Plugin de acesso | Decide quem pode ver o quê |
| Índice Solr | Afeta busca e visibilidade em listagens |

Erro comum:

> Achar que esconder o badge resolve permissão.

Não resolve. Badge é camada visual. Permissão real precisa estar correta no plugin e, em alguns casos, no índice de busca.

### 10.3 Procedimento seguro para mexer em acesso

1. Faça backup do plugin.
2. Defina a regra em texto simples antes de codar.
3. Teste com usuário anônimo.
4. Teste com usuário comum logado.
5. Teste com criador do registro.
6. Teste com sysadmin.
7. Reindexe se a regra afetar busca.

Comando de backup:

```bash
clear
echo '===============INÍCIO==============='
cp -a /opt/ckan-sfb-docker/repo/sfb/rootfs/usr/lib/ckan/venv/src/ckanext-sfb_access/ckanext/sfb_access/plugin.py /opt/ckan-sfb-docker/repo/sfb/rootfs/usr/lib/ckan/venv/src/ckanext-sfb_access/ckanext/sfb_access/plugin.py$(date +%F_%H-%M-%S).bak
echo '===============FIM=================='
```

Depois de alterar extensão Python, reconstrua a imagem do CKAN:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose build --no-cache ckan
docker compose up -d ckan
echo '===============FIM=================='
```

Valide imports:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec -T ckan python - <<'PY'
mods = [
    'ckanext.sfb_access.plugin',
    'ckanext.sfb_facets_multi.plugin',
    'ckanext.sfb_geo_facet.plugin',
    'ckanext.sfb_group_sync.plugin',
    'ckanext.sfbgroups.plugin',
]
for mod in mods:
    __import__(mod)
    print('OK import:', mod)
PY
echo '===============FIM=================='
```

---

## 11. Traduções e textos da interface

Alguns textos podem ser alterados diretamente em templates. Outros podem ser tratados por tradução.

### 11.1 Arquivos de tradução

```text
rootfs/opt/ckan/extra_translations/i18n/pt_BR/LC_MESSAGES/ckan.po
rootfs/opt/ckan/extra_translations/i18n/pt_BR/LC_MESSAGES/sfb_ui.po
rootfs/opt/ckan/extra_translations/pt_BR/LC_MESSAGES/sfb_ui.po
rootfs/usr/lib/ckan/ckan/ckan/i18n/pt_BR/LC_MESSAGES/ckan.po
rootfs/usr/lib/ckan/ckan/ckan/i18n/pt_BR/LC_MESSAGES/ckan.mo
```

### 11.2 Quando usar tradução

Use tradução quando quiser trocar termos recorrentes, por exemplo:

- Dataset para Registro;
- Organization para Unidade;
- Group para Projeto;
- Resource para Arquivo;
- termos institucionais específicos.

### 11.3 Quando usar template

Use template quando a mudança for estrutural:

- esconder um bloco;
- reorganizar campos;
- mudar layout;
- adicionar uma lista;
- alterar uma tela específica.

### 11.4 Compilar traduções

Depois de alterar `.po`, compile para `.mo`:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec -T ckan bash -lc "find /opt/ckan/extra_translations -type f -name '*.po' -print -exec sh -c 'msgfmt \"$1\" -o \"${1%.po}.mo\"' sh {} \;"
docker compose restart ckan
echo '===============FIM=================='
```

---

## 12. Extensões customizadas SFB

As extensões Python ficam em:

```text
rootfs/usr/lib/ckan/venv/src/
```

### 12.1 Lista de extensões

| Extensão | Função principal |
|---|---|
| `ckanext-sfb_access` | Regras de acesso, leitura e visibilidade |
| `ckanext-sfb_facets_multi` | Filtros customizados e facets com múltiplos valores |
| `ckanext-sfb_geo_facet` | Facet/filtro geográfico |
| `ckanext-sfb_group_sync` | Sincronização entre registro e grupo/projeto |
| `ckanext-sfbdraftsearch` | Tratamento de busca/listagem de rascunhos |
| `ckanext-sfbgroups` | Helpers para grupos/projetos no formulário |

### 12.2 Quando mexer em extensão

Mexa em extensão quando a mudança for de comportamento, não apenas visual.

Exemplos:

| Necessidade | Onde mexer |
|---|---|
| Mudar quem pode ver registros internos | `ckanext-sfb_access` |
| Adicionar novo filtro baseado em campo custom | `ckanext-sfb_facets_multi` |
| Corrigir associação automática com projeto | `ckanext-sfb_group_sync` |
| Alterar opções dinâmicas de projeto no formulário | `ckanext-sfbgroups` |
| Ajustar filtro geográfico | `ckanext-sfb_geo_facet` |

### 12.3 Validação depois de alterar extensão

Como extensão Python entra na imagem Docker, a rotina segura é:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose build --no-cache ckan
docker compose up -d ckan
docker compose exec -T ckan ckan -c /etc/ckan/ckan.ini config validate
echo '===============FIM=================='
```

---

## 13. Configurações do CKAN relacionadas à customização

### 13.1 Arquivo de referência

```text
rootfs/etc/ckan/ckan.ini.example
```

Esse arquivo é uma referência documental. O instalador não deve simplesmente substituir o `ckan.ini` real sem cuidado, porque o `ckan.ini` contém informações específicas da instância.

### 13.2 Configurações importantes

| Configuração | Função |
|---|---|
| `ckan.plugins` | Lista de plugins ativos |
| `extra_template_paths` | Caminho dos templates customizados |
| `extra_public_paths` | Caminho de CSS, JS, imagens e assets customizados |
| `scheming.presets` | Presets do `ckanext-scheming` |
| `scheming.dataset_schemas` | Caminho do schema SFB |
| `scheming.dataset_fallback` | Define fallback de schema |
| `ckan.locale_default` | Idioma padrão |
| `ckan.i18n.extra_directory` | Diretório de traduções extras |
| `ckan.max_resource_size` | Limite de upload no CKAN |
| `ckan.resource_proxy.max_file_size` | Limite para proxy/preview de recursos |

### 13.3 Plugins esperados

A configuração do projeto usa uma lista parecida com:

```text
activity scheming_datasets sfb_facets_multi sfb_geo_facet sfb_access sfb_group_sync sfbgroups sfb_drafts_search
```

Se um plugin estiver na lista mas a extensão não existir ou não instalar corretamente, o CKAN pode não subir.

---

## 14. Nginx, upload e HTTPS

### 14.1 Arquivo de Nginx

```text
rootfs/etc/nginx/sites-available/ckan
```

No Docker, o Nginx é gerado pelo script dentro do diretório do projeto, geralmente em:

```text
/opt/ckan-sfb-docker/nginx/default.conf
```

### 14.2 Quando mexer no Nginx

Mexa no Nginx quando precisar alterar:

- domínio;
- limite de upload;
- proxy reverso;
- cabeçalhos;
- HTTP/HTTPS;
- timeout de conexão;
- comportamento de certificados.

### 14.3 Erro 413 ao enviar arquivo

O erro `413 Request Entity Too Large` normalmente indica limite de upload no Nginx ou no CKAN.

Revise:

```text
NGINX_CLIENT_MAX_BODY_SIZE
CKAN_MAX_RESOURCE_SIZE_MB
CKAN_RESOURCE_PROXY_MAX_FILE_SIZE_BYTES
```

Depois reinicie:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose restart ckan nginx
echo '===============FIM=================='
```

---

## 15. Systemd e Solr

Na instalação Docker, systemd não é o centro da execução do CKAN. Mesmo assim, o `rootfs/` mantém arquivos de referência para instalação sem containers ou ambientes híbridos:

```text
rootfs/etc/systemd/system/ckan.service.d/20-wait-solr.conf
rootfs/etc/systemd/system/ckan.service.d/99-bind-local.conf
rootfs/etc/systemd/system/ckan.service.d/solr.conf
rootfs/etc/systemd/system/solr.service
```

Função:

| Arquivo | Função |
|---|---|
| `20-wait-solr.conf` | Faz o CKAN aguardar o Solr antes de iniciar |
| `99-bind-local.conf` | Força CKAN em `127.0.0.1:5000` |
| `solr.conf` | Reforça dependência entre CKAN e Solr |
| `solr.service` | Define serviço Solr customizado |

Em Docker, o equivalente operacional está no `docker-compose.yml`, com healthchecks e dependências entre containers.

---

## 16. Como aplicar mudanças no Docker

A forma de aplicar depende do tipo de arquivo alterado.

### 16.1 Alteração em `/etc/ckan`, schema, templates, CSS ou imagens

Se você alterou arquivos no volume aplicado, por exemplo:

```text
/opt/ckan-sfb-docker/ckan-config
```

normalmente basta reiniciar CKAN e Nginx:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose restart ckan nginx
echo '===============FIM=================='
```

Se a alteração foi no repositório em `rootfs/etc/ckan`, reaplique a customização pelo fluxo do instalador ou copie para o volume com cuidado.

### 16.2 Alteração em extensão Python

Se alterou qualquer arquivo em:

```text
rootfs/usr/lib/ckan/venv/src/ckanext-*
```

reconstrua a imagem do CKAN:

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose build --no-cache ckan
docker compose up -d ckan
echo '===============FIM=================='
```

### 16.3 Alteração em Nginx

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec -T nginx nginx -t
docker compose exec -T nginx nginx -s reload
echo '===============FIM=================='
```

### 16.4 Alteração em `.vars` ou `.secrets`

Se a alteração envolve variáveis estruturais da instalação, rode novamente o instalador conforme o README do projeto. Não edite o `.env` gerado manualmente como fonte oficial, porque ele é produto do script.

---

## 17. Checklist de validação depois de customizar

### 17.1 Validação técnica

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose ps
docker compose exec -T ckan ckan -c /etc/ckan/ckan.ini config validate
curl -fsS -H 'Host: SEU_DOMINIO' http://127.0.0.1/api/3/action/status_show | python3 -m json.tool
echo '===============FIM=================='
```

### 17.2 Validação de tela

Confira no navegador:

```text
https://SEU_DOMINIO/
https://SEU_DOMINIO/dataset
https://SEU_DOMINIO/organization
https://SEU_DOMINIO/group
```

### 17.3 Validação funcional

Teste pelo menos:

- criar registro;
- editar registro;
- adicionar recurso;
- editar recurso;
- pesquisar registro;
- usar filtros;
- abrir página do registro;
- abrir página do recurso;
- testar usuário anônimo;
- testar usuário comum;
- testar sysadmin.

---

## 18. Erros comuns e onde procurar

| Sintoma | Onde investigar primeiro |
|---|---|
| Campo não aparece no cadastro | `sfb_dataset.yaml` e `package_form.html` |
| Campo aparece mas não salva | `validators`, `preset`, schema e logs do CKAN |
| Campo salva mas não aparece na leitura | `additional_info.html` ou `package/read.html` |
| Campo não aparece no card da busca | `package_item.html` e índice Solr |
| Filtro não aparece | `ckanext-sfb_facets_multi` e reindexação |
| Texto do filtro aparece cortado | `facet_list.html` e `sfb_facets_collapsible.css` |
| Upload falha com 413 | Nginx e limites de upload do CKAN |
| Tela de recurso fica confusa | Templates de recurso e CSS global |
| Registro aparece no projeto errado | `sfb_grupo`, `ckanext-sfb_group_sync` e reindexação |
| Usuário não vê registro que deveria ver | `ckanext-sfb_access`, `sfb_acesso`, `package.private` e índice |
| Tradução não muda | `.po` não compilado para `.mo`, cache ou CKAN não reiniciado |
| CKAN não sobe após mudança | `docker compose logs ckan`, plugin quebrado ou `ckan.ini` inválido |

---

## 19. Fluxo recomendado para qualquer customização

Use sempre este fluxo:

1. Identifique o tema da mudança.
2. Localize o arquivo correto no mapa deste guia.
3. Faça backup no padrão do projeto.
4. Altere primeiro em ambiente de teste.
5. Valide `ckan config validate`.
6. Reinicie o necessário.
7. Teste no navegador.
8. Reindexe se afetar busca, filtros ou acesso.
9. Registre a mudança no Git.
10. Só então aplique em produção.

---

## 20. Comandos úteis de diagnóstico

### Ver logs do CKAN

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose logs --tail=160 ckan
echo '===============FIM=================='
```

### Ver logs do Nginx

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose logs --tail=160 nginx
echo '===============FIM=================='
```

### Entrar no shell do CKAN

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec ckan bash
echo '===============FIM=================='
```

### Testar API local via Nginx

```bash
clear
echo '===============INÍCIO==============='
curl -fsS -H 'Host: SEU_DOMINIO' http://127.0.0.1/api/3/action/status_show | python3 -m json.tool
echo '===============FIM=================='
```

### Testar Solr

```bash
clear
echo '===============INÍCIO==============='
cd /opt/ckan-sfb-docker
docker compose exec -T solr wget -qO- http://localhost:8983/solr/ckan/admin/ping?wt=json
echo '===============FIM=================='
```

### Conferir portas públicas e locais

```bash
clear
echo '===============INÍCIO==============='
ss -lntp | grep -E ':(80|443|5000|5432|6379|8983)\b' || true
echo '===============FIM=================='
```

---

## 21. Referência por tema

### Campos

```text
rootfs/etc/ckan/schemas/sfb_dataset.yaml
rootfs/usr/lib/ckan/venv/src/ckanext-scheming/ckanext/scheming/scheming_presets_custom.json
```

### Templates principais

```text
rootfs/etc/ckan/custom/templates/base.html
rootfs/etc/ckan/custom/templates/header.html
rootfs/etc/ckan/custom/templates/footer.html
rootfs/etc/ckan/custom/templates/package/read.html
rootfs/etc/ckan/custom/templates/package/resource_read.html
rootfs/etc/ckan/custom/templates/package/search.html
```

### Snippets importantes

```text
rootfs/etc/ckan/custom/templates/scheming/package/snippets/package_form.html
rootfs/etc/ckan/custom/templates/scheming/package/snippets/additional_info.html
rootfs/etc/ckan/custom/templates/snippets/package_item.html
rootfs/etc/ckan/custom/templates/snippets/facet_list.html
rootfs/etc/ckan/custom/templates/package/snippets/private.html
rootfs/etc/ckan/custom/templates/package/snippets/resource_item.html
```

### CSS e assets

```text
rootfs/etc/ckan/custom/public/css/sfb-custom-global.css
rootfs/etc/ckan/custom/public/css/sfb-home-hero.css
rootfs/etc/ckan/custom/public/sfb_facets_collapsible.css
rootfs/etc/ckan/custom/public/img/home-hero.jpg
rootfs/etc/ckan/custom/public/js/sfb-home-carousel.js
rootfs/etc/ckan/public/images/logo.png
```

### Extensões

```text
rootfs/usr/lib/ckan/venv/src/ckanext-sfb_access
rootfs/usr/lib/ckan/venv/src/ckanext-sfb_facets_multi
rootfs/usr/lib/ckan/venv/src/ckanext-sfb_geo_facet
rootfs/usr/lib/ckan/venv/src/ckanext-sfb_group_sync
rootfs/usr/lib/ckan/venv/src/ckanext-sfbdraftsearch
rootfs/usr/lib/ckan/venv/src/ckanext-sfbgroups
```

### Traduções

```text
rootfs/opt/ckan/extra_translations/i18n/pt_BR/LC_MESSAGES/ckan.po
rootfs/opt/ckan/extra_translations/i18n/pt_BR/LC_MESSAGES/sfb_ui.po
rootfs/opt/ckan/extra_translations/pt_BR/LC_MESSAGES/sfb_ui.po
rootfs/usr/lib/ckan/ckan/ckan/i18n/pt_BR/LC_MESSAGES/ckan.po
rootfs/usr/lib/ckan/ckan/ckan/i18n/pt_BR/LC_MESSAGES/ckan.mo
```

### Infra

```text
rootfs/etc/nginx/sites-available/ckan
rootfs/etc/systemd/system/ckan.service.d/20-wait-solr.conf
rootfs/etc/systemd/system/ckan.service.d/99-bind-local.conf
rootfs/etc/systemd/system/ckan.service.d/solr.conf
rootfs/etc/systemd/system/solr.service
```

---

## 22. Recomendações finais

1. Nunca trate `rootfs/` como uma pasta qualquer. Ela é a forma como a customização vira sistema real.
2. Evite alterar arquivos diretamente dentro do container sem registrar no Git.
3. Para campos, comece pelo `sfb_dataset.yaml`.
4. Para visual, comece pelos CSS e templates em `/etc/ckan/custom`.
5. Para comportamento, procure as extensões `ckanext-sfb_*`.
6. Para acesso, teste sempre com perfis diferentes de usuário.
7. Para filtros e busca, lembre da reindexação.
8. Para tradução, não esqueça de compilar `.po` para `.mo`.
9. Para produção, faça backup antes e tenha plano de rollback.
10. Ao terminar, rode validação técnica e validação visual.

