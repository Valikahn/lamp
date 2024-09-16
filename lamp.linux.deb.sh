#!/bin/bash
clear
export EDITOR=nano

###--------------------  START OF LAMP SCRIPT  --------------------###
##


#######################################################################################################################################################
#######################################################################################################################################################
##																																					 ##
##  LAMP (Linux, Apache, MySQL and PHP)                                                                                                              ##
##  Apache SSL, phpMyAdmin, Webmin and VSFTPD inc FTP SSL                                                                                            ##
##  Managing a Web Server (maws_h16s35)                                                                                                              ##
##																																					 ##
##  Author:  Neil Jamison <000705@uhi.ac.uk>	                        																	         ##
##																																					 ##
##  This bash scrip has been fully tested to work on Ubuntu 24.04 and has been developed to be fully automated once started.                         ##
##  This includes the installation and configuration of Apache, phpMyAdmin, Webmin, and FTP/VSFTPD.                                                  ##
##  This will also need install, configure, and install an SSL cert for HTTPS and FTP                                                                ##
##																																					 ##
#######################################################################################################################################################
#######################################################################################################################################################
##																																					 ##
##  Licensed under the GPLv3 License.																												 ##
##  GPLv3 Licence:  https://www.gnu.org/licenses/gpl-3.0.en.html																					 ##
##																																					 ##
##  This program is free software: 	You can redistribute it and/or modify it under the terms of the GNU General Public License as published by		 ##
##	 							    	the Free Software Foundation, either version 3 of the License, or (at your option) any later version.		 ##
##																																					 ##
#######################################################################################################################################################
#######################################################################################################################################################


###################################################
##												 ##
##  VARIABLES									 ##
##												 ##
###################################################


###--------------------  COLORS DECLARE  --------------------###
##
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)
LBLUE=$(tput setaf 6)
RED=$(tput setaf 1)
PURPLE=$(tput setaf 5)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

###--------------------  VERSIONING --------------------###
##
SCRIPTVERSION="v24.9.16"
BUILD="155"
REVDATE="16 September 2024"
FILENAME="maws_h16s35-$SCRIPTVERSION.$BUILD.linux.deb.sh"

###--------------------  HOST DATA COLLECTION  --------------------###
##
ENS=`nmcli dev status | grep '^ens' | awk '{ print $1 }'`
DOM=`nmcli dev status | grep '^ens' | awk '{ print $4 }'`
LIP=`nmcli -f ipv4.addresses con show $DOM | awk '{ print $2 }'`
DNS=`nmcli -f ipv4.dns con show $DOM | awk '{ print $2 }'`
HST=$(hostname)
IP_ADDRESS=$(ip addr show $ENS | grep -oP 'inet \K[\d.]+')
PRO_STATUS=$(pro status --format json)
USER_NAME=$(w -h | awk '{print $1}' | head -n 1)


###################################################
##												 ##
##  FUNCTIONS									 ##
##												 ##
###################################################


###--------------------  SUDO/ROOT CHECK  --------------------###
##
SUDO_CHECK() {
if [ "$(id -u)" -ne 0 ]; then 
	echo -n "Checking if user is root/sudo..."; 	sleep 5
	echo -e "\rChecking if user is root/sudo... ${RED}[  ACCESS DENIED  ]${NORMAL}"; sleep 3
	echo
	echo "Error 126: Command cannot execute."
	echo "This error code is used when a command is found but is not executable.  Execute as root/sudo!"
	exit 126
else
	echo -n "Checking if user is root/sudo..."; 	sleep 5
	echo -e "\rChecking if user is root/sudo... ${GREEN}[  ACCESS GRANTED  ]${NORMAL}"; sleep 3
    clear
fi
}

###--------------------  RANDOM PASSWORD GENERATOR  --------------------###
##
PASSGEN() {
local genln=$1
[ -z "$genln" ] && genln=12
tr -dc A-Za-z0-9 < /dev/urandom | head -c ${genln} | xargs
}

###--------------------  IS PORT IN USE  --------------------###
##
IS_PORT_IN_USE() {
  sudo lsof -i -P -n | grep LISTEN | grep ":$1 " > /dev/null
  return $?
}

