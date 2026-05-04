# Manifesto dos arquivos do `rootfs`

Este documento lista os arquivos presentes no diretório `rootfs/` do repositório SFB e descreve a função de cada um dentro da customização do CKAN.

Escopo:

- considera apenas arquivos existentes dentro de `rootfs/`;
- não compara com uma instalação vanilla;
- não classifica arquivos como criados ou alterados;
- remove o prefixo `rootfs/` para indicar o caminho final esperado no servidor ou container.

---

# `/etc/ckan`

## `ckan.ini.example`

- **Path:** `/etc/ckan`
- **Função:** arquivo de exemplo do `ckan.ini` com a configuração de referência da instância CKAN SFB. Serve como modelo documental para plugins, idioma, paths customizados, schema, storage, busca, upload e demais parâmetros principais que o instalador deve aplicar ao `ckan.ini` real.

---

# `/etc/ckan/custom/public/css`

## `sfb-custom-global.css`

- **Path:** `/etc/ckan/custom/public/css`
- **Função:** CSS global principal da identidade visual SFB. Controla aparência geral do portal, incluindo cabeçalho, menus, botões, cards, formulários, listagens, filtros, rodapé, ajustes de espaçamento e limpeza visual da interface.

## `sfb-home-hero.css`

- **Path:** `/etc/ckan/custom/public/css`
- **Função:** CSS específico da página inicial. Controla o bloco visual principal da home, incluindo área hero, chamada de busca, imagem de destaque, layout dos elementos iniciais e apresentação visual da entrada do portal.

---

# `/etc/ckan/custom/public/img`

## `home-hero.jpg`

- **Path:** `/etc/ckan/custom/public/img`
- **Função:** imagem de destaque usada na página inicial do CKAN SFB, normalmente aplicada como imagem de fundo ou elemento visual do bloco hero.

---

# `/etc/ckan/custom/public/js`

## `sfb-home-carousel.js`

- **Path:** `/etc/ckan/custom/public/js`
- **Função:** JavaScript da página inicial responsável pelo comportamento de carrossel ou alternância visual de elementos da home, quando usado pelo template customizado da página inicial.

---

# `/etc/ckan/custom/public`

## `sfb_facets_collapsible.css`

- **Path:** `/etc/ckan/custom/public`
- **Função:** CSS específico dos filtros laterais da busca. Ajusta o visual das facets, incluindo comportamento de blocos recolhíveis/expansíveis, espaçamento, leitura dos rótulos e apresentação dos filtros customizados.

---

# `/etc/ckan/custom/templates`

## `base.html`

- **Path:** `/etc/ckan/custom/templates`
- **Função:** template base global do CKAN SFB. Serve como camada principal de override visual e permite carregar CSS, JavaScript, estrutura de página e elementos globais em todas as telas do portal.

## `footer.html`

- **Path:** `/etc/ckan/custom/templates`
- **Função:** template customizado do rodapé. Define a aparência e o conteúdo do footer do portal, incluindo identidade institucional, links, textos e estrutura visual inferior.

## `header.html`

- **Path:** `/etc/ckan/custom/templates`
- **Função:** template customizado do cabeçalho. Controla logo, navegação principal, menu superior, área de usuário e identidade visual exibida no topo do CKAN SFB.

---

# `/etc/ckan/custom/templates/group`

## `read_base.html`

- **Path:** `/etc/ckan/custom/templates/group`
- **Função:** template base da página de leitura de grupos. No CKAN SFB, é usado para adaptar a apresentação de grupos como “Projetos”, ajustando layout, nomenclatura e estrutura visual sem necessariamente alterar a lógica interna nativa do CKAN.

---

# `/etc/ckan/custom/templates/home`

## `index.html`

- **Path:** `/etc/ckan/custom/templates/home`
- **Função:** template principal da página inicial. Define a composição da home do portal CKAN SFB, incluindo blocos de destaque, busca inicial, chamadas institucionais, cards e organização visual da entrada do sistema.

---

# `/etc/ckan/custom/templates/home/snippets`

## `search.html`

- **Path:** `/etc/ckan/custom/templates/home/snippets`
- **Função:** snippet do bloco de busca da página inicial. Controla o campo de busca apresentado na home e a forma como o usuário inicia a pesquisa por registros.

## `search_advanced.html`

