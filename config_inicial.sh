colocar ficheiros em /BOOT
 ssh (ficheiro em branco com este nome)
 wpa_supplicant.conf
 
Conteudo de wpa_supplicant.conf

update_config=1
ctrl_interface=/var/run/wpa_supplicant

network={
 scan_ssid=1
 ssid="nome da rede"
 psk="pass"
}

1º boot
aceder por SSH

Configurar IP Fixo:
modify the file /etc/dhcpcd.conf


######################################################
# TEMPLATE: A different IP address on each network
#
#           The arping address should be the router
#           or some other machine guaranteed to be
#           available. You need to know the addresses
#           of the servers. If none of the arpings find
#           an active machine then you will get a DHCP
#           allocation.
######################################################
interface wlan0
arping 192.168.1.1
# arping xxx.xxx.x.xxx #colocar o IP de outros routers possiveis

profile 192.168.1.1
static ip_address=192.168.1.xxx/24 #o IP escolhido
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 

profile 192.168.0.254
static ip_address=192.168.0.44/24
static routers=192.168.0.254
static domain_name_servers=192.168.0.254

 
RUNNING UPDATE AND UPGRADE
This one's easy, we'll just call:

sudo apt-get update 
sudo apt-get upgrade -y





--------------------
exemplo para instalação de aplicações específicas:

PACKAGES="python-picamera graphicsmagick python-pip"
apt-get install $PACKAGES -y

-------------------------

sudo raspi-config 
Select Hostname, then change the name from raspberrypi to something

mudar LOCALE e timezone no menu
Mudar distribuição da memória / expand filesystem

Mudar password
	passwd
	
