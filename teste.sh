#!/bin/bash
##################################################
# Name: samba4.deploy
# Description: Deploy of Samba4 on Linux Debian Jessie 8.10
# Script Maintainer: Rafael
#
# Versão: 2.5
# Last Updated: March 13th 2016
##################################################
###### Instalação do Samba4 no Debian 8.30 ####### 
# 
: <<'DESC'
Sistema desenvolvido para instalar complentamente um servidor DC em Samba4 no Debian 8.10 Jessie
Este sistema não foi testado em versões mais novas e/ou anteriores, portanto não me responsabilizo por erros.
No encurtador de links utilize o seguinte comando para baixar o código wget goo.gl/28pCdN -O samba4deploy.sh
para executar faça bash samba4deploy.sh e siga os passos da instalação.
Instalação do Debian 8.10
Particionamento Necessário: 
/ - 15Gb
/kit - 50Gb
/dados - 1Tera ou mais
no fstab ficará assim:
/dev/xvdx	/kit	ext4	user_xattr,acl,barrier=1	1
/dev/xvdy	/dados	ext4	user_xattr,acl,barrier=1	1
Para realizar a administração do AD samba4 no windows 7 utilize o RSAT
http://www.microsoft.com/downloads/en/details.aspx?FamilyID=7d2f6ad7-656b-4313-a005-4e344e43997d&displaylang=en
Incluir verificação de erros de download para Samba e outros arquivos.
Incluir sistema de backup do samba e restore
Todos os grupos serão pastas compartilhadas, se você quiser que um grupo não vire pasta compartilhada inicie o grupo com NS_
Incluir serviço de FTP no BDC File Server
DESC


##################################################
#Include source file with text functions
#
echo "Verificando Dependêcias"
echo ""
sleep 2
if [ ! -f textfuncs.fnc ]; then
echo "Baixando arquivo de configuração"
echo ""
sleep 2
wget goo.gl/klNlVy -O textfuncs.fnc
fi
sleep 3
source textfuncs.fnc
##################################################
#Descricao do sistema e Observações Importantes
#
CenterTitle "Samba4Deploy Criação de Servidores Linux"
Colorize 6 "
	Olá, 
	Você esta prestes a iniciar o sistema de deploy e compilação 
	automatizado de servidores Linux Kingit, você poderá criar 
	e linkar servidores de sua matriz e filiais, formando 
	um poderoso e confiável ambiente de redundância.
	
	O que estamos automatizando?
	- Instalação de Samba 4 Domain Controller
	- Instalação de Segundo AD linkado
	- Instalação de FileServer BDC
	- Inclusão de Novos HDs no Ambiente
	- Configuração conforme dados recolhidos
	- Criação de estrutura de Pastas
	- Configuração de Lixeira e Auditoria
	
"
Colorize 1 "	Sistema Homologado apenas para Linux Debian Jessie 8.10"
echo "
"
read -p "   Pressione [Enter] Para iniciar a Instalação, ou Crtl+C para Cancelar"

function InstalaEssenciais(){
	tput clear
	Colorize 2 "Atualizando Repositórios"
	echo ""
	sleep 2
	apt-get update 
	tput clear
	Colorize 2 "Instalando itens essenciais"
	echo ""
	sleep 2	
	export DEBIAN_FRONTEND=noninteractive #Desta maneira qualquer interactive post-install não irá parar o processo. 
	##################################################
	#Lista de itens essenciais para funcionamento do Samba 4 tanto PDC quanto BDC
	#
	#apt-get install -y build-essential libacl1-dev libattr1-dev libblkid-dev libreadline-dev python-dev python-dnspython gdb pkg-config libgnutls28-dev libpopt-dev libldap2-dev dnsutils libbsd-dev attr krb5-user docbook-xsl libcups2-dev acl chkconfig ntp rssh	
	#apt-get install -y acl attr autoconf bison build-essential debhelper dnsutils docbook-xml docbook-xsl flex gdb krb5-user libacl1-dev libaio-dev libattr1-dev libblkid-dev libbsd-dev libcap-dev libcups2-dev libgnutls28-dev libjson-perl libldap2-dev libncurses5-dev libpam0g-dev libparse-yapp-perl libpopt-dev libreadline-dev perl perl-modules pkg-config python-all-dev python-dev python-dnspython python-crypto xsltproc zlib1g-dev ntp rssh
	#apt-get install -y acl attr autoconf bison build-essential debhelper dnsutils docbook-xml docbook-xsl flex gdb krb5-user libacl1-dev libaio-dev libblkid-dev libbsd-dev libcap-dev libcups2-dev libgnutls28-dev libjson-perl libldap2-dev libncurses5-dev libpam0g-dev libparse-yapp-perl libpopt-dev libreadline-dev perl pkg-config python-all-dev python-dnspython python-crypto xsltproc ntp rssh
	apt-get install -y acl attr autoconf bind9utils bison build-essential debhelper dnsutils docbook-xml docbook-xsl flex gdb libjansson-dev krb5-user libacl1-dev libaio-dev libarchive-dev libattr1-dev libblkid-dev libbsd-dev libcap-dev libcups2-dev libgnutls28-dev libgpgme11-dev libjson-perl libldap2-dev libncurses5-dev libpam0g-dev libparse-yapp-perl libpopt-dev libreadline-dev nettle-dev perl perl-modules pkg-config python-all-dev python-crypto python-dbg python-dev python-dnspython python3-dnspython python-gpgme python3-gpgme python-markdown python3-markdown python3-dev xsltproc zlib1g-dev git libgnutls-dev
	tput clear
	Colorize 2 "Alterando o Time/Zone para Sao Paulo"
	echo ""
	sleep 2
	echo "America/Sao_Paulo" > /etc/timezone
	dpkg-reconfigure -f noninteractive tzdata
	tput clear
	Colorize 2 "Download do Samba 4.3.0"
	echo ""
	sleep 2
	wget http://ftp.samba.org/pub/samba/stable/samba-4.3.0.tar.gz
	sleep 2
	Colorize 2 "Descompactando..."
	echo ""
	sleep 2
	gzip -dc samba-4.3.0.tar.gz | tar x
	Colorize 2 "Descompactado com sucesso"
	echo ""
	if [ $TIPO = "M" ] || [ $TIPO = "B" ]; then
		sleep 2
		tput clear
		Colorize 2 "Download do Arquivo samba para configuracao da lixeira e auditoria"
		echo ""
		sleep 2
		wget "https://gist.githubusercontent.com/helladarion/8a537d8f9b17ed9014da/raw/9c6527f3330b7d2351bacf2bc6f4452b58bb633d/smbauditrecycle"
		tput clear
	fi
	if [ $TIPO = "M" ]; then
		Colorize 2 "Download do Arquivo home_fs.sh"
		echo ""
		sleep 2
		wget "https://gist.githubusercontent.com/helladarion/82335dec9745d4166d28/raw/326c9cdfbf60fab13ea2cb96877cbd7ae10e0b1e/home_fs.sh"
		chmod +x /root/home_fs.sh
		tput clear
		sleep 2
		wget "https://gist.githubusercontent.com/helladarion/80fa057c7e72b9c0921f/raw/eb820969f8896f80e5782c3c70d97a0d87fe2edd/Atalhos_base.vbs"
	elif [ $TIPO = "B" ]; then
		Colorize 2 "Download do Arquivo home.sh"
		echo ""
		sleep 2
		wget "https://gist.githubusercontent.com/helladarion/1e0614ea0b6c691fcbb2/raw/f2e29f5b5d62a563a2789f69a12e3d701a614653/home.sh"
		chmod +x /root/home.sh
		Colorize 2 "Download do Arquivo de atalhos_base.sh"
		echo ""
		sleep 2
		wget "https://gist.githubusercontent.com/helladarion/80fa057c7e72b9c0921f/raw/eb820969f8896f80e5782c3c70d97a0d87fe2edd/Atalhos_base.vbs"
	fi
}