- **Path:** `/etc/ckan/custom/templates/home/snippets`
- **Função:** snippet de busca avançada da página inicial. Controla links, opções ou elementos complementares de pesquisa exibidos junto ao bloco de busca da home.

---

# `/etc/ckan/custom/templates/organization`

## `read.html`

- **Path:** `/etc/ckan/custom/templates/organization`
- **Função:** template da página de leitura de organização. No CKAN SFB, adapta a visualização das organizações, tratadas na interface como unidades responsáveis ou unidades institucionais.

---

# `/etc/ckan/custom/templates/package`

## `read.html`

- **Path:** `/etc/ckan/custom/templates/package`
- **Função:** template principal da página de leitura de um registro/dataset. Controla a exibição pública do registro, incluindo metadados, recursos associados, informações institucionais e elementos customizados do perfil SFB.

## `resource_read.html`

- **Path:** `/etc/ckan/custom/templates/package`
- **Função:** template da página de leitura de um recurso. Controla como o CKAN exibe um arquivo, link ou recurso associado a um registro, incluindo seus metadados e ações disponíveis.

## `search.html`

- **Path:** `/etc/ckan/custom/templates/package`
- **Função:** template da página de busca/listagem de registros. Controla a estrutura da busca, a área de resultados, filtros laterais, ordenação e elementos visuais da listagem de datasets.

---

# `/etc/ckan/custom/templates/package/snippets`

## `private.html`

- **Path:** `/etc/ckan/custom/templates/package/snippets`
- **Função:** snippet de exibição de badge de visibilidade. Customiza a forma como o CKAN exibe marcações como privado, interno ou outros estados de acesso definidos pela lógica SFB.

## `resource_item.html`

- **Path:** `/etc/ckan/custom/templates/package/snippets`
- **Função:** snippet de item de recurso. Controla como cada recurso aparece na lista de arquivos/links dentro da página de um registro.

---

# `/etc/ckan/custom/templates/scheming/package`

## `resource_read.html`

- **Path:** `/etc/ckan/custom/templates/scheming/package`
- **Função:** template de leitura de recurso integrado ao `ckanext-scheming`. Ajusta a forma como metadados de recursos definidos pelo schema SFB são exibidos na página do recurso.

---

# `/etc/ckan/custom/templates/scheming/package/snippets`

## `additional_info.html`

- **Path:** `/etc/ckan/custom/templates/scheming/package/snippets`
- **Função:** snippet de informações adicionais do `ckanext-scheming`. Controla a exibição dos campos extras do schema SFB na página de leitura do registro, organizando metadados customizados além dos campos nativos do CKAN.

## `package_form.html`

- **Path:** `/etc/ckan/custom/templates/scheming/package/snippets`
- **Função:** snippet do formulário de criação/edição de registros via `ckanext-scheming`. Controla como os campos do schema SFB aparecem no formulário, incluindo organização visual, campos customizados e comportamento do cadastro.

---

# `/etc/ckan/custom/templates/snippets`

## `facet_list.html`

- **Path:** `/etc/ckan/custom/templates/snippets`
- **Função:** snippet da lista de filtros/facets. Controla a renderização dos filtros laterais na busca, incluindo rótulos, contagens, links, exibição completa de textos e integração visual com os filtros customizados SFB.

## `package_item.html`

- **Path:** `/etc/ckan/custom/templates/snippets`
- **Função:** snippet do card/item de registro na listagem. Controla o que aparece para cada dataset nos resultados de busca, incluindo título, descrição, unidade, status, licença, acesso e outros metadados resumidos.

---

# `/etc/ckan/custom/templates/user`

## `index.html`

- **Path:** `/etc/ckan/custom/templates/user`
- **Função:** template de página de usuários. Ajusta a visualização da área de usuários do CKAN, normalmente usada para adaptar textos, layout ou comportamento administrativo relacionado a contas.

## `list.html`

- **Path:** `/etc/ckan/custom/templates/user`
- **Função:** template de listagem de usuários. Controla como usuários são exibidos em listas administrativas ou páginas relacionadas a contas.

---

# `/etc/ckan/public/images`

## `logo.png`

- **Path:** `/etc/ckan/public/images`
- **Função:** logotipo institucional usado pela interface customizada do CKAN SFB, especialmente no cabeçalho, tema ou páginas que carregam imagens públicas do portal.

