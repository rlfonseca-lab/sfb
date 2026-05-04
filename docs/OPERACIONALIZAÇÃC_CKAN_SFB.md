# Manual de Operacionalização do CKAN SFB

**Interface web, consulta, cadastro, curadoria e administração visual**

> **Documento operacional**
> Este manual foi preparado para orientar o uso do CKAN SFB pela interface gráfica via navegador. Ele não trata de instalação, Docker, API, banco de dados, plugins, YAML ou customização técnica.

# Sumário

- 1. Apresentação e escopo
- 2. Conceitos básicos do CKAN SFB
- 3. Entrar, sair e recuperar acesso
- 4. Conhecer a página inicial
- 5. Jornada 1: Consultar registros
- 6. Visualizar registros e recursos
- 7. Jornada 2: Cadastrar registros e recursos
- 8. Jornada 3: Editar registros e recursos
- 9. Jornada 4: Revisar e publicar com segurança
- 10. Jornada 5: Administrar pela interface web
- 11. Problemas comuns e orientações rápidas
- 12. Boas práticas de preenchimento
- 13. Checklists operacionais
- 14. Glossário operacional
- 15. Lista consolidada de figuras a capturar
- 16. Referências consultadas

# 1. Apresentação e escopo

Este manual orienta a operação do CKAN SFB pela interface gráfica via web. O objetivo é permitir que usuários consultem, cadastrem, editem, revisem e administrem conteúdos do portal sem precisar conhecer a infraestrutura técnica do sistema.

No CKAN SFB, o usuário trabalha principalmente com registros, arquivos ou recursos, unidades, projetos, metadados, status e níveis de acesso. A customização feita no projeto adapta termos, telas, formulários, filtros e elementos visuais para a realidade institucional do SFB.

> **Fora do escopo**
> Este documento não ensina instalação, configuração de servidor, Docker, Nginx, Certbot, banco de dados, Solr, API, alterações em código, templates, plugins ou arquivos YAML. Quando uma ação depender desses temas, o manual indicará que a demanda deve ser encaminhada à equipe técnica.


## 1.1 Quem deve usar este manual

| **Perfil**                 | **Uso principal do manual**                                                                               |
|----------------------------|-----------------------------------------------------------------------------------------------------------|
| Usuário consultor          | Buscar registros, aplicar filtros, abrir páginas de registro e baixar arquivos.                           |
| Usuário cadastrador/editor | Criar registros, preencher metadados, anexar arquivos ou links e corrigir informações.                    |
| Curadoria                  | Revisar qualidade, completude, acesso, status, unidade, projeto e coerência geral dos registros.          |
| Administrador visual       | Gerenciar usuários, senhas, unidades, projetos, membros, papéis e registros excluídos pela interface web. |

## 1.2 Como este manual está organizado

O manual é dividido em cinco jornadas: consultar, cadastrar, editar, revisar e administrar. Cada procedimento importante segue um padrão simples: quando usar, quem pode fazer, passo a passo, resultado esperado e cuidados.

# 2. Conceitos básicos do CKAN SFB

Antes de operar o portal, é importante alinhar alguns termos. Eles aparecem em menus, formulários, filtros e páginas de leitura.

| **Termo**          | **Descrição operacional**                                                                                                                                                                                                                                              |
|--------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Registro           | Ficha principal cadastrada no portal. No CKAN original, corresponde ao dataset ou conjunto de dados. No CKAN SFB, a interface usa a noção de registro para representar documentos, produtos técnicos, bases, links e materiais institucionais descritos por metadados. |
| Arquivo ou recurso | Item associado a um registro. Pode ser um arquivo enviado ao CKAN ou um link externo. Um registro pode ter um ou vários recursos.                                                                                                                                      |
| Unidade            | Entidade institucional responsável pelo registro. No CKAN original, a estrutura equivalente é organização. No CKAN SFB, a interface foi adaptada para tratar organizações como unidades responsáveis ou institucionais.                                                |
| Projeto            | Agrupamento usado para organizar registros por programa, ação, linha de trabalho ou tema institucional. No CKAN original, a estrutura equivalente é grupo. No CKAN SFB, grupos são apresentados como projetos.                                                         |
| Metadados          | Informações que descrevem e classificam o registro, como título, descrição, unidade, projeto, status, CCD, tema, escopo, abrangência, fonte, licença e acesso.                                                                                                         |
| Status             | Indica a situação operacional do registro, como em elaboração, em revisão, em análise, finalizado ou publicado, conforme as opções consolidadas na interface.                                                                                                          |
| Nível de acesso    | Define quem pode ver o registro. As opções principais do projeto são Público, Interno e Privado.                                                                                                                                                                       |

> **Regra simples de leitura**
> Unidade responde institucionalmente pelo registro. Projeto organiza o registro por linha de trabalho. Acesso define quem pode ver. Status indica em que etapa operacional o registro está.


> **[FIGURA 01] Visão geral dos elementos principais da interface**
> Inserir print da página inicial com destaque para menu superior, busca, área do usuário e atalhos principais.
> **Arquivo sugerido:** `imagens/figura-01-visao-geral-dos-elementos-principais-da-interface.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 01 - Visão geral dos elementos principais da interface](imagens/figura-01-visao-geral-dos-elementos-principais-da-interface.png)`


# 3. Entrar, sair e recuperar acesso

### 3.1 Fazer login

**Quando usar:** Quando o usuário precisar cadastrar, editar, revisar ou acessar conteúdo interno.

**Quem pode fazer:** Qualquer usuário com conta ativa no CKAN SFB.

**Passo a passo:**

1.  Acesse o endereço do CKAN SFB no navegador.

2.  Clique na opção de login ou entrada, normalmente localizada no canto superior direito.

3.  Informe seu nome de usuário e senha.

4.  Confirme o acesso.

5.  Verifique se o seu nome ou menu de usuário aparece no topo da página.

**Resultado esperado:** O usuário passa a visualizar as opções compatíveis com seu perfil, como gerenciar registros, acessar área pessoal ou opções administrativas.

**Cuidados:** Nunca compartilhe senha. Em computador compartilhado, sempre saia do sistema ao terminar.

> **[FIGURA 02] Tela de login**
> Inserir print da tela de login do CKAN SFB, sem exibir senha preenchida.
> **Arquivo sugerido:** `imagens/figura-02-tela-de-login.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 02 - Tela de login](imagens/figura-02-tela-de-login.png)`


> **[FIGURA 03] Usuário logado no menu superior**
> Inserir print do topo da página após login, destacando o menu de usuário.
> **Arquivo sugerido:** `imagens/figura-03-usuario-logado-no-menu-superior.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 03 - Usuário logado no menu superior](imagens/figura-03-usuario-logado-no-menu-superior.png)`


### 3.2 Sair do sistema

**Quando usar:** Ao terminar o uso, especialmente em computador compartilhado ou equipamento de terceiros.

**Quem pode fazer:** Qualquer usuário logado.

**Passo a passo:**

6.  Clique no menu do usuário no canto superior direito.

7.  Selecione a opção de sair, logout ou equivalente.

8.  Confirme que o menu deixou de mostrar seu nome de usuário.

**Resultado esperado:** A sessão é encerrada e o navegador volta ao estado de usuário não logado.

**Cuidados:** Fechar a aba nem sempre encerra a sessão. Use sempre a opção de sair.

### 3.3 Recuperar senha pelo próprio usuário

**Quando usar:** Quando o usuário esqueceu a senha e a recuperação por e-mail está habilitada no portal.

**Quem pode fazer:** Usuário com e-mail válido cadastrado.

**Passo a passo:**

9.  Na tela de login, clique em “Esqueci minha senha”, “Redefinir senha” ou opção equivalente.

10. Informe o usuário ou e-mail cadastrado, conforme solicitado.

11. Aguarde a mensagem de redefinição no e-mail institucional.

12. Siga o link recebido e defina uma nova senha.

13. Entre novamente no CKAN SFB com a nova senha.

**Resultado esperado:** O usuário recupera o acesso sem intervenção manual do administrador.

**Cuidados:** Se o e-mail não chegar, verifique spam/lixo eletrônico e confirme se o e-mail cadastrado está correto.

> **[FIGURA 04] Tela de recuperação de senha**
> Inserir print da tela de redefinição de senha ou link equivalente da interface.
> **Arquivo sugerido:** `imagens/figura-04-tela-de-recuperacao-de-senha.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 04 - Tela de recuperação de senha](imagens/figura-04-tela-de-recuperacao-de-senha.png)`