function Ajustefstab(){ #Alteração do sistema de montagem do disco no / e posteriormente para as novas unidades
	Colorize 2 "Alterando os registros para o / assim que o sistema é iniciado"
	echo ""
	sleep 2
	sed -i "s/errors=remount-ro 0/user_xattr,acl,barrier=1 \t1/" /etc/fstab
	sleep 4
	mount -o remount,rw /
}

function Provisionamento(){
	
	if [ $TIPO = "P" ]; then
		Colorize 2 "Inicio do Provisionamento de PDC"
		echo ""
		sleep 2
		samba-tool domain provision --use-rfc2307 --realm=$C_FQDN --server-role=dc --dns-backend=SAMBA_INTERNAL --domain=$R_Domain --adminpass=$R_Passwd
		sleep 2
		Colorize 2 "Ajustando o Forwarder do samba"
		echo ""
		sleep 2
		sed -i "s/forwarder =.*/forwarder = $R_DNS/" /opt/samba/etc/smb.conf
	elif [ $TIPO = "M" ]; then
		Colorize 2 "Inicio do Provisionamento de MDC"
		echo ""
		sleep 2
		echo $R_Passwd | net ads join -U $R_ADMWIN
	elif [ $TIPO = "B" ]; then
		Colorize 2 "Inicio do Provisionamento de BDC"
		echo ""
		sleep 2
		#samba-tool domain provision --use-rfc2307 --realm=$C_FQDN --server-role=dc --dns-backend=SAMBA_INTERNAL --domain=$R_Domain --adminpass=$R_Passwd
		#samba-tool domain join $R_FQDN DC -Uadministrator --realm=$R_FQDN --dns-backend=SAMBA_INTERNAL --option="interfaces=lo eth0" --option="bind interfaces only=yes" --password=$R_Passwd
		samba-tool domain join $R_FQDN DC -Uadministrator --realm=$R_FQDN --dns-backend=SAMBA_INTERNAL --password=$R_Passwd
		sleep 2
		Colorize 2 "Ajustando o Forwarder do samba"
		echo ""
		sleep 2
		sed -i "s/interfaces =.*/&\n\tdns forwarder = 8.8.8.8/" /opt/samba/etc/smb.conf
		sleep 3
	fi
}