---

# `/etc/ckan/schemas`

## `sfb_dataset.yaml`

- **Path:** `/etc/ckan/schemas`
- **Função:** schema principal de metadados do CKAN SFB. Define os campos e opções do formulário de criação e edição de registros e recursos, incluindo rótulos, presets, tipos de campo, vocabulários controlados, validações, obrigatoriedade e organização dos metadados do perfil SFB.

---

# `/etc/nginx/sites-available`

## `ckan`

- **Path:** `/etc/nginx/sites-available`
- **Função:** configuração do Nginx para o CKAN SFB. Define o domínio atendido, proxy reverso para o CKAN local, headers encaminhados, limite de upload e comportamento HTTP/HTTPS quando usado junto ao Certbot.

---

# `/etc/systemd/system/ckan.service.d`

## `20-wait-solr.conf`

- **Path:** `/etc/systemd/system/ckan.service.d`
- **Função:** drop-in systemd que faz o serviço CKAN aguardar o Solr antes de iniciar. Evita que o CKAN suba antes do core de busca estar disponível.

## `99-bind-local.conf`

- **Path:** `/etc/systemd/system/ckan.service.d`
- **Função:** drop-in systemd que força o CKAN a escutar em endereço local, normalmente `127.0.0.1:5000`, impedindo exposição direta do serviço CKAN na internet e deixando o acesso público a cargo do Nginx.

## `solr.conf`

- **Path:** `/etc/systemd/system/ckan.service.d`
- **Função:** drop-in systemd de integração entre CKAN e Solr. Define dependência ou ordenação de inicialização para reforçar que o CKAN deve subir associado ao serviço de busca.

---

# `/etc/systemd/system`

## `solr.service`

- **Path:** `/etc/systemd/system`
- **Função:** unidade systemd customizada do Solr. Controla a forma como o Solr é iniciado no servidor, incluindo execução como serviço, parâmetros de inicialização e integração operacional com o ambiente CKAN SFB.

---

# `/opt/ckan/extra_translations/i18n/pt_BR/LC_MESSAGES`

## `ckan.po`

- **Path:** `/opt/ckan/extra_translations/i18n/pt_BR/LC_MESSAGES`
- **Função:** arquivo de tradução extra em português para textos do domínio principal do CKAN. Permite ajustar termos da interface sem alterar diretamente todos os templates.

## `sfb_ui.po`

- **Path:** `/opt/ckan/extra_translations/i18n/pt_BR/LC_MESSAGES`
- **Função:** arquivo de tradução extra específico da interface SFB. Contém traduções e substituições de termos próprios da customização, como nomenclaturas institucionais e rótulos específicos do projeto.

---

# `/opt/ckan/extra_translations/pt_BR/LC_MESSAGES`

## `sfb_ui.po`

- **Path:** `/opt/ckan/extra_translations/pt_BR/LC_MESSAGES`
- **Função:** arquivo de tradução extra do domínio `sfb_ui` em português. Serve para customizar textos específicos da interface SFB carregados pelo sistema de internacionalização configurado no CKAN.

---

# `/usr/lib/ckan/ckan/ckan/i18n/pt_BR/LC_MESSAGES`

## `ckan.mo`

- **Path:** `/usr/lib/ckan/ckan/ckan/i18n/pt_BR/LC_MESSAGES`
- **Função:** arquivo binário compilado de tradução do CKAN em português. É usado em tempo de execução para exibir traduções da interface.

## `ckan.po`

- **Path:** `/usr/lib/ckan/ckan/ckan/i18n/pt_BR/LC_MESSAGES`
- **Função:** arquivo fonte de tradução do CKAN em português. Contém os textos originais e traduzidos usados para gerar o arquivo compilado `ckan.mo`.

---

# `/usr/lib/ckan/ckan/ckan/public/base/images`

## `ckan-logo.png`

- **Path:** `/usr/lib/ckan/ckan/ckan/public/base/images`
- **Função:** imagem de logotipo no caminho padrão do CKAN core. No rootfs SFB, esse arquivo substitui ou adapta o logotipo exibido por partes da interface que ainda apontam para o asset padrão do CKAN.

---

# `/usr/lib/ckan/ckan/ckan/templates/home/snippets`