### 3.4 Recuperar senha com apoio do administrador

**Quando usar:** Quando a recuperação automática não estiver habilitada, não funcionar ou o usuário não tiver acesso ao e-mail cadastrado.

**Quem pode fazer:** Administrador visual com permissão para gerenciar usuários.

**Passo a passo:**

14. O usuário solicita apoio informando nome completo, nome de usuário e e-mail institucional.

15. O administrador localiza o usuário pela área de usuários.

16. O administrador abre a página do usuário e entra em “Gerenciar”.

17. O administrador define uma senha temporária ou atualiza a senha, conforme a interface permitir.

18. O usuário entra no sistema e troca a senha, se a interface permitir ou se a política interna exigir.

**Resultado esperado:** O acesso é restabelecido e o usuário volta a operar o portal.

**Cuidados:** A senha temporária deve ser comunicada por canal seguro. Evite enviar senha por grupos ou mensagens abertas.

# 4. Conhecer a página inicial

A página inicial do CKAN SFB é a porta de entrada do portal. Ela foi customizada para apresentar a identidade visual do projeto, a busca principal e caminhos de navegação para registros, unidades e projetos.

> **[FIGURA 05] Página inicial completa**
> Inserir print da página inicial do CKAN SFB em resolução ampla, mostrando cabeçalho, bloco principal e busca.
> **Arquivo sugerido:** `imagens/figura-05-pagina-inicial-completa.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 05 - Página inicial completa](imagens/figura-05-pagina-inicial-completa.png)`


### 4.1 Usar a busca da página inicial

**Quando usar:** Quando o usuário já sabe uma palavra, sigla, tema, título parcial ou termo relacionado ao registro que procura.

**Quem pode fazer:** Qualquer usuário, inclusive visitante anônimo para conteúdo público.

**Passo a passo:**

19. Digite uma ou mais palavras no campo de busca da página inicial.

20. Clique no botão de buscar ou pressione Enter.

21. Aguarde a página de resultados.

22. Use os filtros laterais para refinar a busca.

**Resultado esperado:** O CKAN mostra registros compatíveis com o termo pesquisado, respeitando as permissões de acesso do usuário.

**Cuidados:** Usuários não logados só verão registros públicos. Para consultar registros internos, faça login.

> **[FIGURA 06] Busca principal da home**
> Inserir print do campo de busca da página inicial com um termo de exemplo digitado.
> **Arquivo sugerido:** `imagens/figura-06-busca-principal-da-home.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 06 - Busca principal da home](imagens/figura-06-busca-principal-da-home.png)`


### 4.2 Navegar pelo menu superior

**Quando usar:** Quando o usuário deseja acessar diretamente áreas do portal em vez de usar busca livre.

**Quem pode fazer:** Qualquer usuário, respeitadas as permissões de cada área.

**Passo a passo:**

23. Use “Registros” para consultar o catálogo principal.

24. Use “Unidades” para localizar registros por unidade institucional responsável.

25. Use “Projetos” para localizar registros agrupados por projeto.

26. Use o menu do usuário para acessar perfil, painel pessoal ou opções administrativas quando disponíveis.

**Resultado esperado:** O usuário chega à área desejada sem precisar memorizar endereços internos.

**Cuidados:** A nomenclatura pode variar conforme tradução e customização final. Use sempre os rótulos visíveis na interface homologada.

# 5. Jornada 1: Consultar registros

A consulta é a jornada de quem precisa encontrar, interpretar e baixar informações no portal. Ela pode ser feita por busca livre, filtros, unidade ou projeto.

### 5.1 Fazer uma busca simples

**Quando usar:** Quando o usuário procura um registro por título, assunto, sigla, tema, descrição ou palavra relacionada.

**Quem pode fazer:** Qualquer usuário.

**Passo a passo:**

27. Acesse a área de Registros ou use a busca da página inicial.

28. Digite o termo desejado.

29. Clique em buscar.

30. Leia os cards de resultado.

31. Clique no título do registro mais adequado.

**Resultado esperado:** A página de resultados mostra registros compatíveis com a busca.

**Cuidados:** Use termos mais curtos quando a busca não retornar resultados. Teste siglas e nomes por extenso.

> **[FIGURA 07] Página de resultados de busca**
> Inserir print da listagem de registros após uma busca simples, com cards e filtros laterais visíveis.
> **Arquivo sugerido:** `imagens/figura-07-pagina-de-resultados-de-busca.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 07 - Página de resultados de busca](imagens/figura-07-pagina-de-resultados-de-busca.png)`


### 5.2 Usar filtros laterais

**Quando usar:** Quando a busca retorna muitos resultados ou quando o usuário quer restringir por unidade, projeto, tema, CCD ou outro campo.

**Quem pode fazer:** Qualquer usuário.

**Passo a passo:**

32. Faça uma busca ou abra a página de Registros.

33. Observe a coluna lateral de filtros.

34. Clique no filtro desejado, como Unidade, Projeto, Tema ou CCD.

35. Confira se a lista de resultados foi reduzida.

36. Combine mais de um filtro se necessário.

37. Remova filtros ativos quando quiser ampliar a busca novamente.

**Resultado esperado:** A lista passa a mostrar apenas registros compatíveis com os filtros escolhidos.

**Cuidados:** Filtros combinados demais podem esconder resultados úteis. Se a lista ficar vazia, remova um filtro por vez.

> **[FIGURA 08] Filtros laterais de busca**
> Inserir print da coluna de filtros/facets, mostrando Unidade, Projeto, Tema, CCD e demais filtros relevantes.
> **Arquivo sugerido:** `imagens/figura-08-filtros-laterais-de-busca.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 08 - Filtros laterais de busca](imagens/figura-08-filtros-laterais-de-busca.png)`


> **[FIGURA 09] Filtro aplicado**
> Inserir print de uma busca com pelo menos um filtro ativo, mostrando o filtro selecionado e a lista reduzida.
> **Arquivo sugerido:** `imagens/figura-09-filtro-aplicado.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 09 - Filtro aplicado](imagens/figura-09-filtro-aplicado.png)`


### 5.3 Interpretar os cards de resultado

**Quando usar:** Quando o usuário precisa decidir qual registro abrir a partir da lista de resultados.

**Quem pode fazer:** Qualquer usuário.

**Passo a passo:**

38. Leia o título do card.

39. Confira a descrição resumida.

40. Observe Unidade, Projeto, Status, Acesso e Licença, quando exibidos.

41. Confira os formatos dos recursos, quando aparecerem no card.

42. Clique no título para abrir o registro completo.

**Resultado esperado:** O usuário identifica o registro correto antes de abrir ou baixar arquivos.

**Cuidados:** Cards são resumos. Para decisão final, abra a página completa do registro.

> **[FIGURA 10] Card de registro na listagem**
> Inserir print aproximado de um card de resultado mostrando título, descrição e metadados resumidos.
> **Arquivo sugerido:** `imagens/figura-10-card-de-registro-na-listagem.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 10 - Card de registro na listagem](imagens/figura-10-card-de-registro-na-listagem.png)`


### 5.4 Consultar registros por Unidade

**Quando usar:** Quando o usuário quer ver registros associados a uma unidade institucional específica.

**Quem pode fazer:** Qualquer usuário, conforme acesso ao conteúdo.

**Passo a passo:**

43. Clique em “Unidades” no menu superior.

44. Localize a unidade desejada.

45. Abra a página da unidade.

46. Use a busca dentro da unidade ou consulte os registros listados.

**Resultado esperado:** A página apresenta registros vinculados à unidade selecionada.

**Cuidados:** Se um registro esperado não aparecer, verifique nível de acesso, projeto, unidade escolhida e termos de busca.

> **[FIGURA 11] Página de listagem de Unidades**
> Inserir print da tela que lista as unidades institucionais.
> **Arquivo sugerido:** `imagens/figura-11-pagina-de-listagem-de-unidades.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 11 - Página de listagem de Unidades](imagens/figura-11-pagina-de-listagem-de-unidades.png)`


> **[FIGURA 12] Página de uma Unidade**
> Inserir print da página de uma unidade com registros associados.
> **Arquivo sugerido:** `imagens/figura-12-pagina-de-uma-unidade.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 12 - Página de uma Unidade](imagens/figura-12-pagina-de-uma-unidade.png)`


### 5.5 Consultar registros por Projeto

