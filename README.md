<div align="center">
    <a href="https://github.com/Valikahn/lamp" target="_blank">
        <img alt="lamp" src="https://github.com/Valikahn/lamp/blob/master/web/img/lamp_img.png">
    </a>
</div>

## Script Description
LAMP (Linux, Apache, MySQL and PHP)
Apache, phpMyAdmin, Webmin and VSFTPD inc FTP and Self-Signed to work with Apache and VSFTPD.

## Purpose:
The script automates the installation, configuration, and setup of a LAMP (Linux, Apache, MySQL, and PHP) stack. 
It includes additional features like installing phpMyAdmin, Webmin, and VSFTPD for managing web servers and FTP services with SSL support.

* [Tested Operating Systems](#tested-operating-systems)
* [Installed Software Module Versions](#installed-software-module-versions)
* [Install Commands](#install-commands)
* [Script Process](#script-process)
* [Bugs & Issues](#bugs--issues)
* [Licence](#licence)
* [References](#references)

## Tested Operating Systems

* Ubuntu 24.04.x (Noble Numbat)

## Installed Software Module Versions
| Install Modules               | Version
|-------------------------------|-------------------------------|
| Apache                        | 2.4.58
| PHP                           | 8.3.6
| SSL                           | OpenSSL/3.0.13
| MySQL                         | 8.4
| phpMyAdmin                    | 5.2.1
| Webmin                        | 2.202 
| FTP server (vsftpd)           | 3.0.5

Please note that the above versions are the minimal versions that will be installed and may vary.
This deployment is not pulling specific versions but looking for the latest versions available.

## Features and Components
Initial Setup and Environment:
* Clears the terminal and sets the default text editor to nano.
* Defines variables for color outputs, versioning information, and host data collection (network interface, IP address, etc.).



## Install Commands
Install Git and clone the "lamp" package
```
sudo apt-get -y install wget git
git clone https://github.com/Valikahn/lamp.git
```

## Execute Script
```
cd lamp
chmod +x lamp.linux.deb.sh
sudo ./lamp.linux.deb.sh
```

## Script Process
UPDATE THE HOST
```
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
```
INSTALL APACHE AND CONFIGURE DIRECTORY PERMISSIONS
```
apt install -y apache2
apt install -y php
chown -R www-data:www-data /var/www/html
usermod -aG www-data $USER_NAME
chmod -R 775 /var/www/html
chmod g+s /var/www/html

cp /var/www/html/index.html /var/www/html/index.html.bak
cp -r web/* /var/www/html/
```
INSTALL MYSQL SERVER
```
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
```
INSTALL PHPMYADMIN
```
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $PSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections

apt-get install -y phpmyadmin >/dev/null 2>&1
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
systemctl restart apache2
systemctl restart mysql
```
INSTALL DEPENDENCIES
```
apt update
apt install -y php libapache2-mod-php php-mysql php-cli php-curl php-json php-xml php-zip >/dev/null 2>&1
apt install -y net-tools nmap tcpdump cifs-utils dnsutils default-jre dos2unix >/dev/null 2>&1
apt install -y rar unrar perl python3 python3-pip >/dev/null 2>&1

systemctl restart apache2
systemctl restart mysql
```
INSTALL WEBMIN
```
yes | curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh
yes | sh setup-repos.sh
apt-get install -y webmin --install-recommends
apt-get install -y --install-recommends ./webmin-current.deb
```
INSTALL VSFTPD TO ENABLE FTP ACCESS
```
apt install -y vsftpd >/dev/null 2>&1
systemctl enable vsftpd
systemctl start vsftpd
```
CONFIGURE VSFTP/FTP TO INCLUDE SSL (FTPS)
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/private/vsftpd.crt -subj "/C=US/ST=State/L=City/O=Organization/OU=Org/CN=$HST"
sed -i 's/#ssl_enable=YES/ssl_enable=YES/' /etc/vsftpd.conf
echo "rsa_cert_file=/etc/ssl/private/vsftpd.crt" | tee -a /etc/vsftpd.conf
echo "rsa_private_key_file=/etc/ssl/private/vsftpd.key" | tee -a /etc/vsftpd.conf
echo "ssl_tlsv1=YES" | tee -a /etc/vsftpd.conf
echo "ssl_sslv2=NO" | tee -a /etc/vsftpd.conf
echo "ssl_sslv3=NO" | tee -a /etc/vsftpd.conf
systemctl restart vsftpd
```
CONFIGURE APACHE TO USE THE SELF-SIGNED CERTIFICATE
```
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
```
CREATE A SELF-SIGNED CERTIFICATE TO USE WITH APACHE
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt -subj "/C=US/ST=State/L=City/O=Organization/OU=Org/CN=$HST" >/dev/null 2>&1
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 >/dev/null 2>&1
```
ENABLE APACHE SSL MODULE/CONFIGURATION
```
a2enmod ssl
a2ensite ssl-website.conf
a2enmod rewrite
systemctl reload apache2
```
SSH PORT SECURITY | GENERATE PORT NUMBER BETWEEN 1024 and 65535 AND CHANGE
```
while true; 
do
  NEW_PORT=$((RANDOM % 64512 + 1024))
  if ! IS_PORT_IN_USE $NEW_PORT; then
    break
  fi
done

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i "/^#Port/c\Port $NEW_PORT" /etc/ssh/sshd_config

if ufw status | grep -q active; then
  if ! ufw status | grep -q "$NEW_PORT/tcp"; then
    ufw allow $NEW_PORT/tcp
    ufw reload
  fi
  ufw delete allow 22/tcp
  ufw reload
fi
```
ENABLE FIREWALL AND ALLOW PORTS
```
ufw allow in "Apache Full"
ufw allow https
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 990/tcp
ufw allow 10000/tcp
ufw allow 3306/tcp
ufw allow 40000:50000/tcp
ufw reload
echo "y" | ufw enable
systemctl enable apache2
systemctl start apache2
systemctl restart ssh
```

## Program Information
Program Version: 24.9.17.244<br />
File Name: maws_h16s35-v24.9.17.244.linux.deb.sh<br />
Author:  Neil Jamieson (Valikahn)<br />

Program designed, developed, and tested while at university studying Computer Science for module "Managing a Web Server (maws_h16s35)"

## Bugs & Issues
Please feel free to report any bugs or issues to us.
* Issues:  <a href="https://github.com/Valikahn/lamp/issues">Via GitHub</a>

## Licence
Licensed under the GPLv3 License.
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
GPLv3 Licence:  https://www.gnu.org/licenses/gpl-3.0.en.html 

## References
Linux (Ubuntu 24.04.x) - https://ubuntu.com/download/server<br />
Apache - https://httpd.apache.org/<br />
MySQL - https://www.mysql.com/<br />
phpMyAdmin - https://www.phpmyadmin.net/<br />
Webmin - https://webmin.com/<br />
VSFTPD - https://wiki.archlinux.org/title/Very_Secure_FTP_Daemon<br />
OpenSSL - https://openssl-library.org/source/gitrepo/ and https://ubuntu.com/server/docs/openssl<br />