## `promoted.html`

- **Path:** `/usr/lib/ckan/ckan/ckan/templates/home/snippets`
- **Função:** snippet nativo da home do CKAN responsável pelo bloco promovido/destaque. Na customização SFB, controla ou neutraliza esse bloco para ajustar a página inicial ao layout institucional.

---

# `/usr/lib/ckan/ckan/ckan/templates/package/snippets`

## `package_basic_fields.html`

- **Path:** `/usr/lib/ckan/ckan/ckan/templates/package/snippets`
- **Função:** template nativo dos campos básicos do formulário de dataset. Na customização SFB, ajusta a forma como campos básicos como título, nome, descrição, organização, visibilidade ou licença aparecem durante criação e edição de registros.

---

# `/usr/lib/ckan/venv/src/ckanext-scheming/ckanext/scheming`

## `scheming_presets_custom.json`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-scheming/ckanext/scheming`
- **Função:** arquivo de presets customizados do `ckanext-scheming`. Define componentes reutilizáveis de formulário, validação ou exibição usados pelo schema SFB para campos que não são cobertos apenas pelos presets padrão.

---

# `/usr/lib/ckan/venv/src/ckanext-sfb_access`

## `setup.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_access`
- **Função:** arquivo de instalação da extensão `ckanext-sfb_access`. Registra o pacote Python e o plugin para que o CKAN consiga instalar e carregar a extensão no ambiente virtual.

---

# `/usr/lib/ckan/venv/src/ckanext-sfb_access/ckanext`

## `__init__.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_access/ckanext`
- **Função:** arquivo de inicialização do namespace Python `ckanext`. Permite que a extensão seja reconhecida como parte do ecossistema de extensões CKAN.

---

# `/usr/lib/ckan/venv/src/ckanext-sfb_access/ckanext/sfb_access`

## `__init__.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_access/ckanext/sfb_access`
- **Função:** arquivo de inicialização do pacote `sfb_access`. Permite importar o módulo da extensão dentro do CKAN.

## `managed_access_phase1.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_access/ckanext/sfb_access`
- **Função:** módulo auxiliar da extensão de acesso. Registra ou organiza a primeira fase da lógica de acesso gerenciado, servindo como apoio à implementação das regras de visibilidade do projeto.

## `plugin.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_access/ckanext/sfb_access`
- **Função:** plugin principal da extensão de acesso SFB. Implementa regras de visibilidade e leitura dos registros com base no campo de acesso do projeto, tratando comportamentos como público, interno e privado, além de integrar permissões, badges e consulta de datasets/recursos.

---

# `/usr/lib/ckan/venv/src/ckanext-sfb_facets_multi`

## `pyproject.toml`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_facets_multi`
- **Função:** arquivo de metadados/build Python da extensão `ckanext-sfb_facets_multi`. Auxilia ferramentas modernas de empacotamento na identificação e instalação do pacote.

## `setup.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_facets_multi`
- **Função:** arquivo de instalação da extensão `ckanext-sfb_facets_multi`. Registra o pacote e o plugin para que o CKAN consiga carregar a extensão de filtros customizados.

---

# `/usr/lib/ckan/venv/src/ckanext-sfb_facets_multi/ckanext`

## `__init__.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_facets_multi/ckanext`
- **Função:** arquivo de inicialização do namespace Python `ckanext` usado pela extensão de facets múltiplas.

---

# `/usr/lib/ckan/venv/src/ckanext-sfb_facets_multi/ckanext/sfb_facets_multi`

## `__init__.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_facets_multi/ckanext/sfb_facets_multi`
- **Função:** arquivo de inicialização do pacote `sfb_facets_multi`. Permite importar os componentes da extensão no CKAN.

## `plugin.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_facets_multi/ckanext/sfb_facets_multi`
- **Função:** plugin principal dos filtros customizados SFB. Define quais campos extras viram facets, como valores múltiplos são indexados, quais rótulos aparecem na busca e a ordem de exibição dos filtros laterais.

---

# `/usr/lib/ckan/venv/src/ckanext-sfb_geo_facet`

## `setup.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_geo_facet`
- **Função:** arquivo de instalação da extensão `ckanext-sfb_geo_facet`. Registra o pacote e o plugin responsável pelo filtro geográfico.

---