**Quando usar:** Quando o usuário quer ver registros agrupados por projeto, programa, ação ou linha de trabalho.

**Quem pode fazer:** Qualquer usuário, conforme acesso ao conteúdo.

**Passo a passo:**

47. Clique em “Projetos” no menu superior.

48. Localize o projeto desejado.

49. Abra a página do projeto.

50. Consulte os registros vinculados ou use a busca interna.

**Resultado esperado:** A página apresenta registros vinculados ao projeto selecionado.

**Cuidados:** Projeto organiza conteúdo, mas não substitui Unidade nem nível de acesso.

> **[FIGURA 13] Página de listagem de Projetos**
> Inserir print da tela que lista os projetos.
> **Arquivo sugerido:** `imagens/figura-13-pagina-de-listagem-de-projetos.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 13 - Página de listagem de Projetos](imagens/figura-13-pagina-de-listagem-de-projetos.png)`


> **[FIGURA 14] Página de um Projeto**
> Inserir print da página de um projeto com registros associados.
> **Arquivo sugerido:** `imagens/figura-14-pagina-de-um-projeto.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 14 - Página de um Projeto](imagens/figura-14-pagina-de-um-projeto.png)`


# 6. Visualizar registros e recursos

### 6.1 Abrir e interpretar um registro

**Quando usar:** Quando o usuário encontrou um registro e precisa verificar seus metadados e arquivos associados.

**Quem pode fazer:** Qualquer usuário com permissão de leitura do registro.

**Passo a passo:**

51. Clique no título do registro na listagem ou em um link direto.

52. Leia o título e a descrição.

53. Confira Unidade, Projeto, Status, Acesso e Licença.

54. Consulte os demais metadados exibidos na seção de informações adicionais.

55. Role a página até a área de arquivos ou recursos.

**Resultado esperado:** O usuário entende o conteúdo, contexto e condição de uso do registro.

**Cuidados:** Não baixe nem compartilhe arquivos antes de conferir o nível de acesso e a licença.

> **[FIGURA 15] Página completa de um Registro**
> Inserir print da página de leitura de um registro, com título, metadados principais e lista de recursos.
> **Arquivo sugerido:** `imagens/figura-15-pagina-completa-de-um-registro.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 15 - Página completa de um Registro](imagens/figura-15-pagina-completa-de-um-registro.png)`


> **[FIGURA 16] Metadados adicionais do Registro**
> Inserir print da área de informações adicionais do registro, mostrando campos SFB.
> **Arquivo sugerido:** `imagens/figura-16-metadados-adicionais-do-registro.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 16 - Metadados adicionais do Registro](imagens/figura-16-metadados-adicionais-do-registro.png)`


### 6.2 Abrir um recurso

**Quando usar:** Quando o usuário precisa ver detalhes de um arquivo ou link associado ao registro.

**Quem pode fazer:** Qualquer usuário com permissão de leitura do recurso.

**Passo a passo:**

56. Na página do registro, localize a lista de recursos.

57. Clique no nome do recurso desejado.

58. Leia nome, descrição, formato e demais metadados.

59. Use o botão de download ou abertura do link, conforme o caso.

**Resultado esperado:** O recurso é exibido em página própria ou aberto para download/acesso externo.

**Cuidados:** Alguns arquivos podem não ter pré-visualização no navegador. Nesse caso, baixe o arquivo e abra no programa adequado.

> **[FIGURA 17] Lista de recursos de um Registro**
> Inserir print da área onde aparecem arquivos e links vinculados a um registro.
> **Arquivo sugerido:** `imagens/figura-17-lista-de-recursos-de-um-registro.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 17 - Lista de recursos de um Registro](imagens/figura-17-lista-de-recursos-de-um-registro.png)`


> **[FIGURA 18] Página de leitura de um Recurso**
> Inserir print da página do recurso, mostrando metadados do arquivo/link e botão de download.
> **Arquivo sugerido:** `imagens/figura-18-pagina-de-leitura-de-um-recurso.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 18 - Página de leitura de um Recurso](imagens/figura-18-pagina-de-leitura-de-um-recurso.png)`


### 6.3 Baixar arquivo

**Quando usar:** Quando o usuário precisa usar o arquivo fora do navegador.

**Quem pode fazer:** Qualquer usuário com permissão de acesso ao recurso.

**Passo a passo:**

60. Abra o registro ou a página do recurso.

61. Clique no botão de download ou opção equivalente.

62. Aguarde a conclusão do download.

63. Abra o arquivo no programa adequado ao formato.

64. Se o arquivo não abrir, confira se o download terminou corretamente.

**Resultado esperado:** O arquivo fica disponível localmente para uso autorizado.

**Cuidados:** Não redistribua arquivo interno ou privado fora das regras institucionais.

# 7. Jornada 2: Cadastrar registros e recursos

Cadastrar é criar uma ficha de registro com metadados e, quando necessário, anexar arquivos ou links. A qualidade do cadastro determina se o material será encontrado e compreendido depois.

### 7.1 Checklist antes de cadastrar

| **Item**                                                                                        | **Conferido?** | **Observações** |
|-------------------------------------------------------------------------------------------------|----------------|-----------------|
| Verifiquei se o registro ainda não existe no CKAN SFB.                                          | ☐ Sim ☐ Não    |                 |
| Sei qual é a Unidade responsável pelo material.                                                 | ☐ Sim ☐ Não    |                 |
| Sei qual Projeto deve ser associado, se houver.                                                 | ☐ Sim ☐ Não    |                 |
| Tenho título e descrição minimamente claros.                                                    | ☐ Sim ☐ Não    |                 |
| Identifiquei o CCD ou classe aplicável.                                                         | ☐ Sim ☐ Não    |                 |
| Defini o nível de acesso: Público, Interno ou Privado.                                          | ☐ Sim ☐ Não    |                 |
| Identifiquei status inicial adequado.                                                           | ☐ Sim ☐ Não    |                 |
| Tenho arquivo ou link pronto para anexar, se aplicável.                                         | ☐ Sim ☐ Não    |                 |
| Conferi se o material não contém informação sensível indevida para o nível de acesso escolhido. | ☐ Sim ☐ Não    |                 |

### 7.2 Criar um novo registro

**Quando usar:** Quando um material precisa entrar no catálogo do CKAN SFB.

**Quem pode fazer:** Usuário com permissão para criar registros na Unidade correspondente.

**Passo a passo:**

65. Faça login no CKAN SFB.

66. Acesse a área de Registros.

67. Clique em “Adicionar Registro”, “Novo Registro” ou opção equivalente.

68. Escolha a Unidade responsável, quando solicitado.

69. Preencha os campos do formulário.

70. Revise campos obrigatórios destacados pela interface.

71. Salve ou avance para a etapa de adicionar recurso, conforme o fluxo apresentado.

**Resultado esperado:** O registro é criado e passa a existir no portal, respeitando o nível de acesso definido.

**Cuidados:** Se o botão de criação não aparecer, o usuário provavelmente não tem permissão na Unidade. Solicite ajuste ao administrador visual.

> **[FIGURA 19] Botão de criação de Registro**
> Inserir print da página de Registros ou Unidade mostrando o botão para adicionar novo registro.
> **Arquivo sugerido:** `imagens/figura-19-botao-de-criacao-de-registro.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 19 - Botão de criação de Registro](imagens/figura-19-botao-de-criacao-de-registro.png)`


> **[FIGURA 20] Formulário de criação de Registro**
> Inserir print do início do formulário de registro com campos principais.
> **Arquivo sugerido:** `imagens/figura-20-formulario-de-criacao-de-registro.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 20 - Formulário de criação de Registro](imagens/figura-20-formulario-de-criacao-de-registro.png)`


### 7.3 Preencher campos principais

**Quando usar:** Durante criação ou edição de registro.

**Quem pode fazer:** Usuário cadastrador/editor.

**Passo a passo:**

72. Preencha o título com nome claro, específico e sem abreviações desnecessárias.

73. Preencha a descrição explicando o que é o material, sua finalidade, escopo e contexto.

74. Selecione Unidade responsável e Projeto, quando aplicável.

75. Selecione CCD, tema, escopo, abrangência, fonte e sistema relacionado conforme as listas disponíveis.

76. Defina status do registro.

77. Defina nível de acesso.

78. Selecione licença quando aplicável.

79. Revise o formulário antes de salvar.

**Resultado esperado:** O registro fica descrito de forma suficiente para busca, leitura e revisão.