function MDC () {
	##################################################
	#Levantamento de dados Iniciais, exibição
	#
	CenterTitle "Configurações iniciais para o FileServer MDC" 
	tput cup 5 2
	Colorize 6 "Digite o nome deste servidor (hostname) ex.: servidor : "
	tput cup 6 2
	Colorize 6 "Digite o endereço de IP deste servidor. ex.: 192.168.253.1 : "
	tput cup 7 2
	Colorize 6 "Escolha a Mascara de rede: 1.) 255.255.0.0 ou 2.)255.255.255.0 : "
	tput cup 8 2
	Colorize 6 "Digite o Gateway da rede. ex.: 192.168.253.1 : "
	##################################################
	#Dados do servidor AD
	#
	tput cup 9 2
	echo ""
	Colorize 6 "  ==============( Servidor AD Destino )=============="
	echo ""
	tput cup 12 2
	Colorize 6 "Nome do domínio que deseja ingressar FQDN ex. empresa.matriz : "
	tput cup 13 2
	Colorize 6 "IP do servidor que deseja ingressar. ex.: 192.168.253.12 : "
	tput cup 14 2
	Colorize 6 "Usuario Administrator do AD : "
	tput cup 15 2
	Colorize 6 "Senha do Administrator do AD : "
	
	
	##################################################
	##Captação de Dados##
	#
	tput cup 5 2
	Colorize 6 "Digite o nome deste servidor (hostname) ex.: servidor : "
	read R_Host
	tput cup 6 2
	Colorize 6 "Digite o endereço de IP deste servidor. ex.: 192.168.253.1 : "
	read R_IP
	tput cup 7 2
	Colorize 6 "Escolha a Mascara de rede: 1.) 255.255.0.0 ou 2.)255.255.255.0 : "
	read R_Mask
	if [ $R_Mask = 1 ];then
		R_Mask=255.255.0.0
		varRecorte=$(echo $R_IP | cut -d. -f3,4)
		R_Broad=$(echo $R_IP | sed -n "s/$varRecorte$/255.255/p")
		R_Network=$(echo $R_IP | sed -n "s/$varRecorte$/0.0/p")
	else
		R_Mask=255.255.255.0
		varRecorte=$(echo $R_IP | cut -d. -f4)
		R_Broad=$(echo $R_IP | sed -n "s/$varRecorte$/255/p")
		R_Network=$(echo $R_IP | sed -n "s/$varRecorte$/0/p")
	fi
	tput cup 8 2
	Colorize 6 "Digite o Gateway da rede. ex.: 192.168.253.1 : "
	read R_Gat
	##################################################
	#Dados do servidor AD
	#
	tput cup 9 2
	echo ""
	Colorize 6 "  ==============( Servidor AD Destino )=============="
	echo ""
	tput cup 12 2
	Colorize 6 "Nome do domínio que deseja ingressar FQDN ex. empresa.matriz : "
	read R_FQDN
	tput cup 13 2
	Colorize 6 "IP do servidor que deseja ingressar. ex.: 192.168.253.12 : "
	read R_DOMIP
	tput cup 14 2
	Colorize 6 "Usuario Administrator do AD : "
	read R_ADMWIN
	tput cup 15 2
	Colorize 6 "Senha do Administrator do AD : "
	read R_Passwd
	
	##################################################
	##Setando o DNS do Domínio
	#
	R_DNS=$R_DOMIP
	
	##################################################
	#Ajustando FQDN para ficar minusculo
	#
	R_FQDN=$(echo $R_FQDN | tr '[:upper:]' '[:lower:]')
	
	#################################################
	#Ajustando FQDN para ficar maiusculo
	#
	C_FQDN=$(echo $R_FQDN | tr '[:lower:]' '[:upper:]') #Colocando o domínio em UpperCase
	##################################################
	#Separando apenas o Domain
	#
	R_Domain=$(echo $C_FQDN | cut -d. -f1)
	##################################################
	##Seta o Tipo de Operação
	#
	TIPO="M"
	
	##################################################
	##Conferência dos Dados
	#
	CenterTitle "Conferencia dos Dados"
	echo "
  
  Hostname:	$R_Host
  IP Local:	$R_IP
  Mascara:	$R_Mask
  Gateway:	$R_Gat
  DNS:		$R_DNS
  Dominio FQDN:	$R_FQDN	
  IP Servidor:	$R_DOMIP
  
  
  
	"
	Colorize 4 "Confirmar (s/n): "
	read R_OK
	
	if [ $R_OK = "s" ];then
		echo "Dados Confirmados, seguindo a instalação"
		echo ""
		sleep 3
		InstalaEssenciais
		sleep 3
		AjustesIniciais
		sleep 3
		tput clear
		Ajustefstab
		sleep 3
		tput clear
		configuraSMB
		sleep 3
		tput clear
		AjustaResolv
		Provisionamento
		sleep 3
		AlteraNSSwitch
		sleep 3
		PermissoesMember
		AjustaResolv
		sleep 3
		ConfigACL
		sleep 3
		tput clear
		#TestaServer
	else
		echo "Voltando para a configuração de MDC"; sleep 3 ; MDC
	fi
	
}