# `/usr/lib/ckan/venv/src/ckanext-sfb_geo_facet/ckanext`

## `__init__.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_geo_facet/ckanext`
- **Função:** arquivo de inicialização do namespace Python `ckanext` usado pela extensão de facet geográfica.

---

# `/usr/lib/ckan/venv/src/ckanext-sfb_geo_facet/ckanext/sfb_geo_facet`

## `__init__.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_geo_facet/ckanext/sfb_geo_facet`
- **Função:** arquivo de inicialização do pacote `sfb_geo_facet`. Permite que o CKAN importe a extensão.

## `plugin.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_geo_facet/ckanext/sfb_geo_facet`
- **Função:** plugin principal do filtro geográfico SFB. Ajusta a indexação ou exibição de campos relacionados à referência geográfica para permitir filtragem na busca de registros.

---

# `/usr/lib/ckan/venv/src/ckanext-sfb_group_sync`

## `setup.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_group_sync`
- **Função:** arquivo de instalação da extensão `ckanext-sfb_group_sync`. Registra o pacote e o plugin de sincronização entre campos de registro e grupos/projetos do CKAN.

---

# `/usr/lib/ckan/venv/src/ckanext-sfb_group_sync/ckanext`

## `__init__.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_group_sync/ckanext`
- **Função:** arquivo de inicialização do namespace Python `ckanext` usado pela extensão de sincronização de grupos.

---

# `/usr/lib/ckan/venv/src/ckanext-sfb_group_sync/ckanext/sfb_group_sync`

## `__init__.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_group_sync/ckanext/sfb_group_sync`
- **Função:** arquivo de inicialização do pacote `sfb_group_sync`. Permite importar o módulo da extensão.

## `plugin.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfb_group_sync/ckanext/sfb_group_sync`
- **Função:** plugin principal de sincronização grupo/projeto. Mantém coerência entre o campo de projeto/grupo informado no registro e a associação do dataset aos grupos internos do CKAN.

---

# `/usr/lib/ckan/venv/src/ckanext-sfbdraftsearch`

## `setup.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfbdraftsearch`
- **Função:** arquivo de instalação da extensão `ckanext-sfbdraftsearch`. Registra o pacote e o plugin relacionado à busca ou listagem de registros em rascunho.

---

# `/usr/lib/ckan/venv/src/ckanext-sfbdraftsearch/ckanext`

## `__init__.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfbdraftsearch/ckanext`
- **Função:** arquivo de inicialização do namespace Python `ckanext` usado pela extensão de busca de rascunhos.

---

# `/usr/lib/ckan/venv/src/ckanext-sfbdraftsearch/ckanext/sfbdraftsearch`

## `__init__.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfbdraftsearch/ckanext/sfbdraftsearch`
- **Função:** arquivo de inicialização do pacote `sfbdraftsearch`. Permite importar os módulos da extensão no CKAN.

## `plugin.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfbdraftsearch/ckanext/sfbdraftsearch`
- **Função:** plugin principal da extensão de rascunhos. Ajusta comportamento de busca/listagem para permitir tratamento específico de registros em elaboração, rascunho ou não publicados conforme a lógica do projeto SFB.

---

# `/usr/lib/ckan/venv/src/ckanext-sfbgroups`

## `setup.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfbgroups`
- **Função:** arquivo de instalação da extensão `ckanext-sfbgroups`. Registra o pacote e o plugin auxiliar de grupos/projetos.

---

# `/usr/lib/ckan/venv/src/ckanext-sfbgroups/ckanext`

## `__init__.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfbgroups/ckanext`
- **Função:** arquivo de inicialização do namespace Python `ckanext` usado pela extensão `sfbgroups`.

---

# `/usr/lib/ckan/venv/src/ckanext-sfbgroups/ckanext/sfbgroups`

## `__init__.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfbgroups/ckanext/sfbgroups`
- **Função:** arquivo de inicialização do pacote `sfbgroups`. Permite importar a extensão no CKAN.

## `plugin.py`

- **Path:** `/usr/lib/ckan/venv/src/ckanext-sfbgroups/ckanext/sfbgroups`
- **Função:** plugin principal auxiliar de grupos/projetos. Fornece lógica e helpers para listar grupos existentes como opções de projeto no formulário, permitindo associar registros a projetos de forma mais amigável na interface.