**Cuidados:** Evite preencher campos controlados com valores improvisados. Se uma opção estiver faltando, encaminhe demanda à curadoria/gestão.

> **[FIGURA 21] Campos institucionais do Registro**
> Inserir print do bloco do formulário com Unidade, Projeto, CCD e campos de classificação.
> **Arquivo sugerido:** `imagens/figura-21-campos-institucionais-do-registro.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 21 - Campos institucionais do Registro](imagens/figura-21-campos-institucionais-do-registro.png)`


> **[FIGURA 22] Campo de Status e Acesso**
> Inserir print do bloco do formulário onde aparecem Status e Nível de acesso.
> **Arquivo sugerido:** `imagens/figura-22-campo-de-status-e-acesso.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 22 - Campo de Status e Acesso](imagens/figura-22-campo-de-status-e-acesso.png)`


### 7.4 Adicionar arquivo ao registro

**Quando usar:** Quando o material principal está em arquivo local, como PDF, planilha, documento ou outro formato autorizado.

**Quem pode fazer:** Usuário com permissão de edição no registro.

**Passo a passo:**

80. Na etapa de recursos, escolha a opção de enviar arquivo.

81. Clique em escolher arquivo ou botão equivalente.

82. Selecione o arquivo no computador.

83. Preencha nome do recurso com identificação clara.

84. Preencha descrição do recurso.

85. Informe formato quando a interface não identificar automaticamente.

86. Salve o recurso.

**Resultado esperado:** O arquivo fica associado ao registro e aparece na lista de recursos.

**Cuidados:** Aguarde o fim do envio antes de sair da página. Arquivos grandes podem demorar.

> **[FIGURA 23] Tela de envio de arquivo/Recurso**
> Inserir print do formulário de recurso no modo de upload de arquivo.
> **Arquivo sugerido:** `imagens/figura-23-tela-de-envio-de-arquivo-recurso.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 23 - Tela de envio de arquivo/Recurso](imagens/figura-23-tela-de-envio-de-arquivo-recurso.png)`


### 7.5 Adicionar link externo ao registro

**Quando usar:** Quando o conteúdo está hospedado em outro sistema, página ou repositório autorizado.

**Quem pode fazer:** Usuário com permissão de edição no registro.

**Passo a passo:**

87. Na etapa de recursos, escolha a opção de link ou URL.

88. Cole o endereço completo do link.

89. Preencha nome do recurso.

90. Descreva o que o link contém.

91. Salve o recurso.

92. Abra o link depois de salvar para confirmar que está correto.

**Resultado esperado:** O link fica associado ao registro e pode ser acessado pela página do recurso.

**Cuidados:** Evite links temporários, privados sem permissão ou dependentes de sessão pessoal.

> **[FIGURA 24] Cadastro de link externo como Recurso**
> Inserir print do formulário de recurso no modo link/URL.
> **Arquivo sugerido:** `imagens/figura-24-cadastro-de-link-externo-como-recurso.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 24 - Cadastro de link externo como Recurso](imagens/figura-24-cadastro-de-link-externo-como-recurso.png)`


### 7.6 Adicionar vários recursos

**Quando usar:** Quando um mesmo registro possui mais de um arquivo, anexo ou link associado.

**Quem pode fazer:** Usuário com permissão de edição no registro.

**Passo a passo:**

93. Adicione o primeiro recurso normalmente.

94. Use a opção de salvar e adicionar outro, se disponível.

95. Repita o preenchimento para cada arquivo ou link.

96. Dê nomes diferentes e descritivos para cada recurso.

97. Ao terminar, finalize o cadastro e abra a página do registro para conferir.

**Resultado esperado:** Todos os arquivos ou links ficam reunidos no mesmo registro.

**Cuidados:** Não crie registros separados para arquivos que fazem parte do mesmo produto, salvo orientação da curadoria.

# 8. Jornada 3: Editar registros e recursos

Editar é corrigir, completar ou atualizar um registro existente. A edição deve preservar coerência: título, descrição, status, acesso, arquivos e classificação precisam continuar contando a mesma história.

### 8.1 Abrir modo de edição do registro

**Quando usar:** Quando o usuário precisa alterar metadados, status, acesso ou recursos de um registro.

**Quem pode fazer:** Usuário com permissão de edição no registro, administrador da Unidade ou administrador visual.

**Passo a passo:**

98. Abra a página do registro.

99. Clique em “Gerenciar”, “Editar” ou botão equivalente.

100. Aguarde o formulário de edição carregar.

101. Faça as alterações necessárias.

102. Salve ao final.

103. Volte à página do registro e confira o resultado.

**Resultado esperado:** As alterações ficam salvas e visíveis conforme permissões do usuário.

**Cuidados:** Se o botão de edição não aparecer, o usuário provavelmente não tem permissão para alterar aquele registro.

> **[FIGURA 25] Botão Gerenciar/Editar Registro**
> Inserir print da página de um registro mostrando o botão de gerenciamento/edição.
> **Arquivo sugerido:** `imagens/figura-25-botao-gerenciar-editar-registro.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 25 - Botão Gerenciar/Editar Registro](imagens/figura-25-botao-gerenciar-editar-registro.png)`


> **[FIGURA 26] Formulário de edição de Registro**
> Inserir print do formulário de edição já preenchido.
> **Arquivo sugerido:** `imagens/figura-26-formulario-de-edicao-de-registro.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 26 - Formulário de edição de Registro](imagens/figura-26-formulario-de-edicao-de-registro.png)`


### 8.2 Alterar status do registro

**Quando usar:** Quando o registro muda de etapa operacional, por exemplo de elaboração para revisão ou publicação.

**Quem pode fazer:** Usuário editor, curadoria ou administrador visual, conforme regra interna.

**Passo a passo:**

104. Abra o registro em modo de edição.

105. Localize o campo Status.

106. Selecione o novo status adequado.

107. Revise se os demais campos estão coerentes com o novo status.

108. Salve.

109. Confira se o status aparece corretamente na página do registro e na listagem.

**Resultado esperado:** O status passa a refletir a situação atual do registro.

**Cuidados:** Não use status publicado ou finalizado sem revisar metadados, arquivos e acesso.

### 8.3 Alterar nível de acesso

**Quando usar:** Quando for necessário mudar quem pode visualizar o registro.

**Quem pode fazer:** Usuário autorizado pela regra interna de gestão do conteúdo.

**Passo a passo:**

110. Abra o registro em modo de edição.

111. Localize o campo de nível de acesso.

112. Escolha Público, Interno ou Privado, conforme o caso.

113. Leia novamente o título, descrição e arquivos para confirmar que o nível escolhido é adequado.

114. Salve.

115. Teste a visualização com o perfil adequado, se possível.

**Resultado esperado:** O registro passa a respeitar o novo nível de acesso.

**Cuidados:** Antes de tornar algo público, confira se não há informação sensível, dados pessoais, minuta interna ou documento sem autorização de divulgação.

### 8.4 Editar metadados de um recurso

**Quando usar:** Quando o arquivo ou link está correto, mas nome, descrição, formato ou metadados do recurso precisam de ajuste.

**Quem pode fazer:** Usuário com permissão de edição no registro/recurso.

**Passo a passo:**

116. Abra a página do registro.

117. Localize o recurso desejado.

118. Abra a página do recurso ou a aba de recursos no modo de edição.

119. Clique em editar ou gerenciar recurso.

120. Altere nome, descrição, formato ou demais campos.

121. Salve e confira a página final.

**Resultado esperado:** O recurso continua vinculado ao registro, com metadados corrigidos.

**Cuidados:** Não substitua o arquivo se o problema estiver apenas no texto descritivo.

> **[FIGURA 27] Edição de Recurso existente**
> Inserir print da tela de edição de um recurso já cadastrado.
> **Arquivo sugerido:** `imagens/figura-27-edicao-de-recurso-existente.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 27 - Edição de Recurso existente](imagens/figura-27-edicao-de-recurso-existente.png)`


### 8.5 Substituir arquivo de um recurso

**Quando usar:** Quando o arquivo anexado está errado, desatualizado ou precisa ser substituído por nova versão.

**Quem pode fazer:** Usuário com permissão de edição no registro/recurso.

**Passo a passo:**

122. Abra o registro em modo de edição.

123. Acesse a área de recursos.

124. Abra o recurso que terá o arquivo substituído.

125. Use a opção de remover/substituir arquivo, conforme a interface homologada.

