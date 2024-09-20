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
##  Managing a Web Server (MAWS_HP2V48)                                                                                                              ##
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

###--------------------  BLINK DECLARE  --------------------###
##
BLINK=$(tput blink)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

###--------------------  VERSIONING --------------------###
##
SCRIPTVERSION="v24.9.23"
BUILD="001-ALPHA"
REVDATE="23 September 2024"
FILENAME="maws_hp2v48.$SCRIPTVERSION.linux.deb.sh"

###--------------------  HOST DATA COLLECTION  --------------------###
##
if command -v nmcli >/dev/null 2>&1; then
    ENS=$(nmcli dev status | grep '^ens' | awk '{ print $1 }')
    DOM=$(nmcli dev status | grep '^ens' | awk '{ print $4 }')
    LIP=$(nmcli -f ipv4.addresses con show $DOM | awk '{ print $2 }')
    DNS=$(nmcli -f ipv4.dns con show $DOM | awk '{ print $2 }' | paste -sd ',')
else
    echo "This script works best with NMCLI (Network Manager)"
    echo "NMCLI is not installed. Do you want to install it? (y/n)"
    read -r INSTALL_NMCLI

    if [[ "$INSTALL_NMCLI" == "y" || "$INSTALL_NMCLI" == "Y" ]]; then
        sudo apt-get update && sudo apt-get install network-manager -y >/dev/null 2>&1
        ENS=$(nmcli dev status | grep '^ens' | awk '{ print $1 }')
        DOM=$(nmcli dev status | grep '^ens' | awk '{ print $4 }')
        LIP=$(nmcli -f ipv4.addresses con show $DOM | awk '{ print $2 }')
        DNS=$(nmcli -f ipv4.dns con show $DOM | awk '{ print $2 }' | paste -sd ',')
    else
        ENS=$(ip link show | grep '^2:' | awk -F': ' '{ print $2 }' | grep '^ens')
        LIP=$(ip -4 addr show dev $ENS | grep 'inet ' | awk '{ print $2 }')
        DNS=$(grep -A 4 'nameservers:' /etc/netplan/*.yaml | grep '-' | awk '{ print $2 }' | paste -sd ',')
    fi
fi

HST=$(hostname)
IP_ADDRESS=$(ip addr show $ENS | grep -oP 'inet \K[\d.]+')
USER_NAME=$(w -h | awk '{print $1}' | head -n 1)

source ./functions/functions.sh


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
echo "###-----------------------------------------------------------------------------------------###"
echo
echo "LAMP (Linux, Apache, MySQL and PHP)"
echo "Managing a Web Server (MAWS_HP2V48)"
echo
echo "Author:  Neil Jamieson <000705@uhi.ac.uk>"
echo "Currently logged-in as user: ${LBLUE}[  $USER_NAME  ]${NORMAL} with sudo permissions."
echo
echo "${YELLOW}[  Credit where credits due!  This did not write itself!  ]${NORMAL}"
echo
echo "###-----------------------------------------------------------------------------------------###"
echo
echo "Script Version: ${LBLUE}[  $SCRIPTVERSION  ]${NORMAL}"
echo "Filename: ${LBLUE}[  $FILENAME  ]${NORMAL}"
echo "Build Release: ${LBLUE}[  $BUILD  ]${NORMAL}"
echo "Last Update: ${LBLUE}[  $REVDATE  ]${NORMAL}"
echo
echo "Operating System: ${LBLUE}[  $DIST  ]${NORMAL}"
echo "Hostname: ${LBLUE}[  $HST  ]${NORMAL}"
echo "IP Address / CIDR: ${LBLUE}[  $LIP  ]${NORMAL}"
echo "DNS Addresses: ${LBLUE}[  $DNS  ]${NORMAL}"
echo "Network Interface: ${LBLUE}[  $ENS  ]${NORMAL}" 
echo
echo "###-----------------------------------------------------------------------------------------###"
echo
echo "${BLINK}${YELLOW}[  IMPORTANT  ]${RESET}"
echo "Once the script has completed deploying, output infomration will be provided."
echo "This is important!  Once the screen is cleared or the host rebooted the data will be lost!"
echo
echo "###-----------------------------------------------------------------------------------------###"
echo
sleep 2

CONFIRM_YES_NO
DELETE_PURGE

###--------------------  UPDATE THE HOST  --------------------###
##
clear
NEEDRESTART_MODE=a
DEBIAN_PRIORITY=required
export DEBIAN_FRONTEND=noninteractive

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
clear
apt install -y apache2
apt install -y php
chown -R www-data:www-data /var/www/html
usermod -aG www-data $USER_NAME
chmod -R 775 /var/www/html
chmod g+s /var/www/html

cp /var/www/html/index.html /var/www/html/index.html.bak
rm -rf /var/www/html/index.html
touch /var/www/html/index.html

echo "<!DOCTYPE html>" >> /var/www/html/index.html
echo >> /var/www/html/index.html
echo "<!-- LAMP Logo at top of HTML document -->" >> /var/www/html/index.html
echo "<div align="center">" >> /var/www/html/index.html
echo "	<a href="https://github.com/Valikahn/lamp" target="_blank">" >> /var/www/html/index.html
echo "		<img alt="lamp" src="img/lamp_img.png">" >> /var/www/html/index.html
echo "	</a>" >> /var/www/html/index.html
echo "</div>" >> /var/www/html/index.html
echo >> /var/www/html/index.html
echo "<!-- HEAD containing the page title and link to external CSS  -->" >> /var/www/html/index.html
echo "<html lang="en">" >> /var/www/html/index.html
echo "<head>" >> /var/www/html/index.html
echo "	<meta charset="UTF-8">" >> /var/www/html/index.html
echo "	<meta name="viewport" content="width=device-width, initial-scale=1.0">" >> /var/www/html/index.html
echo "	<link rel="stylesheet" href="css/styles.css">" >> /var/www/html/index.html
echo >> /var/www/html/index.html
echo "	<title>LAMP (Linux, Apache, MySQL and PHP)</title>" >> /var/www/html/index.html
echo "</head>" >> /var/www/html/index.html
echo >> /var/www/html/index.html
echo "<!-- BODY containing the page information -->" >> /var/www/html/index.html
echo "<body>" >> /var/www/html/index.html
echo "	<h2 align="center">_________________________________________________</h3><br>" >> /var/www/html/index.html
echo "	<h2 align="center">LAMP (Linux, Apache, MySQL and PHP)</h2><br>" >> /var/www/html/index.html
echo "	<h3 align="center">Apache, phpMyAdmin, Webmin and VSFTPD inc FTP and Self-Signed Certificate to work with Apache and VSFTPD.</h3>" >> /var/www/html/index.html
echo "	<br>" >> /var/www/html/index.html
echo "	<h3 align="center">Program Version: $SCRIPTVERSION</h3>" >> /var/www/html/index.html
echo "	<h3 align="center">File Name: $FILENAME</h3>" >> /var/www/html/index.html
echo "	<h3 align="center">Author:  Neil Jamieson (Valikahn)</h3>" >> /var/www/html/index.html
echo "	<br>" >> /var/www/html/index.html
echo "	<h3 align="center">Program designed, developed, and tested while at university studying Computer Science for module 'Managing a Web Server (MAWS_HP2V48)'</h3>" >> /var/www/html/index.html
echo "	<br>" >> /var/www/html/index.html
echo "	<h3 align="center">Please refer to the GitHub README file for specific information about this script.</h3>" >> /var/www/html/index.html
echo "	<h3 align="center">Github: <a href="https://github.com/Valikahn/lamp" target="_blank">https://github.com/Valikahn/lamp</a></h3>" >> /var/www/html/index.html
echo "	<h2 align="center">_________________________________________________</h3><br>" >> /var/www/html/index.html
echo "	<h3 align="center"><a href="http://$IP_ADDRESS/phpinfo.php" target="_blank">PHP Info</a></h3>" >> /var/www/html/index.html
echo "</body>" >> /var/www/html/index.html
echo "</html>" >> /var/www/html/index.html

cp -r web/* /var/www/html/

CONFIRM_YES_NO

###--------------------  INSTALL MYSQL SERVER  --------------------###
##
clear
apt update
DEBIAN_FRONTEND=noninteractive apt install -y mysql-server
systemctl enable mysql
systemctl start mysql

mysql --user=root <<_EOF_
ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '$MYSQL_ROOT_PASSWORD';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;

CREATE USER 'phpMyAdmin'@'localhost' IDENTIFIED BY '$PSWD';
GRANT ALL PRIVILEGES ON *.* TO 'phpMyAdmin'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
_EOF_

debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"

###--------------------  INSTALL PHPMYADMIN  --------------------###
##
clear
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $PSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections

apt-get install -y phpmyadmin >/dev/null 2>&1
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
systemctl restart apache2
systemctl restart mysql

###--------------------  INSTALL DEPENDENCIES  --------------------###
##
clear
apt update
apt install -y php libapache2-mod-php php-mysql php-cli php-curl php-json php-xml php-zip >/dev/null 2>&1
apt install -y net-tools nmap tcpdump cifs-utils dnsutils default-jre dos2unix >/dev/null 2>&1
apt install -y rar unrar perl python3 python3-pip >/dev/null 2>&1

systemctl restart apache2
systemctl restart mysql

###--------------------  INSTALL WEBMIN  --------------------###
##
clear
yes | curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh
yes | sh setup-repos.sh
apt-get install -y webmin --install-recommends
apt-get install -y --install-recommends ./webmin-current.deb

#sudo /usr/share/webmin/changepass.pl /etc/webmin root "$ROOT_PASSWORD"

###--------------------  INSTALL VSFTPD TO ENABLE FTP ACCESS  --------------------###
##
clear
apt install -y vsftpd >/dev/null 2>&1
systemctl enable vsftpd
systemctl start vsftpd

###--------------------  CONFIGURE VSFTPD/FTP TO INCLUDE SSL (FTPS)  --------------------###
##
clear
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/private/vsftpd.crt -subj "/C=UK/ST=Cromarty/L=Alness/O=MAWS_HP2V48/OU=H16S35/CN=$HST"

CREATE_RANDOM_PORT
FTP_PORT=$NEW_PORT

# Enable SSL
sed -i 's/#ssl_enable=YES/ssl_enable=YES/' /etc/vsftpd.conf
echo "rsa_cert_file=/etc/ssl/private/vsftpd.crt" | tee -a /etc/vsftpd.conf
echo "rsa_private_key_file=/etc/ssl/private/vsftpd.key" | tee -a /etc/vsftpd.conf
echo "ssl_tlsv1=YES" | tee -a /etc/vsftpd.conf
echo "ssl_sslv2=NO" | tee -a /etc/vsftpd.conf
echo "ssl_sslv3=NO" | tee -a /etc/vsftpd.conf

# Configure to use FTPS on port 990
echo "listen_port=27783" | tee -a /etc/vsftpd.conf
echo "allow_anon_ssl=NO" | tee -a /etc/vsftpd.conf
echo "force_local_data_ssl=YES" | tee -a /etc/vsftpd.conf
echo "force_local_logins_ssl=YES" | tee -a /etc/vsftpd.conf
echo "ssl_ciphers=HIGH" | tee -a /etc/vsftpd.conf
echo "require_ssl_reuse=NO" | tee -a /etc/vsftpd.conf

# Passive mode settings (optional, adjust based on your network setup)
echo "pasv_enable=YES" | tee -a /etc/vsftpd.conf
echo "pasv_min_port=10000" | tee -a /etc/vsftpd.conf
echo "pasv_max_port=10100" | tee -a /etc/vsftpd.conf

cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
sed -i "/^#listen_port/c\listen_port $FTP_PORT" /etc/vsftpd.conf

if ufw status | grep -q active; then
    if ! ufw status | grep -q "$FTP_PORT/tcp"; then
        ufw allow $FTP_PORT/tcp
        ufw reload
    fi
fi

systemctl restart vsftpd

###--------------------  CONFIGURE APACHE TO USE THE SELF-SIGNED CERTIFICATE  --------------------###
##
clear
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

###--------------------  CREATE A SELF-SIGNED CERTIFICATE TO USE WITH APACHE  --------------------###
##
clear
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt -subj "/C=UK/ST=Cromarty/L=Alness/O=MAWS_HP2V48/OU=H16S35/CN=$HST" >/dev/null 2>&1
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 >/dev/null 2>&1

###--------------------  ENABLE APACHE SSL MODULE/CONFIGURATION  --------------------###
##
clear
a2enmod ssl
a2ensite ssl-website.conf
a2enmod rewrite
systemctl reload apache2

###--------------------  SSH PORT SECURITY | GENERATE PORT NUMBER BETWEEN 1024 and 65535 AND CHANGE  --------------------###
##
clear
CREATE_RANDOM_PORT
SSH_PORT=$NEW_PORT

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i "/^#Port/c\Port $SSH_PORT" /etc/ssh/sshd_config

if ufw status | grep -q active; then
  if ! ufw status | grep -q "$SSH_PORT/tcp"; then
    ufw allow $SSH_PORT/tcp
    ufw reload
  fi
  ufw delete allow 22/tcp
  ufw reload
fi

###--------------------  ENABLE FIREWALL AND ALLOW PORTS  --------------------###
##
clear
ufw allow in "Apache Full"
ufw allow https
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 10000/tcp
ufw allow 3306/tcp
ufw allow 40000:50000/tcp
ufw allow 10000:10100/tcp
ufw reload
echo "y" | ufw enable
systemctl enable apache2
systemctl start apache2
systemctl restart ssh

###--------------------  OUTPUT INFORMATION  --------------------###
##
clear
echo "LAMP Stack Server Installed."
echo
echo "Apache HTTP is accessable at http://$IP_ADDRESS"
echo "Apache HTTPS SSL enabled for https://$IP_ADDRESS"
echo
echo "Access phpMyAdmin at http://$IP_ADDRESS/phpmyadmin"
echo "phpMyAdmin Username: phpMyAdmin"
echo "Password: $PSWD"
echo
echo "Access Webmin at https://$IP_ADDRESS:10000"
echo "Webmin Username: $USER_NAME"
echo "Password: [SHELL PASSWORD]"
echo 
echo "Sudo Username: root"
echo "Password: $ROOT_PASSWORD"
echo
echo "FTP server running with SSL enabled on port $FTP_PORT"
echo "SSH port has been changed to $SSH_PORT."
echo
echo "Port 22 has been blocked on the firewall."
echo "Please ensure you update your connection settings accordingly."
echo
echo "You can now reboot the system.  This is advisible!"
CONFIRM_YES_NO
reboot

##
###--------------------  END OF LAMP SCRIPT  --------------------###