Adicionar novo utilizador
	sudo adduser xxxxxx
	sudo passwd xxxxx #mudar a password do novo user
	(que será criado em /home/xxxxxx/
	
Adicionar utilizador XXXXXX com permissões SUDO
	sudo visudo (fazer scroll e duplicar linha root com novo username)
	
Remover user pi (pode não ser boa ideia) - e só depois de estar logado com outro user
	sudo deluser pi (ou sudo deluser --remove-all-files pi)
	ou então
	sudo passwd --lock pi
	sudo passwd -l root (será que funciona? para lockar a conta root?)
	

Remove the pi user from the sudo group:

	sudo deluser pi sudo
	
Comment out the pi user from the sudoers configuration file:

	sudo sed -ri -e 's/pi ALL=(ALL) NOPASSWD: ALL/# pi ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers.d/010_pi-nopasswd




	
Criar novo user com as mesmas permissões do user pi
	groups pi
resultado: pi: aaa vvv ccc
	# ?funciona? sudo useradd -m -G aaa,vvv,ccc NOVOUSER (ou sudo usermod <newusername> -a -G aaa,vvv,ccc
	sudo passwd NOVOUSER group #1 a 1
	
	

Fazer com que sudo necessite de password
	sudo nano /etc/sudoers.d/010_pi-nopasswd
	
	mudar pi ALL=(ALL) PASSWD: ALL (substituir pi pelo user que quisermos mudar)
	
Mudar que users podem aceder via ssh
	sudo nano /etc/ssh/sshd_config
	* adicionar no final deste ficheiro:
	AllowUsers xxxxx aaaaa cccccc nnnnnn
	* impedir acesso root via ssh (o acesso pode depois ser obtido por sudo)
	PermitRootLogin no


	* depois de alterar é necessário reiniciar o sshd
	sudo systemctl restart ssh
	
	
Edit /etc/ssh/sshd_config to include:
	# allow root access only with ssh keys
	# unless needed, disable completely with 'no'
	PermitRootLogin without-password

	# permit password from rfc1918 local addresses
	# edit to match your local network
	Match Address 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,169.254.0.0/16
	PasswordAuthentication yes
	# global option no password auth (keys only)
	PasswordAuthentication no

Change the IP range specified in the Match Address line to match your network(s).
reiniciar ssh
	sudo systemctl restart ssh		
----------------------------------------------

Update do raspberry 
	sudo apt-get update
	sudo apt-get dist-upgrade -y

Eventualmente em cron job semanal - limpar pacotes deb guardados em /var/cache/apt/archives
	sudo apt-get clean
	
Cron job diário para fazer o update
---------------
Cron
		crontab -e (a primeira vez vai pedir para indicar qual o editor - nano)
		
		# m h  dom mon dow   command
		# * * * * *  command to execute
		# ┬ ┬ ┬ ┬ ┬
		# │ │ │ │ │
		# │ │ │ │ │
		# │ │ │ │ └───── day of week (0 - 7) (0 to 6 are Sunday to Saturday, or use names; 7 is Sunday, the same as 0)
		# │ │ │ └────────── month (1 - 12)
		# │ │ └─────────────── day of month (1 - 31)
		# │ └──────────────────── hour (0 - 23)
		# └───────────────────────── min (0 - 59)

para ver tarefas
	crontab -l
	
	
	0 1 * * * /usr/bin/apt-get update
	0 10 * * * /usr/bin/apt-get upgrade -y

------------------------
Firewall (exemplo)
install ufw which is a software firewall

$ sudo apt-get install ufw

set up

$ sudo ufw status
Status: active

basic concept is that deny all packets, then allows some pakets that I need (like ssh)
$ sudo ufw default DENY
$ sudo ufw allow ssh
$ sudo ufw allow 80 (if allows users to access pi via web browsers)

delete rule
$ sudo ufw delete allow 22

set limitation to make pi more secure
$ sudo ufw limit ssh

set log function
$ sudo ufw logging low

enable ufw
$ sudo ufw enable



------------------------
Fail2ban

sudo apt install fail2ban

aceder a /etc/fail2ban
copiar jail.conf para jail.local
	sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
	sudo nano /etc/fail2ban/jail.local
alterar a secção ssh
	[ssh]
	enabled  = true
	port     = ssh
	filter   = sshd (#diz respeito ao ficheiro /etc/fail2ban/filters.d/sshd.conf)
	logpath  = /var/log/auth.log
	maxretry = 6
	
	
---------------------------
Remove Unused Network-Facing Services
Determine Running Services
	sudo ss -atpu
	
------------------------------
link sobre o uso de fail2ban e ifft
https://domoticproject.com/raspberry-pi-security/

--------------------------
Install unattended-upgrades to automatically install security upgrades as they are released.

-------------------------------



/boot/config.txt - modificar gpu-mem para 16

# If a line containing "gpu_mem" exists
if grep -Fq "gpu_mem" $CONFIG
then
	# Replace the line
	echo "Modifying gpu_mem"
	sed -i "/gpu_mem/c\gpu_mem=16" $CONFIG
else
	# Create the definition
	echo "gpu_mem not defined. Creating definition"
	echo "gpu_mem=16" >> $CONFIG
fi

----------------------------------
Serviço timesyncd

Edit  /etc/systemd/timesyncd.conf , especially the second line

[Time]
NTP=0.pt.pool.ntp.org
FallbackNTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
#RootDistanceMaxSec=5
#PollIntervalMinSec=32
#PollIntervalMaxSec=2048

------------------------------------------

Debian and Ubuntu users can install the latest stable version of InfluxDB using the apt-get package manager.

curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/os-release
test $VERSION_ID = "7" && echo "deb https://repos.influxdata.com/debian wheezy stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
test $VERSION_ID = "8" && echo "deb https://repos.influxdata.com/debian jessie stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
test $VERSION_ID = "9" && echo "deb https://repos.influxdata.com/debian stretch stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

Then, install and start the InfluxDB service:

sudo apt-get update && sudo apt-get install influxdb
sudo service influxdb start
Or if your operating system is using systemd (Ubuntu 15.04+, Debian 8+):

sudo apt-get update && sudo apt-get install influxdb
sudo systemctl unmask influxdb.service
sudo systemctl start influxdb