126. Escolha o novo arquivo.

127. Atualize nome, descrição e formato se necessário.

128. Salve e abra o recurso para confirmar.

**Resultado esperado:** O recurso passa a apontar para o arquivo correto.

**Cuidados:** Se a interface não permitir substituição direta, registre a ocorrência para suporte/curadoria antes de criar duplicatas.

> **[FIGURA 28] Substituição de arquivo do Recurso**
> Inserir print da área da interface usada para trocar/remover o arquivo de um recurso existente.
> **Arquivo sugerido:** `imagens/figura-28-substituicao-de-arquivo-do-recurso.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 28 - Substituição de arquivo do Recurso](imagens/figura-28-substituicao-de-arquivo-do-recurso.png)`


### 8.6 Remover recurso

**Quando usar:** Quando um arquivo ou link foi associado por engano, ficou obsoleto ou não deve mais estar vinculado ao registro.

**Quem pode fazer:** Usuário com permissão de edição e autorização para remover o recurso.

**Passo a passo:**

129. Abra o registro em modo de edição.

130. Acesse a área de recursos.

131. Localize o recurso a remover.

132. Use a opção de excluir/remover recurso.

133. Confirme a operação se a interface pedir confirmação.

134. Volte à página do registro e verifique se o recurso não aparece mais.

**Resultado esperado:** O recurso deixa de aparecer no registro.

**Cuidados:** Excluir recurso não é o mesmo que excluir registro. Use com cuidado e apenas quando houver certeza.

# 9. Jornada 4: Revisar e publicar com segurança

A revisão evita que registros incompletos, duplicados, mal classificados ou com acesso incorreto sejam publicados. A curadoria deve olhar o conjunto: metadados, arquivos, status, licença e visibilidade.

### 9.1 Checklist de revisão do registro

| **Item**                                               | **Conferido?** | **Observações** |
|--------------------------------------------------------|----------------|-----------------|
| Título é claro, específico e compreensível.            | ☐ Sim ☐ Não    |                 |
| Descrição explica o conteúdo e o contexto do material. | ☐ Sim ☐ Não    |                 |
| Unidade responsável está correta.                      | ☐ Sim ☐ Não    |                 |
| Projeto associado está correto ou justificado.         | ☐ Sim ☐ Não    |                 |
| CCD foi escolhido de forma coerente.                   | ☐ Sim ☐ Não    |                 |
| Tema, escopo, abrangência e fonte estão adequados.     | ☐ Sim ☐ Não    |                 |
| Status combina com a situação real do registro.        | ☐ Sim ☐ Não    |                 |
| Nível de acesso foi escolhido corretamente.            | ☐ Sim ☐ Não    |                 |
| Licença está preenchida quando aplicável.              | ☐ Sim ☐ Não    |                 |
| Arquivos ou links abrem corretamente.                  | ☐ Sim ☐ Não    |                 |
| Não há duplicidade com outro registro.                 | ☐ Sim ☐ Não    |                 |
| Não há informação sensível em registro público.        | ☐ Sim ☐ Não    |                 |

### 9.2 Revisar metadados

**Quando usar:** Quando um registro foi criado, alterado ou encaminhado para publicação.

**Quem pode fazer:** Curadoria, editor responsável ou administrador visual.

**Passo a passo:**

135. Abra a página do registro.

136. Leia título e descrição como se fosse um usuário externo ao setor.

137. Confira Unidade, Projeto e CCD.

138. Confira campos controlados e campos livres.

139. Abra modo de edição apenas se precisar corrigir.

140. Salve alterações e volte à leitura para conferir.

**Resultado esperado:** O registro fica compreensível e recuperável por busca e filtros.

**Cuidados:** Não aprove registro que dependa de conhecimento informal para ser entendido.

### 9.3 Revisar arquivos e links

**Quando usar:** Quando o registro possui recursos associados.

**Quem pode fazer:** Curadoria, editor responsável ou administrador visual.

**Passo a passo:**

141. Abra cada recurso associado ao registro.

142. Confira se o nome do recurso corresponde ao conteúdo.

143. Baixe ou abra o arquivo quando necessário.

144. Verifique se o link externo funciona.

145. Confirme se o recurso não está duplicado.

146. Confirme se o conteúdo pode ser exibido no nível de acesso escolhido.

**Resultado esperado:** Os recursos ficam corretos, acessíveis e coerentes com o registro.

**Cuidados:** Um registro bom com arquivo errado vira armadilha de gaveta: parece organizado, mas leva o usuário para o lugar errado.

### 9.4 Revisar acesso antes de publicar

**Quando usar:** Antes de tornar um registro público ou antes de mudar seu nível de acesso.

**Quem pode fazer:** Curadoria e responsáveis autorizados.

**Passo a passo:**

147. Confira o campo de acesso.

148. Leia o conteúdo do registro.

149. Abra cada recurso e verifique se há conteúdo sensível.

150. Confirme licença e autorização de divulgação.

151. Se houver dúvida, mantenha restrito e encaminhe para validação responsável.

**Resultado esperado:** O acesso do registro fica adequado à regra institucional.

**Cuidados:** A publicação pública deve ser tratada como ação deliberada, não como valor padrão automático.

> **Regra prática de acesso**
> Público: qualquer pessoa pode visualizar. Interno: apenas usuários logados/internos, conforme regra do projeto. Privado: acesso restrito ao responsável/owner e administradores autorizados, conforme implementação homologada.


# 10. Jornada 5: Administrar pela interface web

Administração visual é o conjunto de tarefas administrativas feitas pelo navegador. Ela inclui gerenciar usuários, recuperar senhas, criar e editar unidades, criar e editar projetos, ajustar membros e papéis e tratar registros excluídos.

> **Limite da administração visual**
> Algumas tarefas administrativas não são feitas pela interface web, como instalação, criação de sysadmin do zero quando não há acesso prévio, alteração de plugins, mudanças de schema, reindexação, ajustes de servidor ou correções técnicas. Encaminhe esses casos à equipe técnica.


> **[FIGURA 29] Menu administrativo do usuário**
> Inserir print do menu de um usuário administrador visual, mostrando opções adicionais disponíveis.
> **Arquivo sugerido:** `imagens/figura-29-menu-administrativo-do-usuario.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 29 - Menu administrativo do usuário](imagens/figura-29-menu-administrativo-do-usuario.png)`


### 10.1 Localizar usuários

**Quando usar:** Quando o administrador precisa conferir dados, permissões ou recuperar acesso de um usuário.

**Quem pode fazer:** Administrador visual ou sysadmin.

**Passo a passo:**

152. Faça login com conta administrativa.

153. Acesse a área de usuários, normalmente pelo endereço ou menu de usuários.

154. Use a busca por nome, usuário ou e-mail institucional.

155. Abra o perfil do usuário correto.

156. Confira nome completo, e-mail e informações exibidas.

**Resultado esperado:** O administrador encontra o usuário correto antes de alterar qualquer informação.

**Cuidados:** Confirme a identidade do usuário antes de trocar senha ou alterar permissões.

> **[FIGURA 30] Listagem/busca de Usuários**
> Inserir print da página de usuários com campo de busca.
> **Arquivo sugerido:** `imagens/figura-30-listagem-busca-de-usuarios.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 30 - Listagem/busca de Usuários](imagens/figura-30-listagem-busca-de-usuarios.png)`


> **[FIGURA 31] Perfil de Usuário**
> Inserir print de um perfil de usuário de teste, sem dados pessoais sensíveis.
> **Arquivo sugerido:** `imagens/figura-31-perfil-de-usuario.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 31 - Perfil de Usuário](imagens/figura-31-perfil-de-usuario.png)`


### 10.2 Criar usuário

**Quando usar:** Quando uma pessoa autorizada precisa acessar o CKAN SFB e a criação de conta pela interface está habilitada.

**Quem pode fazer:** Usuário autorizado ou administrador visual, conforme configuração do portal.

**Passo a passo:**

157. Verifique se existe opção de registrar/criar usuário na interface.

158. Preencha nome de usuário, nome completo, e-mail institucional e senha inicial, conforme o formulário solicitar.

159. Salve o cadastro.

160. Peça ao usuário para fazer login e atualizar dados pessoais, se necessário.

161. Depois, associe o usuário à Unidade ou Projeto adequado, quando aplicável.

**Resultado esperado:** O usuário passa a ter conta ativa no CKAN SFB.