function PDC () {
	##################################################
	#Levantamento de dados Iniciais, exibição
	#
	CenterTitle "Configurações iniciais para o servidor PDC" 
	tput cup 5 2
	Colorize 6 "Digite o nome do servidor (hostname) ex.: servidor : "
	tput cup 6 2
	Colorize 6 "Crie uma senha forte para o usuário Administrator do Samba4 : "
	tput cup 7 2
	Colorize 6 "Por favor digite o nome do domínio FQDN ex. empresa.matriz : "
	tput cup 8 2
	Colorize 6 "Digite o endereço de IP para o servidor. ex.: 192.168.253.12 : "
	tput cup 9 2
	Colorize 6 "Escolha a Mascara de rede desejada: 1.) 255.255.0.0 ou 2.)255.255.255.0 : "
	tput cup 10 2
	Colorize 6 "Digite o Gateway da rede. ex.: 192.168.253.1 : "
	tput cup 11 2
	Colorize 6 "Qual DNS deseja: 1.) Google , 2.) OpenDNS ou 3.) Gateway : "
	##################################################
	##Captação de Dados##
	#
	tput cup 5 2
	Colorize 6 "Digite o nome do servidor (hostname) ex.: servidor : "
	read R_Host
	tput cup 6 2
	Colorize 6 "Crie uma senha forte para o usuário Administrator do Samba4 : "
	read R_Passwd
	tput cup 7 2
	Colorize 6 "Por favor digite o nome do domínio FQDN ex. empresa.matriz : "
	read R_FQDN
	##################################################
	#Ajustando FQDN para ficar minusculo
	#
	R_FQDN=$(echo $R_FQDN | tr '[:upper:]' '[:lower:]')
	##################################################
	#Ajustando FQDN para ficar maiusculo
	#
	C_FQDN=$(echo $R_FQDN | tr '[:lower:]' '[:upper:]') #Colocando o domínio em UpperCase
	##################################################
	#Separando apenas o Domain
	#
	R_Domain=$(echo $C_FQDN | cut -d. -f1)
	
	tput cup 8 2
	Colorize 6 "Digite o endereço de IP para o servidor. ex.: 192.168.253.12 : "
	read R_IP
	tput cup 9 2
	Colorize 6 "Escolha a Mascara de rede desejada: 1.) 255.255.0.0 ou 2.)255.255.255.0 : "
	read R_Mask
	if [ $R_Mask = 1 ];then
		R_Mask=255.255.0.0
		varRecorte=$(echo $R_IP | cut -d. -f3,4)
		R_Broad=$(echo $R_IP | sed -n "s/$varRecorte$/255.255/p")
		R_Network=$(echo $R_IP | sed -n "s/$varRecorte$/0.0/p")
	else
		R_Mask=255.255.255.0
		varRecorte=$(echo $R_IP | cut -d. -f4)
		R_Broad=$(echo $R_IP | sed -n "s/$varRecorte$/255/p")
		R_Network=$(echo $R_IP | sed -n "s/$varRecorte$/0/p")
	fi
	tput cup 10 2
	Colorize 6 "Digite o Gateway da rede. ex.: 192.168.253.1 : "
	read R_Gat
	tput cup 11 2
	Colorize 6 "Qual DNS deseja: 1.) Google , 2.) OpenDNS ou 3.) Gateway : "
	read R_DNS
	if [ $R_DNS = 1 ];then
		R_DNS=8.8.8.8
	elif [ $R_DNS = 2 ];then
		R_DNS=208.67.222.222
	elif [ $R_DNS = 3 ];then
		R_DNS=$R_Gat
	else
		tput 13 2
		Colorize 1 "Opção DNS digitada inexistente, usarei o Gateway"
		R_DNS=$R_Gat
	fi
	##################################################
	##Seta Variável DOMIP para configuração do Interfaces
	#
	R_DOMIP=$R_IP
	##################################################
	##Seta o Tipo de Operação
	#
	TIPO="P"
	##################################################
	##Conferência dos Dados
	#
	CenterTitle "Conferencia dos Dados"
	echo "
	Installation Directory:            /opt/samba/
	AD DC Hostname:                    $R_Host
	AD DNS Domain Name:                $R_FQDN
	Kerberos Realm:                    $C_FQDN
	NT4 Domain Name/NetBIOS Name:      $R_Domain
	IP Address:                        $R_IP
	Server Role:                       Domain Controller (DC)
	Domain Admin Password:             $R_Passwd
	Forwarder DNS Server:              $R_DNS
	"
	Colorize 4 "Confirmar (s/n): "
	read R_OK
	
	if [ $R_OK = "s" ];then
		echo "Dados Confirmados, seguindo a instalação"
		echo ""
		sleep 3
		InstalaEssenciais
		sleep 3
		AjustesIniciais
		/etc/init.d/networking restart
		sleep 3
		tput clear
		Ajustefstab
		sleep 5
		AjustaResolv
		sleep 3
		tput clear
		Provisionamento
		sleep 3
		echo "exibindo o Resolv Pela ultima Vez"
		cat /etc/resolv.conf
		sleep 5
		AjustaResolv
		IniciaSamba
		sleep 3
		tput clear
		TestaServer
		Colorize 1 "Configurações prontas reiniciando o computador em 30 segundos"
		sleep 30
		reboot
	else
		echo "Voltando para a configuração de PDC"; sleep 3 ; PDC
	fi
	
}