###--------------------  COLLECTING SYSTEM DATA  --------------------###
##
COLLECTING_SYSTEM_DATA() {
DIST=$nil
PSUEDONAME=$nil
PSWD=$(PASSGEN)
echo -n "Collecting Host/System Data..."

## RHEL 
if [ -f "/etc/redhat-release" ]; then 
	DIST=`cat /etc/redhat-release`
	PSUEDONAME=`cat /etc/redhat-release | sed s/\ release.*// | cut -d " " -f 1`
	if [[ "$PSUEDONAME" == "Red" ]]; then
		DISTRO='RedHat'	
	elif [[ "$PSUEDONAME" == "CentOS" ]]; then
		DISTRO='CentOS'
	fi
echo -e "\rCollecting Host/System Data... ${GREEN}[  OK  ]${NORMAL}"

## DEBIAN
elif [ -f /etc/debian_version ] ; then
	DIST=`cat /etc/lsb-release | sed 's/"//g' | grep '^DISTRIB_DESCRIPTION' | awk -F=  '{ print $2 }'`
	PSUEDONAME=`cat /etc/lsb-release | sed 's/"//g' | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
	if [[ "$PSUEDONAME" == "Ubuntu" ]]; then
		DISTRO='Debian'
	fi
echo -e "\rCollecting Host/System Data... ${GREEN}[  OK  ]${NORMAL}"

else
	echo -e "\rCollecting Host/System Data... ${BOLD}${RED}[  FAIL  ]${NORMAL}"
	echo "ERROR: RHEL or DEBIAN release files could not be found! [OPERATING SYSTEM DETECTION]"
	exit 1
fi
}

###--------------------  CONFIRM_YES_NO  --------------------###
#
CONFIRM_YES_NO () {
while true;
	do
	read -p "Please confirm you're happy to proceed? (Yy/Nn): " CONFIRM
    echo
    if [[ "$CONFIRM" == "Y" ]] || [[ "$CONFIRM" == "y" ]] || [[ "$CONFIRM" == "YES" ]] || [[ "$CONFIRM" == "yes" ]] || [[ "$CONFIRM" == "Yes" ]]; then
		clear
		break
    elif [[ "$CONFIRM" == "N" ]] || [[ "$CONFIRM" == "n" ]] || [[ "$CONFIRM" == "NO" ]] || [[ "$CONFIRM" == "no" ]] || [[ "$CONFIRM" == "No" ]]; then
	    exit
    else
	    echo "Invalid choice - try again please. Enter 'Yy' or 'Nn'."
	    echo
    fi
done
}


###################################################
##												 ##
##  SCRIPT START        			   			 ## 
##												 ##
###################################################

SUDO_CHECK
COLLECTING_SYSTEM_DATA

###--------------------  OPERATING SYSTEM CONSOLE OUTPUT  --------------------###
##
sleep 2
echo
echo "###-------------------------------------------------------------------------###"
echo
echo "LAMP (Linux, Apache, MySQL and PHP)"
echo "Apache SSL, phpMyAdmin, Webmin and VSFTPD inc FTP SSL"
echo "Managing a Web Server (maws_h16s35)"
echo
echo "Author:  Neil Jamieson <000705@uhi.ac.uk>"
echo "${YELLOW}[  Credit where credits due!  This did not write itself!  ]${NORMAL}"
echo
echo "###-------------------------------------------------------------------------###"
echo
echo "Script Version: ${LBLUE}[  $SCRIPTVERSION  ]${NORMAL}"
echo "Filename: ${LBLUE}[  $FILENAME  ]${NORMAL}"
echo "Last Update: ${LBLUE}[  $REVDATE  ]${NORMAL}"
echo "Operating System: ${LBLUE}[  $DIST  ]${NORMAL}"
echo "IP Address: ${LBLUE}[  $IP_ADDRESS  ]${NORMAL}"
echo "Hostname: ${LBLUE}[  $HST  ]${NORMAL}"
echo "Logged-in user (SUDO Permissions): ${LBLUE}[  $USER_NAME  ]${NORMAL}"
echo
echo "###-------------------------------------------------------------------------###"
echo
sleep 2

CONFIRM_YES_NO

###--------------------  UPDATE THE HOST  --------------------###
##
NEEDRESTART_MODE=a
DEBIAN_PRIORITY=required
export DEBIAN_FRONTEND=noninteractive

pro_attached=$(echo "$PRO_STATUS" | jq '.account')
    if [[ $pro_attached != "null" ]]; then
        echo "Ubuntu Pro is attached. Detaching and purging the client."
        pro detach --assume-yes
        apt-get purge ubuntu-pro-client -y
    fi

apt update && apt upgrade -y
apt-get -o Dpkg::Options::="--force-confdef" \
              -o Dpkg::Options::="--force-confold" \
              apt dist-upgrade -y
			  dpkg --configure -a

apt --purge autoremove -y
apt autoclean -y
apt update && apt upgrade -y

###--------------------  INSTALL APACHE AND CONFIGURE DIRECTORY PERMISSIONS  --------------------###
##
apt install apache2 -y
#mkdir "/var/www/html/$HST"
#touch /etc/apache2/sites-available/$HST.conf
chown -R www-data:www-data /var/www/html
usermod -aG www-data $USER_NAME
chown $USER_NAME:$USER_NAME /var/www/html
chmod -R 775 /var/www/html
chmod g+s /var/www/html

cp /var/www/html/index.html /var/www/html/index.html.bak
cp -r web/* /var/www/html/

###--------------------  ENABLE FIREWALL AND INCLUDE AND PORTS  --------------------###
##
echo "y" | ufw enable
ufw allow in "Apache Full"
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 990/tcp
ufw allow 22/tcp
ufw allow 10000/tcp
ufw allow 3306/tcp
ufw allow 40000:50000/tcp
ufw reload
systemctl enable apache2
systemctl start apache2

clear
echo "ENABLE FIREWALL AND INCLUDE AND PORTS"
CONFIRM_YES_NO

###--------------------  INSTALL MYSQL SERVER  --------------------###
##
sudo DEBIAN_FRONTEND=noninteractive apt install mysql-server -y
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '$PSWD';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql -e "FLUSH PRIVILEGES;"

systemctl restart mysql

###--------------------  INSTALL PHPMYADMIN  --------------------###
##
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PSWD" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $PSWD" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PSWD" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | sudo debconf-set-selections

apt-get install phpmyadmin -y
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
systemctl restart apache2
systemctl restart mysql

###--------------------  INSTALL PHP / OTHER APPLICATIONS  --------------------###
##
apt update
apt install -y php libapache2-mod-php php-mysql php-cli php-curl php-json php-xml php-zip
apt install -y net-tools nmap tcpdump cifs-utils dnsutils default-jre dos2unix 
apt install -y rar unrar perl python3 python3-pip

systemctl restart apache2
systemctl restart mysql

clear
echo "INSTALL PHP / OTHER APPLICATIONS" 
CONFIRM_YES_NO

###--------------------  INSTALL WEBMIN  --------------------###
##
apt install wget -y
wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo tee /etc/apt/trusted.gpg.d/jcameron.asc
sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
apt update -y
apt install webmin -y
systemctl enable webmin
systemctl start webmin

clear
echo "INSTALL WEBMIN"
CONFIRM_YES_NO

###--------------------  INSTALL VSFTPD TO ENABLE FTP ACCESS  --------------------###
##
apt install vsftpd -y
systemctl enable vsftpd
systemctl start vsftpd

clear
echo "INSTALL VSFTPD TO ENABLE FTP ACCESS"
CONFIRM_YES_NO

###--------------------  CONFIGURE VSFTPD/FTP TO INCLUDE SSL (FTPS)  --------------------###
##
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/private/vsftpd.crt -subj "/C=US/ST=State/L=City/O=Organization/OU=Org/CN=$HST"
sed -i 's/#ssl_enable=YES/ssl_enable=YES/' /etc/vsftpd.conf
echo "rsa_cert_file=/etc/ssl/private/vsftpd.crt" | tee -a /etc/vsftpd.conf
echo "rsa_private_key_file=/etc/ssl/private/vsftpd.key" | tee -a /etc/vsftpd.conf
echo "ssl_tlsv1=YES" | tee -a /etc/vsftpd.conf
echo "ssl_sslv2=NO" | tee -a /etc/vsftpd.conf
echo "ssl_sslv3=NO" | tee -a /etc/vsftpd.conf
systemctl restart vsftpd

clear
echo "CONFIGURE VSFTPD/FTP TO INCLUDE SSL (FTPS)"
CONFIRM_YES_NO

###--------------------  CONFIGURE APACHE TO USE THE SELF-SIGNED CERTIFICATE  --------------------###
##
bash -c "cat > /etc/apache2/sites-available/ssl-website.conf <<EOF
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    ServerName $HST
    ServerAlias $IP_ADDRESS

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    SSLCertificateChainFile /etc/ssl/certs/dhparam.pem

    <FilesMatch '\.(cgi|shtml|phtml|php)$'>
        SSLOptions +StdEnvVars
    </FilesMatch>

    <Directory /usr/lib/cgi-bin>
        SSLOptions +StdEnvVars
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF"

clear
echo "CONFIGURE APACHE TO USE THE SELF-SIGNED CERTIFICATE"
CONFIRM_YES_NO

###--------------------  CREATE A SELF-SIGNED CERTIFICATE TO USE WITH APACHE  --------------------###
##
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt -subj "/C=US/ST=State/L=City/O=Organization/OU=Org/CN=$HST"
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

clear
echo "CREATE A SELF-SIGNED CERTIFICATE TO USE WITH APACHE"
CONFIRM_YES_NO

###--------------------  ENABLE APACHE SSL MODULE/CONFIGURATION  --------------------###
##
a2enmod ssl
a2ensite ssl-website.conf
sudo a2enmod rewrite
systemctl reload apache2

clear
echo "ENABLE APACHE SSL MODULE/CONFIGURATION"
CONFIRM_YES_NO

###--------------------  SSH PORT SECURITY | GENERATE PORT NUMBER BETWEEN 1024 and 65535 AND CHANGE  --------------------###
##
while true; 
do
  NEW_PORT=$((RANDOM % 64512 + 1024))
  if ! IS_PORT_IN_USE $NEW_PORT; then
    break
  fi
done

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i "/^#Port/c\Port $NEW_PORT" /etc/ssh/sshd_config

if sudo ufw status | grep -q active; then
  if ! sudo ufw status | grep -q "$NEW_PORT/tcp"; then
    sudo ufw allow $NEW_PORT/tcp
    sudo ufw reload
  fi
  sudo ufw delete allow 22/tcp
  sudo ufw reload
fi

sudo systemctl restart ssh

clear
echo "SSH PORT SECURITY | GENERATE PORT NUMBER BETWEEN 1024 and 65535 AND CHANGE"
CONFIRM_YES_NO

###--------------------  OUTPUT INFORMATION  --------------------###
##
clear
echo "LAMP Stack Server Installed."
echo
echo "Apache HTTP is accessable at http://$IP_ADDRESS and http://$HST"
echo "Apache HTTPS SSL enabled for https://$IP_ADDRESS and https://$HST"
echo
echo "Access phpMyAdmin at http://$IP_ADDRESS/phpmyadmin or http://$HST/phpmyadmin"
echo "phpMyAdmin Username: phpMyAdmin"
echo "Password: $PSWD"
echo
echo "Access Webmin at https://$IP_ADDRESS:10000 or https://$HST:10000"
echo "Webmin Username: $USER_NAME"
echo "Password: [SSH Password]"
echo
echo "FTP server running with SSL enabled on port 990"
echo
echo "SSH port has been changed to $NEW_PORT."
echo "Port 22 has been blocked on the firewall."
echo "Please ensure you update your connection settings accordingly."
echo
echo "You can now reboot the system.  This is advisible!"
CONFIRM_YES_NO
reboot

##
###--------------------  END OF LAMP SCRIPT  --------------------###