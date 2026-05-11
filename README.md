# Instalação do CKAN Customizado para o SFB

## Passo a passo da instalação

1. Crie uma Máquina Virtual (VM) para a instalação e anote o IP de acesso a essa VM. Os requisitos mínimos são:

   - Sistema Operacional Linux Ubuntu, preferencialmente 24.04 LTS;
   - 4 GB de memória RAM;
   - 2 processadores;
   - 50 GB de disco, preferencialmente SSD;
   - Acesso SSH;
   - Usuário `root` ou com acesso `sudo`.

2. Acesse a máquina virtual através de um aplicativo SSH, como o PuTTY. Use o IP fornecido no momento da criação da VM e entre com o usuário `root` ou com um usuário com acesso `sudo`.

3. Uma vez dentro do terminal da VM, cole a seguinte sequência de comandos:

   ```bash
   git clone https://github.com/rlfonseca-lab/sfb.git
   cd sfb
   nano install_ckan_sfb_docker_full.vars
   nano install_ckan_sfb_docker_full.secrets
   chmod 700 install_ckan_sfb_docker_full.sh
   chmod 644 install_ckan_sfb_docker_full.vars
   chmod 600 install_ckan_sfb_docker_full.secrets
   sudo ./install_ckan_sfb_docker_full.sh
   ```

   Esses comandos têm por objetivo:

   1. Baixar os arquivos de instalação do CKAN customizado;
   2. Abrir o primeiro arquivo de configuração, que deve ser preenchido com valores como:
      - Endereço de acesso do sistema CKAN (`DOMAIN`);
      - E-mail do responsável por certificados (`CERTBOT_EMAIL`), geralmente definido pelo administrador de rede local;
      - E-mail do administrador principal do sistema CKAN (`CKAN_SYSADMIN_EMAIL`).
   3. Abrir o segundo arquivo de configuração, que deve ser preenchido com senhas como:
      - Senha para banco de dados do CKAN (`CKAN_DB_PASSWORD`);
      - Senha para o administrador do CKAN (`CKAN_SYSADMIN_PASSWORD`).
   4. Rodar o instalador previamente baixado.

4. O instalador fará todo o processo automaticamente, podendo levar até 10 minutos para toda a instalação. Ao final, o CKAN estará disponível com os seguintes dados:

   - **Endereço:** o mesmo fornecido antes da instalação;
   - **Nome de usuário:** `ckanadmin`;
   - **Senha:** senha para administrador do CKAN fornecida antes da instalação.