**Cuidados:** Se a criação de contas via web estiver desabilitada, solicite criação pela equipe técnica ou pelo fluxo institucional definido.

> **[FIGURA 32] Tela de criação/registro de Usuário**
> Inserir print da tela de cadastro de usuário, caso esteja habilitada no CKAN SFB.
> **Arquivo sugerido:** `imagens/figura-32-tela-de-criacao-registro-de-usuario.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 32 - Tela de criação/registro de Usuário](imagens/figura-32-tela-de-criacao-registro-de-usuario.png)`


### 10.3 Alterar senha de usuário

**Quando usar:** Quando o usuário esqueceu a senha ou perdeu acesso ao e-mail de recuperação.

**Quem pode fazer:** Administrador visual/sysadmin com permissão de gerenciar usuários.

**Passo a passo:**

162. Localize o usuário na área de usuários.

163. Abra o perfil correto.

164. Clique em “Gerenciar”.

165. Defina uma nova senha ou senha temporária, conforme a interface permitir.

166. Salve.

167. Comunique o usuário por canal seguro.

**Resultado esperado:** O usuário consegue acessar novamente o portal.

**Cuidados:** Evite reutilizar senhas padrão. Oriente troca após o primeiro acesso, quando possível.

> **[FIGURA 33] Tela de gerenciamento de Usuário**
> Inserir print da tela de gerenciamento de usuário com campos editáveis, ocultando informações sensíveis.
> **Arquivo sugerido:** `imagens/figura-33-tela-de-gerenciamento-de-usuario.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 33 - Tela de gerenciamento de Usuário](imagens/figura-33-tela-de-gerenciamento-de-usuario.png)`


### 10.4 Criar Unidade

**Quando usar:** Quando uma nova unidade institucional precisa ser representada no CKAN SFB.

**Quem pode fazer:** Administrador visual com permissão para criar Unidades/organizações.

**Passo a passo:**

168. Acesse o menu “Unidades”.

169. Clique em “Adicionar Unidade” ou opção equivalente.

170. Preencha nome oficial da unidade.

171. Preencha descrição objetiva.

172. Adicione imagem/logotipo apenas se houver padrão institucional.

173. Salve.

174. Abra a página criada e confira o resultado.

**Resultado esperado:** A nova Unidade fica disponível para associação de registros e membros.

**Cuidados:** Evite criar unidades duplicadas por variação de sigla ou grafia. Consulte a curadoria antes de criar.

> **[FIGURA 34] Criação de Unidade**
> Inserir print do formulário de criação de Unidade.
> **Arquivo sugerido:** `imagens/figura-34-criacao-de-unidade.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 34 - Criação de Unidade](imagens/figura-34-criacao-de-unidade.png)`


### 10.5 Gerenciar membros de uma Unidade

**Quando usar:** Quando usuários precisam criar, editar ou administrar registros vinculados a uma Unidade.

**Quem pode fazer:** Administrador da Unidade ou sysadmin.

**Passo a passo:**

175. Abra a página da Unidade.

176. Clique em “Gerenciar” ou opção administrativa equivalente.

177. Acesse a aba de membros.

178. Adicione o usuário pelo nome de usuário ou e-mail, conforme a interface pedir.

179. Escolha o papel adequado.

180. Salve.

181. Confirme se o usuário aparece na lista de membros.

**Resultado esperado:** O usuário passa a ter o papel definido dentro da Unidade.

**Cuidados:** Dê o menor nível de permissão suficiente para a tarefa. Permissão demais vira gaveta aberta em sala movimentada.

> **[FIGURA 35] Membros de Unidade**
> Inserir print da aba de membros de uma Unidade, usando usuários de teste.
> **Arquivo sugerido:** `imagens/figura-35-membros-de-unidade.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 35 - Membros de Unidade](imagens/figura-35-membros-de-unidade.png)`


### 10.6 Criar Projeto

**Quando usar:** Quando um novo projeto, programa, ação ou agrupamento precisa organizar registros no CKAN SFB.

**Quem pode fazer:** Administrador visual com permissão para criar Projetos/grupos.

**Passo a passo:**

182. Acesse o menu “Projetos”.

183. Clique em “Adicionar Projeto” ou opção equivalente.

184. Preencha nome oficial do projeto.

185. Preencha descrição e critério de inclusão.

186. Adicione imagem, se houver padrão institucional.

187. Salve e confira a página criada.

**Resultado esperado:** O Projeto fica disponível para associação de registros.

**Cuidados:** Não use Projeto para substituir Unidade. Projeto organiza por tema/ação; Unidade responde institucionalmente.

> **[FIGURA 36] Criação de Projeto**
> Inserir print do formulário de criação de Projeto.
> **Arquivo sugerido:** `imagens/figura-36-criacao-de-projeto.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 36 - Criação de Projeto](imagens/figura-36-criacao-de-projeto.png)`


### 10.7 Gerenciar membros de um Projeto

**Quando usar:** Quando usuários precisam acompanhar ou administrar um projeto.

**Quem pode fazer:** Administrador do Projeto ou sysadmin.

**Passo a passo:**

188. Abra a página do Projeto.

189. Clique em “Gerenciar”.

190. Acesse a aba de membros, se disponível.

191. Adicione, remova ou altere papéis de usuários conforme a necessidade.

192. Salve e confira a lista de membros.

**Resultado esperado:** A equipe do Projeto fica atualizada.

**Cuidados:** Permissões de Projeto podem não ser iguais às permissões de Unidade. Confira o efeito esperado antes de usar Projeto como regra de acesso.

> **[FIGURA 37] Membros de Projeto**
> Inserir print da área de membros de um Projeto, se disponível na interface.
> **Arquivo sugerido:** `imagens/figura-37-membros-de-projeto.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 37 - Membros de Projeto](imagens/figura-37-membros-de-projeto.png)`


### 10.8 Mover registro entre Unidades

**Quando usar:** Quando um registro foi cadastrado na Unidade errada ou mudou de responsabilidade institucional.

**Quem pode fazer:** Administrador visual ou usuário com permissão de edição suficiente.

**Passo a passo:**

193. Abra o registro em modo de edição.

194. Localize o campo de Unidade/organização responsável.

195. Selecione a Unidade correta.

196. Revise Projeto, acesso e status para garantir coerência.

197. Salve.

198. Abra a página da Unidade nova e confirme se o registro aparece.

**Resultado esperado:** O registro passa a pertencer à Unidade correta.

**Cuidados:** Mover Unidade pode alterar quem consegue editar o registro. Faça esse ajuste com cuidado.

> **[FIGURA 38] Alteração de Unidade em Registro**
> Inserir print do campo de Unidade/organização no formulário de edição do registro.
> **Arquivo sugerido:** `imagens/figura-38-alteracao-de-unidade-em-registro.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 38 - Alteração de Unidade em Registro](imagens/figura-38-alteracao-de-unidade-em-registro.png)`


### 10.9 Excluir registro

**Quando usar:** Quando um registro foi criado por engano, está duplicado ou deve sair da navegação normal.

**Quem pode fazer:** Usuário com permissão de edição/exclusão ou administrador visual.

**Passo a passo:**

199. Abra o registro.

200. Entre em “Gerenciar” ou “Editar”.

201. Use a opção de excluir/remover registro.

202. Leia a mensagem de confirmação.

203. Confirme somente se houver certeza.

204. Verifique se o registro deixou de aparecer na busca comum.

**Resultado esperado:** O registro é marcado como excluído e sai da listagem normal.

**Cuidados:** Registro excluído pode continuar reservado internamente, inclusive impedindo reutilização do mesmo nome/URL.

> **[FIGURA 39] Exclusão de Registro**
> Inserir print da tela ou botão de exclusão de registro, sem confirmar em ambiente real sem necessidade.
> **Arquivo sugerido:** `imagens/figura-39-exclusao-de-registro.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 39 - Exclusão de Registro](imagens/figura-39-exclusao-de-registro.png)`


### 10.10 Eliminar definitivamente registro excluído

**Quando usar:** Quando um registro excluído não deve ser recuperado e precisa ser apagado definitivamente para liberar nome/URL ou limpar a lixeira.

**Quem pode fazer:** Apenas administrador visual/sysadmin autorizado.

**Passo a passo:**

205. Acesse a área administrativa de registros excluídos/lixeira, quando disponível.

206. Localize o registro excluído.

207. Confira cuidadosamente se é o item correto.

208. Use a opção de eliminação definitiva ou purge.

209. Confirme apenas se a decisão for irreversível e autorizada.

