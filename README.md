# Instalação do CKAN Customizado para o SFB
## Passo a Passo da instalação
1. Crie uma Máquina Virtual (VM) para a instalação, e anote o IP de acesso a essa VM. Seus requisitos mínimos são:
- Sistema Operacional Linux Ubuntu, preferencialmente 24.04 LTS;
- 4GB de memória RAM;
- 2 processadores;
- 50GB de disco, preferencialmente SSD;
- Acesso SSH;
- Usuário root ou com acesso sudo.
2. Acesse a máquina virtual através de um aplicativo SSH, como o PUTTY. Acesse usando o IP fornecido no momento da criação da VM, usando o usuário root ou com acesso sudo fornecido.
3. Uma vez dentro do terminal da VM, cole a seguinte sequência de comandos:
```text
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
i. Baixar os arquivos de instalação do CKAN customizado;
ii. Abrir o primeiro arquivo de configuração, que deve ser preenchido com valores como:
    - Endereço de acesso do sistema CKAN (DOMAIN);
    - Email do responsável por certificados (CERTBOT_EMAIL), geralmente definido pelo administrador de rede local;
    - Email do administrador principal do sistema CKAN (CKAN_SYSADMIN_EMAIL).
iii.  Abrir o segundo arquivo de configuração, que deve ser preenchido com senhas como:
    - Senha para banco de dados do CKAN (CKAN_DB_PASSWORD)
    - Senha para o administrador do CKAN (CKAN_SYSADMIN_PASSWORD)
iv. Rodar o instalador previamente baixado.
4. O instalador fará todo o processo automaticamente, podendo levar até 10 minutos para toda a instalação. Ao final, o CKAN estará disponível em:
- Endereço: O mesmo fornecido antes da instalação;
- Nome de usuário: ckanadmin
- Senha: Senha para administrador do CKAN fornecida antes da instalação.