function BDC () {
	##################################################
	#Levantamento de dados Iniciais, exibição
	#
	CenterTitle "Configurações iniciais para o BDC" 
	tput cup 5 2
	Colorize 6 "Digite o nome deste servidor (hostname) ex.: servidor : "
	tput cup 6 2
	Colorize 6 "Digite o endereço de IP deste servidor. ex.: 192.168.253.1 : "
	tput cup 7 2
	Colorize 6 "Escolha a Mascara de rede: 1.) 255.255.0.0 ou 2.)255.255.255.0 : "
	tput cup 8 2
	Colorize 6 "Digite o Gateway da rede. ex.: 192.168.253.1 : "
	##################################################
	#Dados do servidor AD
	#
	tput cup 9 2
	echo ""
	Colorize 6 "  ==============( Servidor AD Principal )=============="
	echo ""
	tput cup 12 2
	Colorize 6 "Nome do domínio que deseja ingressar FQDN ex. empresa.matriz : "
	tput cup 13 2
	Colorize 6 "IP do servidor que deseja ingressar. ex.: 192.168.253.12 : "
	tput cup 14 2
	Colorize 6 "Senha do Administrator do AD : "
	
	
	##################################################
	##Captação de Dados##
	#
	tput cup 5 2
	Colorize 6 "Digite o nome deste servidor (hostname) ex.: servidor : "
	read R_Host
	tput cup 6 2
	Colorize 6 "Digite o endereço de IP deste servidor. ex.: 192.168.253.1 : "
	read R_IP
	tput cup 7 2
	Colorize 6 "Escolha a Mascara de rede: 1.) 255.255.0.0 ou 2.)255.255.255.0 : "
	read R_Mask
	if [ $R_Mask = 1 ];then
		R_Mask=255.255.0.0
		varRecorte=$(echo $R_IP | cut -d. -f3,4)
		R_Broad=$(echo $R_IP | sed -n "s/$varRecorte$/255.255/p")
		R_Network=$(echo $R_IP | sed -n "s/$varRecorte$/0.0/p")
	else
		R_Mask=255.255.255.0
		varRecorte=$(echo $R_IP | cut -d. -f4)
		R_Broad=$(echo $R_IP | sed -n "s/$varRecorte$/255/p")
		R_Network=$(echo $R_IP | sed -n "s/$varRecorte$/0/p")
	fi
	tput cup 8 2
	Colorize 6 "Digite o Gateway da rede. ex.: 192.168.253.1 : "
	read R_Gat
	##################################################
	#Dados do servidor AD
	#
	tput cup 9 2
	echo ""
	Colorize 6 "  ==============( Servidor AD Principal )=============="
	echo ""
	tput cup 12 2
	Colorize 6 "Nome do domínio que deseja ingressar FQDN ex. empresa.matriz : "
	read R_FQDN
	tput cup 13 2
	Colorize 6 "IP do servidor que deseja ingressar. ex.: 192.168.253.12 : "
	read R_DOMIP
	tput cup 14 2
	Colorize 6 "Senha do Administrator do AD : "
	read R_Passwd
	
	##################################################
	##Setando o DNS do Domínio
	#
	R_DNS=$R_DOMIP
	
	##################################################
	#Ajustando FQDN para ficar minusculo
	#
	R_FQDN=$(echo $R_FQDN | tr '[:upper:]' '[:lower:]')
	
	#################################################
	#Ajustando FQDN para ficar maiusculo
	#
	C_FQDN=$(echo $R_FQDN | tr '[:lower:]' '[:upper:]') #Colocando o domínio em UpperCase
	##################################################
	#Separando apenas o Domain
	#
	R_Domain=$(echo $C_FQDN | cut -d. -f1)
	##################################################
	##Seta o Tipo de Operação
	#
	TIPO="B"
	
	##################################################
	##Conferência dos Dados
	#
	CenterTitle "Conferencia dos Dados"
	echo "
  
  Hostname:	$R_Host
  IP Local:	$R_IP
  Mascara:	$R_Mask
  Gateway:	$R_Gat
  DNS:		$R_DNS
  Dominio FQDN:	$R_FQDN	
  IP Servidor:	$R_DOMIP
  
  
  
	"
	Colorize 4 "Confirmar (s/n): "
	read R_OK
	
	if [ $R_OK = "s" ];then
		echo "Dados Confirmados, seguindo a instalação"
		echo ""
		sleep 3
		InstalaEssenciais
		sleep 3
		AjustesIniciais
		sleep 3
		tput clear
		Ajustefstab
		sleep 3
		tput clear
		echo 'exibindo Resolv antes de provisionar'
		cat /etc/resolv.conf
		sleep 5
		AjustaResolv
		echo 'exibindo Resolv antes de provisionar'
		cat /etc/resolv.conf
		sleep 3
		#read -p "   Pressione [Enter] Para continuar"
		sleep 3
		Provisionamento
		sleep 3
		echo "exibindo o Resolv Pela ultima Vez"
		cat /etc/resolv.conf
		#read -p "   Pressione [Enter] Para continuar"
		sleep 5
		AjustaResolv
		sleep 3
		tput clear
		configuraSMB
		sleep 3
		IniciaSamba
		AlteraNSSwitch
		sleep 3
		#PermissoesMember
		sleep 3
		#ConfigACL
		sleep 3
		tput clear
		TestaServer
		Colorize 1 "Configurações prontas reiniciando o computador em 30 segundos"
		sleep 30
		reboot
	else
		echo "Voltando para a configuração de MDC"; sleep 3 ; MDC
	fi
	
}

function AjustaResolv () {
	echo ""
	Colorize 2 "Ajustando o resolv.conf"
	echo ""
	sleep 2
	echo "domain $R_FQDN" > /etc/resolv.conf
	echo "search $R_FQDN" >> /etc/resolv.conf
	echo "nameserver $R_DOMIP" >> /etc/resolv.conf
	echo "nameserver 127.0.0.1" >> /etc/resolv.conf
}

function AjustaHosts () {
	Colorize 2 "Ajustes no hosts"
	echo ""
	sleep 2
	#sed -i "s/$HOSTNAME/$R_Host/;s/localhost$/&\n127.0.0.1\t$R_Host.$R_FQDN\t$R_Host\n$R_IP\t$R_Host.$R_FQDN\t$R_Host/" /etc/hosts
	sed -i "s/$HOSTNAME/$R_Host/;s/localhost$/&\n$R_IP\t$R_Host.$R_FQDN\t$R_Host/" /etc/hosts
}

function ConfiguraMake () {
	cd /root/samba-4.3.0/
	sleep 2
	if [ $TIPO = "P" ]; then
			Colorize 2 "Inicinado configuração de Samba PDC"
			echo ""
			sleep 3
			./configure --prefix=/opt/samba --enable-debug --enable-selftest
	elif [ $TIPO = "M" ]; then
			Colorize 2 "Inicinado configuração de Samba MDC"
			echo ""
			sleep 3
			./configure --prefix=/opt/samba --with-ads --with-shared-modules=idmap_ad --enable-debug --enable-selftest
	elif [ $TIPO = "B" ]; then
			Colorize 2 "Inicinado configuração de Samba BDC"
			echo ""
			sleep 3
			./configure --prefix=/opt/samba --enable-debug --enable-selftest
	fi
	
	Colorize 2 "Iniciarei o processo mais lento de toda a instalação, vamos montar os pacotes"
	echo ""
	sleep 3
	make
	make install
	sleep 3
	Colorize 2 "Ajustes no krb5.conf"
	echo ""
	sleep 2
	cp /etc/krb5.conf /etc/krb5.conf.ORIGINAL
	rm /etc/krb5.conf
	cp /opt/samba/share/setup/krb5.conf /etc/
	sed -i "s/\${REALM}/$C_FQDN/;s/true/&\n\n[realms]\n\t$C_FQDN = {\n\tkdc = $R_DOMIP\n\tadmin_server = $R_DOMIP\n}/" /etc/krb5.conf
	Colorize 2 "Seu sistema está pronto para ser provisionado"
	echo ""
	sleep 4
}

