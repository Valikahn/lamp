###################################################
##												 ##
##  PROGRAM 									 ##
##												 ##
###################################################


clear

###--------------------  UNINSTALL DETACH UBUNTU PRO  --------------------###
##
DETACH_PRO() {
if command -v pro &> /dev/null; then
    echo "Ubuntu Pro is installed. Checking if the system is attached..."
    PRO_STATUS=$(pro status --format json)
        if [[ $(echo "$PRO_STATUS" | grep -i '"attached": true') ]]; then
            echo "System is attached to Ubuntu Pro. Detaching now..."
            sudo pro detach
                if [ $? -eq 0 ]; then
                    echo "System successfully detached from Ubuntu Pro."
                else
                    echo "Failed to detach from Ubuntu Pro. Exiting."
                    exit 1
                fi
            else
                echo "System is not attached to Ubuntu Pro."
        fi
    echo "Proceeding to uninstall Ubuntu Pro."
    sudo apt-get remove --purge ubuntu-advantage-tools -y
    if [ $? -eq 0 ]; then
        echo "Ubuntu Pro has been successfully uninstalled."
    else
        echo "Failed to uninstall Ubuntu Pro."
        exit 1
    fi
else
    echo "Ubuntu Pro is not installed. Continuing."
fi

echo "Script will now continue..."
sleep 5
}

###--------------------  DELETE PURGE CLOUD-INIT  --------------------###
## 
PURGE_CLOUD_INIT() {
if dpkg -l | grep -q cloud-init > /dev/null 2>&1; then
    apt-get purge -y cloud-init 2>&1
	apt autoremove -y 2>&1
else
	echo "Cloud-Init not found/installed on host - moving on."
fi

if id "cloud-user"; then
    deluser cloud-user 2>&1
	echo "Deleted cloud-user account"
	deluser --remove-home cloud-user 2>&1
	echo "Deleted cloud-user profile"
else
	echo "Cloud-User Profile not found on host - moving on."
fi

if [ -e "/var/log/cloud-init.log" ]; then
    rm -rf /var/log/cloud-init.log 2>&1
    echo "Deleted cloud-init files (/var/log/cloud-init.log)"
fi
		
if [ -e "/var/log/cloud-init-output.log" ]; then
    rm -rf /var/log/cloud-init-output.log 2>&1
    echo "Deleted cloud-init files (/var/log/cloud-init-output.log)"
fi
sleep 5
}

###--------------------  UPDATE DEB HOST  --------------------###
##
UPDATE_DEB_HOST() {
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
}

###--------------------  INSTALL APACHE AND CONFIGURE DIRECTORY PERMISSIONS  --------------------###
##
INSTALL_APACHE() {
clear
apt install -y apache2
apt install -y php
chown -R www-data:www-data /var/www/html
usermod -aG www-data $USER_NAME
chmod -R 775 /var/www/html
chmod g+s /var/www/html
}

###--------------------  INSTALL IONCUBE LOADER  --------------------###
##
INSTALL_IONCUBE() {
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_EXT_DIR=$(php -i | grep extension_dir | cut -d" " -f5)
IONCUBE_URL="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"
IONCUBE_DIR="/tmp/ioncube"

apt update -y && sudo apt upgrade -y
sudo apt install php-cli php-dev php-pear -y
wget $IONCUBE_URL -O /tmp/ioncube_loaders.tar.gz
tar xzf /tmp/ioncube_loaders.tar.gz -C /tmp/
sudo cp $IONCUBE_DIR/ioncube_loader_lin_${PHP_VERSION}.so $PHP_EXT_DIR

PHP_INI_CLI="/etc/php/${PHP_VERSION}/cli/php.ini"
PHP_INI_FPM="/etc/php/${PHP_VERSION}/fpm/php.ini"

if ! grep -q "ioncube_loader_lin_${PHP_VERSION}.so" $PHP_INI_CLI; then
    echo "zend_extension = $PHP_EXT_DIR/ioncube_loader_lin_${PHP_VERSION}.so" | sudo tee -a $PHP_INI_CLI
fi

if [ -f "$PHP_INI_FPM" ]; then
    if ! grep -q "ioncube_loader_lin_${PHP_VERSION}.so" $PHP_INI_FPM; then
        echo "zend_extension = $PHP_EXT_DIR/ioncube_loader_lin_${PHP_VERSION}.so" | sudo tee -a $PHP_INI_FPM
    fi
fi

if [ $(systemctl is-active apache2) == "active" ]; then
    sudo systemctl restart apache2
fi

if [ $(systemctl is-active php${PHP_VERSION}-fpm) == "active" ]; then
    sudo systemctl restart php${PHP_VERSION}-fpm
fi

clear
php -v | grep ionCube

if [ $? -eq 0 ]; then
    echo "IonCube Loader installed successfully!"
else
    echo "IonCube Loader installation failed."
fi
sleep 5
}

###--------------------  INSTALL MYSQL SERVER  --------------------###
##
INSTALL_MYSQL() {
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
}

###--------------------  INSTALL PHPMYADMIN  --------------------###
##
INSTALL_PHPMYADMIN() {
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
}

###--------------------  INSTALL DEPENDENCIES  --------------------###
##
INSTALL_DEPENDENCIES() {
clear
apt update
apt install -y libapache2-mod-php php-mysql php-cli php-curl php-json php-xml php-zip >/dev/null 2>&1
apt install -y net-tools nmap tcpdump cifs-utils dnsutils default-jre dos2unix >/dev/null 2>&1
apt install -y rar unrar perl python3 python3-pip >/dev/null 2>&1

systemctl restart apache2
systemctl restart mysql
}

###--------------------  INSTALL WEBMIN  --------------------###
##
INSTALL_WEBMIN() {
clear
yes | curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh
yes | sh setup-repos.sh
apt-get install -y --install-recommends webmin
apt-get install -y --install-recommends ./webmin-current.deb
}

# This command will reset the root password and prevent access using the shell login.
#sudo /usr/share/webmin/changepass.pl /etc/webmin root "$ROOT_PASSWORD"

###--------------------  INSTALL VSFTPD TO ENABLE FTP ACCESS  --------------------###
##
INSTALL_VSFTPD(){
clear
apt install -y vsftpd >/dev/null 2>&1
systemctl enable vsftpd
systemctl start vsftpd

source ./conf/vsftpd.sh

systemctl restart vsftpd
}

###--------------------  CONFIGURE APACHE VIRTUAL HOST FOR PORT 443  --------------------###
##
SELF_SIGNED_CERT() {
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

source ./conf/ss_cert.sh
}

###--------------------  SSH PORT SECURITY | GENERATE PORT NUMBER BETWEEN 1024 and 65535 AND CHANGE  --------------------###
##
GENERATE_SSH_PORT() {
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
}

###--------------------  ENABLE FIREWALL AND ALLOW PORTS  --------------------###
##
FIREWALL() {
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
}