**Resultado esperado:** O registro é removido definitivamente, quando a operação for suportada pela interface.

**Cuidados:** Esta operação não deve ser usada como rotina. Uma vez confirmada, pode não haver recuperação pela interface.

> **[FIGURA 40] Lixeira/Administração de excluídos**
> Inserir print da página administrativa de registros excluídos, usando registros de teste.
> **Arquivo sugerido:** `imagens/figura-40-lixeira-administracao-de-excluidos.png`
> **Quando o print estiver salvo, substitua/acompanhe este marcador com:** `![Figura 40 - Lixeira/Administração de excluídos](imagens/figura-40-lixeira-administracao-de-excluidos.png)`


> **Unidades e Projetos excluídos**
> No CKAN 2.10, a eliminação definitiva de organizações e grupos pela interface pode não estar disponível. Se uma Unidade ou Projeto precisar ser removido definitivamente e a interface não oferecer essa opção, encaminhe para a equipe técnica.


# 11. Problemas comuns e orientações rápidas

| **Problema**                              | **Orientação**                                                                                            |
|-------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| Não consigo entrar                        | Confirme usuário e senha. Use recuperação de senha. Se não resolver, peça apoio ao administrador.         |
| Esqueci minha senha                       | Use a opção de redefinição por e-mail ou solicite alteração ao administrador visual.                      |
| Não vejo o botão de criar registro        | Você pode não ter permissão na Unidade. Solicite inclusão como membro/editor.                             |
| Registro não aparece para outro usuário   | Confira nível de acesso: Público, Interno ou Privado.                                                     |
| Registro esperado não aparece na busca    | Teste outro termo, remova filtros e confira se o registro não está interno/privado.                       |
| Projeto não aparece no formulário         | Verifique se o Projeto existe e se está cadastrado corretamente.                                          |
| Unidade não aparece no formulário         | Solicite criação ou ajuste da Unidade ao administrador visual.                                            |
| Campo obrigatório impede salvar           | Preencha o campo destacado ou revise se a opção escolhida é válida.                                       |
| Opção de lista está faltando              | Encaminhe pedido à curadoria/gestão. Não improvise em campo livre.                                        |
| Arquivo não abre no navegador             | Tente baixar o arquivo. Alguns formatos não têm pré-visualização.                                         |
| Upload demora ou falha                    | Verifique tamanho e conexão. Se persistir, registre ocorrência com tipo e tamanho do arquivo.             |
| Nome de registro não pode ser reutilizado | Pode existir registro excluído com o mesmo identificador. Verifique a lixeira/administração de excluídos. |

# 12. Boas práticas de preenchimento

| **Campo/tema** | **Boa prática**                                                                                             |
|----------------|-------------------------------------------------------------------------------------------------------------|
| Título         | Use nome claro e específico. Evite “Relatório”, “Documento final” ou siglas sem contexto.                   |
| Descrição      | Explique o que é, para que serve, período/abrangência, origem e principais cuidados de uso.                 |
| Unidade        | Escolha a unidade responsável de fato, não apenas a unidade que está cadastrando.                           |
| Projeto        | Use o projeto que organiza o conteúdo. Não crie projeto novo por variação pequena de nome.                  |
| CCD            | Escolha a classificação mais adequada. Se houver dúvida, peça validação à curadoria.                        |
| Temas e tags   | Use termos úteis para recuperação. Evite excesso ou variações desnecessárias.                               |
| Status         | Atualize status quando a situação mudar. Não deixe rascunho como publicado por engano.                      |
| Acesso         | Revise antes de tornar público. Conteúdo interno ou privado deve ficar protegido.                           |
| Licença        | Informe quando aplicável. Licença ausente reduz clareza sobre uso e redistribuição.                         |
| Recursos       | Nomeie arquivos de forma compreensível. Descreva cada recurso para que o usuário saiba o que está baixando. |

> **Princípio do cadastro bom**
> Um registro bem preenchido deve ser entendido por alguém que não participou da produção do material. Se só quem cadastrou entende, o cadastro ainda não terminou.


# 13. Checklists operacionais

### 13.1 Checklist rápido para cadastrar Registro

| **Item**                                           | **Conferido?** | **Observações** |
|----------------------------------------------------|----------------|-----------------|
| Busquei registros semelhantes antes de criar novo. | ☐ Sim ☐ Não    |                 |
| Título está claro.                                 | ☐ Sim ☐ Não    |                 |
| Descrição está suficiente.                         | ☐ Sim ☐ Não    |                 |
| Unidade correta foi selecionada.                   | ☐ Sim ☐ Não    |                 |
| Projeto correto foi selecionado, quando aplicável. | ☐ Sim ☐ Não    |                 |
| CCD e campos de classificação foram preenchidos.   | ☐ Sim ☐ Não    |                 |
| Status inicial está coerente.                      | ☐ Sim ☐ Não    |                 |
| Acesso foi definido com cuidado.                   | ☐ Sim ☐ Não    |                 |
| Licença foi preenchida quando aplicável.           | ☐ Sim ☐ Não    |                 |
| Arquivos ou links foram adicionados e testados.    | ☐ Sim ☐ Não    |                 |

### 13.2 Checklist rápido para cadastrar Recurso

| **Item**                                   | **Conferido?** | **Observações** |
|--------------------------------------------|----------------|-----------------|
| Arquivo/link pertence ao registro correto. | ☐ Sim ☐ Não    |                 |
| Nome do recurso é claro.                   | ☐ Sim ☐ Não    |                 |
| Descrição explica o conteúdo do recurso.   | ☐ Sim ☐ Não    |                 |
| Formato está correto.                      | ☐ Sim ☐ Não    |                 |
| Arquivo abre ou link funciona.             | ☐ Sim ☐ Não    |                 |
| Não há informação sensível indevida.       | ☐ Sim ☐ Não    |                 |
| Versão do arquivo é a correta.             | ☐ Sim ☐ Não    |                 |

### 13.3 Checklist rápido para Administração de Usuário

| **Item**                                                       | **Conferido?** | **Observações** |
|----------------------------------------------------------------|----------------|-----------------|
| Usuário correto foi localizado.                                | ☐ Sim ☐ Não    |                 |
| Nome completo e e-mail estão corretos.                         | ☐ Sim ☐ Não    |                 |
| Conta não é duplicada.                                         | ☐ Sim ☐ Não    |                 |
| Usuário está vinculado à Unidade correta.                      | ☐ Sim ☐ Não    |                 |
| Papel concedido é o mínimo necessário.                         | ☐ Sim ☐ Não    |                 |
| Senha temporária foi comunicada de forma segura, se aplicável. | ☐ Sim ☐ Não    |                 |

### 13.4 Checklist rápido para criação de Unidade

| **Item**                                    | **Conferido?** | **Observações** |
|---------------------------------------------|----------------|-----------------|
| Nome oficial confirmado.                    | ☐ Sim ☐ Não    |                 |
| Sigla conferida.                            | ☐ Sim ☐ Não    |                 |
| Não existe Unidade duplicada.               | ☐ Sim ☐ Não    |                 |
| Descrição está clara.                       | ☐ Sim ☐ Não    |                 |
| Responsável institucional identificado.     | ☐ Sim ☐ Não    |                 |
| Administradores/membros iniciais definidos. | ☐ Sim ☐ Não    |                 |

### 13.5 Checklist rápido para criação de Projeto

| **Item**                                    | **Conferido?** | **Observações** |
|---------------------------------------------|----------------|-----------------|
| Nome oficial confirmado.                    | ☐ Sim ☐ Não    |                 |
| Não existe Projeto duplicado.               | ☐ Sim ☐ Não    |                 |
| Critério de inclusão está claro.            | ☐ Sim ☐ Não    |                 |
| Descrição explica objetivo do Projeto.      | ☐ Sim ☐ Não    |                 |
| Responsável ou equipe gestora identificada. | ☐ Sim ☐ Não    |                 |
| Membros iniciais definidos, se aplicável.   | ☐ Sim ☐ Não    |                 |

# 14. Glossário operacional