function AlteraInterfaces () {
	Colorize 2 "Alterando o arquivo interfaces"
	echo ""
	sleep 2
	sed -i "s/iface eth0/auto eth0\n&/ ; s/dhcp/static\n\taddress $R_IP\n\tnetmask $R_Mask\n\tgateway $R_Gat\n\tnetwork $R_Network\n\tbroadcast $R_Broad\n\tdns-nameserver $R_DOMIP\n\tdns-search $R_FQDN/" /etc/network/interfaces
	Colorize 2 "Reiniciando o dispositivo de Rede Eth0"
	echo ""
	sleep 2
	/etc/init.d/networking restart
}

function AjustesIniciais(){ 
	#Chama Função para alteração do dispositivo de rede para ip fixo
	#
	if [ $TIPO = "P" ];then
		AlteraInterfaces
		
		Colorize 2 "Alterando o arquivo hostname (o nome da maquina)"
		echo ""
		sleep 2
		echo $R_Host > /etc/hostname
		sleep 2
		hostname $R_Host #Seta o nome da maquina sem reiniciar	
		#Chama Função para ajuste do resolv.conf
		#
		AjustaResolv
		#Chama Função para ajuste do hosts
		#
		AjustaHosts
		
		Colorize 2 "Inclusão dos dados no profile"
		echo ""
		sleep 2
		echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/samba/bin:/opt/samba/sbin"' >> /etc/profile
		sleep 3
		export PATH=$PATH:/opt/samba/bin:/opt/samba/sbin
		Colorize 2 "Ajustes no RSSH, alteração da porta para 3851"
		echo ""
		sleep 2
		sed -i "s/^Port 22/Port 3851/;s/^PermitRootLogin/#&/" /etc/ssh/sshd_config
		/etc/init.d/ssh restart
		
		
		Colorize 2 "Ajustes no Limits.conf"
		echo ""
		sleep 2
		echo	"root hard nofile 131072" >> /etc/security/limits.conf
		echo	"root soft nofile 65536" >> /etc/security/limits.conf
		echo 	"mioutente hard nofile 32768" >> /etc/security/limits.conf
		echo 	"mioutente soft nofile 16384" >> /etc/security/limits.conf
		Colorize 2 "preparando a configuração inicial do samba4"
		echo ""
		sleep 2
		#Chama Função para Configuracao dos Pacotes
		ConfiguraMake
	elif [ $TIPO = "M" ];then
		AlteraInterfaces
		
		Colorize 2 "Alterando o arquivo hostname (o nome da maquina)"
		echo ""
		sleep 2
		echo $R_Host > /etc/hostname
		sleep 2
		hostname $R_Host #Seta o nome da maquina sem reiniciar	
		#Chama Função para ajuste do resolv.conf
		#
		AjustaResolv
		#Chama Função para ajuste do hosts
		#
		AjustaHosts
		
		Colorize 2 "Inclusão dos dados no profile"
		echo ""
		sleep 2
		echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/samba/bin:/opt/samba/sbin"' >> /etc/profile
		sleep 3
		export PATH=$PATH:/opt/samba/bin:/opt/samba/sbin
		Colorize 2 "Ajustes no RSSH, alteração da porta para 3851"
		echo ""
		sleep 2
		sed -i "s/^Port 22/Port 3851/;s/^PermitRootLogin/#&/" /etc/ssh/sshd_config
		/etc/init.d/ssh restart
		#Chama Função para Configuracao dos Pacotes
		ConfiguraMake
		
	elif [ $TIPO = "B" ];then
		AlteraInterfaces
		
		Colorize 2 "Alterando o arquivo hostname (o nome da maquina)"
		echo ""
		sleep 2
		echo $R_Host > /etc/hostname
		sleep 2
		hostname $R_Host #Seta o nome da maquina sem reiniciar	
		#Chama Função para ajuste do resolv.conf
		#
		AjustaResolv
		#Chama Função para ajuste do hosts
		#
		AjustaHosts
		
		Colorize 2 "Inclusão dos dados no profile"
		echo ""
		sleep 2
		echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/samba/bin:/opt/samba/sbin"' >> /etc/profile
		sleep 3
		export PATH=$PATH:/opt/samba/bin:/opt/samba/sbin
		Colorize 2 "Ajustes no RSSH, alteração da porta para 3851"
		echo ""
		sleep 2
		sed -i "s/^Port 22/Port 3851/;s/^PermitRootLogin/#&/" /etc/ssh/sshd_config
		/etc/init.d/ssh restart
		
		
		Colorize 2 "Ajustes no Limits.conf"
		echo ""
		sleep 2
		echo	"root hard nofile 131072" >> /etc/security/limits.conf
		echo	"root soft nofile 65536" >> /etc/security/limits.conf
		echo 	"mioutente hard nofile 32768" >> /etc/security/limits.conf
		echo 	"mioutente soft nofile 16384" >> /etc/security/limits.conf
		Colorize 2 "preparando a configuração inicial do samba4"
		echo ""
		sleep 2
		#Chama Função para Configuracao dos Pacotes
		ConfiguraMake
	fi

}

function CriaSmb () {
	#R_Host="serverteste"
	#C_FQDN="ENGEFORM.MATRIZ"
	#R_Grupo=$(echo $C_FQDN | cut -d. -f1)
	echo "
[global]
  netbios name = $R_Host
  workgroup = $R_Domain
  security = ADS
  realm = $C_FQDN
  dedicated keytab file = /etc/krb5.keytab
  kerberos method = secrets and keytab
  username map = /opt/samba/user.map
  idmap config *:backend = tdb
  idmap config *:range = 70001-1999999
  idmap config $R_Domain:backend = rid
  idmap config $R_Domain:schema_mode = rfc2307
  idmap config $R_Domain:range = 100-4000000
  winbind nss info = rfc2307
  winbind trusted domains only = no
  winbind use default domain = yes
  winbind enum users  = yes
  winbind enum groups = yes
  winbind refresh tickets = Yes
  winbind cache time = 40
"	> /opt/samba/etc/smb.conf        
#[kit]
  #path = /kit
  #read only = no
  #admin users = @'"'$R_Domain\Domain Admins'"'
}

function IniciaSamba () {
	if [ $TIPO = "M" ]; then
		tput clear
		Colorize 2 "Subindo Serviço do winbind"
		echo ""
		sleep 2
		killall winbind
		/opt/samba/sbin/winbindd
		Colorize 2 "Subindo Serviço do nmbd"
		echo ""
		sleep 2
		killall nmbd
		/opt/samba/sbin/nmbd
		Colorize 2 "Subindo Serviço do smbd"
		echo ""
		sleep 2
		killall smbd
		/opt/samba/sbin/smbd
		Colorize 2 "Incluindo inicializacao automatica"
		echo ""
		sleep 4
		sed -i "s_^exit 0_/opt/samba/sbin/winbindd\n/opt/samba/sbin/nmbd\n/opt/samba/sbin/smbd\n\n&_" /etc/rc.local
		
	elif [ $TIPO = "P" ] || [ $TIPO = "B" ]; then
		tput clear
		Colorize 2 "Subindo Serviço do Samba"
		echo ""
		sleep 2
		/opt/samba/sbin/samba
		sleep 4
		Colorize 2 "Verificando se o serviço está em pé"
		echo ""
		ps -aux | grep samba
		sleep 4
		tput clear
		Colorize 2 "Incluindo inicializacao automatica"
		echo ""
		sleep 4
		sed -i "s_^exit 0_/opt/samba/sbin/samba\n\n&_" /etc/rc.local
	fi
	
	
}

function PermissoesMember () {
	tput clear
	Colorize 2 "Preparando pré requisitos para permissionamento de arquivos"
	echo ""
	sleep 2
	echo "!root = $R_Domain\Administrator $R_Domain\administrator" > /opt/samba/user.map
	##################################################
	##Reinicia Serviços
	#
	IniciaSamba
	Colorize 2 "Dando privilégios totais ao computador membro para o administrador do Domínio"
	echo ""
	sleep 2
	echo $R_Passwd | net rpc rights grant '$R_Domain\Domain Admins' SeDiskOperatorPrivilege -U '$R_Domain\administrator' -I $R_FQDN
}

function AlteraNSSwitch () {
	tput clear
	Colorize 2 "Realizando Alterações no nsswith.conf"
	echo ""
	sleep 2
	sed -i "s/passwd:.*/passwd:\t\tcompat winbind/;s/group:.*/group:\t\tcompat winbind/;s/networks:.*/networks:\tfiles dns/" /etc/nsswitch.conf
	tput clear
	Colorize 2 "Criando links para funcionamento no samba"
	echo ""
	sleep 2
	ln -s /opt/samba/lib/libnss_winbind.so /usr/lib/x86_64-linux-gnu/
	ln -s /usr/lib/x86_64-linux-gnu/libnss_winbind.so /usr/lib/x86_64-linux-gnu/libnss_winbind.so.2
	ldconfig
	net cache flush
}

function configuraSMB(){
	#Pre requisitos para funcionar corretamente é criar um /dados para os arquivos, e a pasta kit para os log e lixeira
	#Gostaria de criar antes uma conexao vpn com a kingit, deixando a instalação interligada com o laboratório.
	#Pastas necessárias
	#
	Colorize 2 "  Criando estrutura de pastas seguindo o padrão Kingit"
	echo "
	
	Do que estamos falando?
	As pastas de lixeira, logs, atalhos padrões e pastas de atalhos
	agora estão separadas dos dados dos clientes
	/kit/lixeira
	/kit/pastas
	/kit/log
	/kit/atalhos_padroes
	
	A Pasta de Dados conterá apenas os dados dos clientes
	
	/dados/
	
	"
	if [ $TIPO = "M" ]; then
		CriaSmb
		tput clear
		Colorize 2 "Inclusão da base de configuracao do smb.conf na configuracao basica"
		echo ""
		sleep 3
		sed -i "25r /root/smbauditrecycle" /opt/samba/etc/smb.conf
		sleep 15
		
	elif [ $TIPO = "B" ]; then
		tput clear
		Colorize 2 "Inclusão da base de configuracao do smb.conf na configuracao basica"
		echo ""
		sleep 3
		sed -i "10r /root/smbauditrecycle" /opt/samba/etc/smb.conf
		#sed -i "25r /root/smbauditrecycle" /opt/samba/etc/smb.conf
		sleep 15
	fi
	
	sleep 15
	mkdir -p /kit
	mkdir -p /kit/lixeira
	mkdir -p /kit/pastas
	mkdir -p /kit/log
	mkdir -p /kit/atalhos_padroes
	mkdir -p /dados/
	
	#LOG do samba
	Colorize 2 "Incluindo instruções para salvar o log de acessos"
	echo ""
	sleep 2
	echo "local3.notice /kit/log/samba-full_audit.log" >> /etc/rsyslog.conf
	sleep 3
	
}