| **Termo**            | **Definição**                                                                            |
|----------------------|------------------------------------------------------------------------------------------|
| Acesso               | Regra que define quem pode visualizar o registro.                                        |
| Administrador visual | Usuário com permissão para administrar elementos do portal pela interface web.           |
| Card                 | Resumo de um registro exibido na página de resultados.                                   |
| CCD                  | Código/classificação usada para organizar o conteúdo conforme vocabulário institucional. |
| Curadoria            | Atividade de revisar qualidade, coerência, completude e acesso dos registros.            |
| Filtro               | Opção lateral usada para restringir resultados de busca.                                 |
| Interno              | Nível de acesso destinado a usuários logados/internos, conforme regra do projeto.        |
| Licença              | Indicação de condições de uso, reuso e distribuição do conteúdo.                         |
| Metadados            | Campos que descrevem e classificam um registro ou recurso.                               |
| Privado              | Nível de acesso restrito a responsáveis e administradores autorizados.                   |
| Projeto              | Agrupamento temático/operacional de registros.                                           |
| Público              | Nível de acesso visível a qualquer visitante.                                            |
| Recurso              | Arquivo ou link associado a um registro.                                                 |
| Registro             | Ficha principal de descrição de um conteúdo no CKAN SFB.                                 |
| Status               | Situação operacional do registro.                                                        |
| Unidade              | Estrutura institucional responsável pelo registro.                                       |

# 15. Lista consolidada de figuras a capturar

| **Figura** | **Print a capturar**                              |
|------------|---------------------------------------------------|
| 01         | Visão geral dos elementos principais da interface |
| 02         | Tela de login                                     |
| 03         | Usuário logado no menu superior                   |
| 04         | Tela de recuperação de senha                      |
| 05         | Página inicial completa                           |
| 06         | Busca principal da home                           |
| 07         | Página de resultados de busca                     |
| 08         | Filtros laterais de busca                         |
| 09         | Filtro aplicado                                   |
| 10         | Card de registro na listagem                      |
| 11         | Página de listagem de Unidades                    |
| 12         | Página de uma Unidade                             |
| 13         | Página de listagem de Projetos                    |
| 14         | Página de um Projeto                              |
| 15         | Página completa de um Registro                    |
| 16         | Metadados adicionais do Registro                  |
| 17         | Lista de recursos de um Registro                  |
| 18         | Página de leitura de um Recurso                   |
| 19         | Botão de criação de Registro                      |
| 20         | Formulário de criação de Registro                 |
| 21         | Campos institucionais do Registro                 |
| 22         | Campo de Status e Acesso                          |
| 23         | Tela de envio de arquivo/Recurso                  |
| 24         | Cadastro de link externo como Recurso             |
| 25         | Botão Gerenciar/Editar Registro                   |
| 26         | Formulário de edição de Registro                  |
| 27         | Edição de Recurso existente                       |
| 28         | Substituição de arquivo do Recurso                |
| 29         | Menu administrativo do usuário                    |
| 30         | Listagem/busca de Usuários                        |
| 31         | Perfil de Usuário                                 |
| 32         | Tela de criação/registro de Usuário               |
| 33         | Tela de gerenciamento de Usuário                  |
| 34         | Criação de Unidade                                |
| 35         | Membros de Unidade                                |
| 36         | Criação de Projeto                                |
| 37         | Membros de Projeto                                |
| 38         | Alteração de Unidade em Registro                  |
| 39         | Exclusão de Registro                              |
| 40         | Lixeira/Administração de excluídos                |


## Arquivos sugeridos para as imagens

| Figura | Print a capturar | Arquivo sugerido |
|---|---|---|
| 01 | Visão geral dos elementos principais da interface | `imagens/figura-01-visao-geral-dos-elementos-principais-da-interface.png` |
| 02 | Tela de login | `imagens/figura-02-tela-de-login.png` |
| 03 | Usuário logado no menu superior | `imagens/figura-03-usuario-logado-no-menu-superior.png` |
| 04 | Tela de recuperação de senha | `imagens/figura-04-tela-de-recuperacao-de-senha.png` |
| 05 | Página inicial completa | `imagens/figura-05-pagina-inicial-completa.png` |
| 06 | Busca principal da home | `imagens/figura-06-busca-principal-da-home.png` |
| 07 | Página de resultados de busca | `imagens/figura-07-pagina-de-resultados-de-busca.png` |
| 08 | Filtros laterais de busca | `imagens/figura-08-filtros-laterais-de-busca.png` |
| 09 | Filtro aplicado | `imagens/figura-09-filtro-aplicado.png` |
| 10 | Card de registro na listagem | `imagens/figura-10-card-de-registro-na-listagem.png` |
| 11 | Página de listagem de Unidades | `imagens/figura-11-pagina-de-listagem-de-unidades.png` |
| 12 | Página de uma Unidade | `imagens/figura-12-pagina-de-uma-unidade.png` |
| 13 | Página de listagem de Projetos | `imagens/figura-13-pagina-de-listagem-de-projetos.png` |
| 14 | Página de um Projeto | `imagens/figura-14-pagina-de-um-projeto.png` |
| 15 | Página completa de um Registro | `imagens/figura-15-pagina-completa-de-um-registro.png` |
| 16 | Metadados adicionais do Registro | `imagens/figura-16-metadados-adicionais-do-registro.png` |
| 17 | Lista de recursos de um Registro | `imagens/figura-17-lista-de-recursos-de-um-registro.png` |
| 18 | Página de leitura de um Recurso | `imagens/figura-18-pagina-de-leitura-de-um-recurso.png` |
| 19 | Botão de criação de Registro | `imagens/figura-19-botao-de-criacao-de-registro.png` |
| 20 | Formulário de criação de Registro | `imagens/figura-20-formulario-de-criacao-de-registro.png` |
| 21 | Campos institucionais do Registro | `imagens/figura-21-campos-institucionais-do-registro.png` |
| 22 | Campo de Status e Acesso | `imagens/figura-22-campo-de-status-e-acesso.png` |
| 23 | Tela de envio de arquivo/Recurso | `imagens/figura-23-tela-de-envio-de-arquivo-recurso.png` |
| 24 | Cadastro de link externo como Recurso | `imagens/figura-24-cadastro-de-link-externo-como-recurso.png` |
| 25 | Botão Gerenciar/Editar Registro | `imagens/figura-25-botao-gerenciar-editar-registro.png` |
| 26 | Formulário de edição de Registro | `imagens/figura-26-formulario-de-edicao-de-registro.png` |
| 27 | Edição de Recurso existente | `imagens/figura-27-edicao-de-recurso-existente.png` |
| 28 | Substituição de arquivo do Recurso | `imagens/figura-28-substituicao-de-arquivo-do-recurso.png` |
| 29 | Menu administrativo do usuário | `imagens/figura-29-menu-administrativo-do-usuario.png` |
| 30 | Listagem/busca de Usuários | `imagens/figura-30-listagem-busca-de-usuarios.png` |
| 31 | Perfil de Usuário | `imagens/figura-31-perfil-de-usuario.png` |
| 32 | Tela de criação/registro de Usuário | `imagens/figura-32-tela-de-criacao-registro-de-usuario.png` |
| 33 | Tela de gerenciamento de Usuário | `imagens/figura-33-tela-de-gerenciamento-de-usuario.png` |
| 34 | Criação de Unidade | `imagens/figura-34-criacao-de-unidade.png` |
| 35 | Membros de Unidade | `imagens/figura-35-membros-de-unidade.png` |
| 36 | Criação de Projeto | `imagens/figura-36-criacao-de-projeto.png` |
| 37 | Membros de Projeto | `imagens/figura-37-membros-de-projeto.png` |
| 38 | Alteração de Unidade em Registro | `imagens/figura-38-alteracao-de-unidade-em-registro.png` |
| 39 | Exclusão de Registro | `imagens/figura-39-exclusao-de-registro.png` |
| 40 | Lixeira/Administração de excluídos | `imagens/figura-40-lixeira-administracao-de-excluidos.png` |

# 16. Referências consultadas

- CKAN 2.10.9 Documentation. User guide e Sysadmin guide. Consultado em maio de 2026.

- CKAN 2.11 Documentation. Overview e Sysadmin guide. Consultado em maio de 2026 para conferência de documentação atual.

- COSTA, Lucas Rodrigues et al. Guia do usuário do CKAN. IBICT, 2017.

- MANIFESTO_ROOTFS.md do projeto CKAN SFB, com descrição dos arquivos de customização da interface, templates, schema, traduções e extensões.

- Arquivos de instalação Docker do CKAN SFB: install_ckan_sfb_docker_full.sh, install_ckan_sfb_docker_full.vars e install_ckan_sfb_docker_full.secrets, usados apenas para compreender o ambiente alvo e a customização aplicada.