function ConfigACL () {
	setfacl -m d:g:"domain admins":rwx /kit
	setfacl -m d:g:"domain admins":rwx /dados
}

function TestaServer(){
	
	#Colorize 2 "Exibindo Configurações Locais: resolv.conf"
	#echo ""
	#cat /etc/resolv.conf
	#sleep 7
	#AjustaResolv
	#cat /etc/resolv.conf
	#sleep 7
	Colorize 2 "Verificando se o Samba está ligado"
	echo ""
	ps -aux | grep samba
	sleep 3
	Colorize 2 "Efetuando teste NSLOOKUP"
	echo ""
	sleep 3
	nslookup $R_FQDN
	Colorize 2 "Logando na seção como Administrator. "
	echo ""
	sleep 3
	echo $R_Passwd | kinit administrator@$C_FQDN
	Colorize 2 "Exibe o Ticket Recem Criado"
	echo ""
	sleep 3
	klist
	sleep 3
	Colorize 2 "Mostrando compartilhamentos"
	echo ""
	smbclient -L //$R_Host.$R_FQDN -U%
	sleep 3
	Colorize 2 "Listando o conteudo da pasta netlogon de rede"
	echo ""
	sleep 3
	smbclient -k //$R_Host.$R_FQDN/netlogon -c 'ls'
	Colorize 2 "Testando DNS"
	echo ""
	sleep 3
	host -t SRV _ldap._tcp.$R_FQDN
	host -t SRV _kerberos._udp.$R_FQDN
	host -t A $R_Host.$R_FQDN
	sleep 10
	
	CenterTitle "Seu sistema foi instalado e configurado corretamente"
	echo "
  
  Hostname:	$R_Host
  Senha:	$R_Passwd
  Dominio FQDN:	$R_FQDN	
  IP Servidor:	$R_IP
  Mascara:	$R_Mask
  Gateway:	$R_Gat
  DNS:		$R_DNS
	"
}

function CriaCompartilhamento() {
	##################################################
	#Levantamento de dados Iniciais, exibição
	#
	CenterTitle "Configuração de Compartilhamento" 
	tput cup 5 2
	Colorize 1 "
	Importante lembrar que para que o sistema funcione corretamente
	todos os compartilhamentos devem ter um grupo com o mesmo nome.
	Caso você deseje que este compartilhamento seja disponibilizado
	automaticamente	para os usuários, não se esqueça de:
	- Dar as permissões para o grupo na pasta criada,
	- Criar o atalho dentro da pasta atalhos padrões 
	- Criar a GPO com permissão para o grupo.
	
	"
	Colorize 6 "Digite o nome do compartilhamento que deseja : "
		
	##################################################
	##Captação de Dados##
	#
	tput cup 5 2
	Colorize 1 "
	Importante lembrar que para que o sistema funcione corretamente
	todos os compartilhamentos devem ter um grupo com o mesmo nome.
	Caso você deseje que este compartilhamento seja disponibilizado
	automaticamente	para os usuários, não se esqueça de:
	- Dar as permissões para o grupo na pasta criada,
	- Criar o atalho dentro da pasta atalhos padrões 
	- Criar a GPO com permissão para o grupo.
	
	"
	Colorize 6 "Digite o nome do compartilhamento que deseja : "
	read R_Compart
	##################################################
	##Seta o Tipo de Operação
	#
	TIPO="C"
	
	CenterTitle "Conferencia dos Dados"
	echo "
  
  Pasta Local:	/dados/$R_Compart
 
	"
	Colorize 4 "Confirmar (s/n): "
	read R_OK
	
	if [ $R_OK = "s" ];then
		Colorize 6 "Criando as pastas e o compartilhamento $R_Compart"
		sleep 3
		mkdir -p /dados/$R_Compart
	echo "
[$R_Compart]
	path = /dados/$R_Compart
	read only = No
	Browseable = Yes" >> /opt/samba/etc/smb.conf
		echo ""
		Colorize 6 "Compartilhamento Criado com sucesso"
		echo ""
	fi
	
}

function menuPrincipal () {
	CenterTitle "Samba 4 Deploy"
	tput cup 5 2
	Colorize 4 "O que deseja fazer?"
	echo "
  1. Criar um novo servidor autonomo PDC (Primary Domain Controller).
  2. Criar um BDC FileServer de um servidor Samba 4 existente. 
  3. File Server MEMBRO de um AD Samba ou Windows Existente
  4. Incluir novo HD no Servidor Samba4.
  5. Criar Compartilhamento em FileServer
  9. Sair
  
  Qual a sua escolha:"
	tput cup 13 21
	read R_Mnu
	
	case $R_Mnu in
		1) PDC ;;
		2) BDC ;;
		3) MDC ;;
		4) Colorize 5 "  Funcionalidade ainda em desenvolvimento. Voltando ao Menu Principal" ; sleep 3 ; menuPrincipal ;;
		5) Colorize 5 "  Funcionalidade atrelada do home.sh. Voltando ao Menu Principal" ; sleep 3 ; menuPrincipal ;; #CriaCompartilhamento ;;
		9) echo "  Valew Falow" ; exit;;
		*) echo "  Por favor escolha uma opção valida. Voltando para o Menu Principal."; sleep 3 ; menuPrincipal ;;
	esac
}

menuPrincipal

if [ $TIPO = "M" ] || [ $TIPO = "B" ]; then
	rm /root/smbauditrecycle
	rm -R /root/samba-4.3.0/
fi
