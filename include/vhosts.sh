###################################################
##                                               ##
##  PROGRAM                                      ##
##                                               ##
###################################################

clear

###--------------------  vHost Creation  --------------------###
##
read -p "How many vHosts would you like to create? " QTY_VHOSTS
for ((v=1; v<=QTY_VHOSTS; v++)); do
    clear
    read -p "Enter the name for vHost $v (e.g., hello_world.local): " VHOST_NAME
    if ! mkdir -p /var/www/public_html/$VHOST_NAME/cms; then
        echo "Failed to create directory for $VHOST_NAME"
        continue
    fi
    echo

while true;
    do
    echo "Which CMS would you like to install for $VHOST_NAME?"
    echo "(1) for Drupal ${LBLUE}[https://www.drupal.org/]${NORMAL}"
    echo "(2) for Joomla ${LBLUE}[https://www.joomla.org/]${NORMAL}"
    echo "(3) for WordPress ${LBLUE}[https://wordpress.com/]${NORMAL}"
    echo "(4) for Grav ${LBLUE}[https://getgrav.org/]${NORMAL}"
    echo "(5) for ModX ${LBLUE}[https://modx.com/]${NORMAL}"
    echo "Or type skip to not install a CMS"
    echo 
    read -p "What is your choice? " CMS_CHOICE
    case $CMS_CHOICE in
        1)
            clear
            echo "Setting up Drupal for $VHOST_NAME"
            if wget -O /tmp/drupal.tar.gz https://www.drupal.org/download-latest/tar.gz; then
                if tar -xzf /tmp/drupal.tar.gz -C /var/www/public_html/$VHOST_NAME/cms --strip-components=1; then
                    echo "Drupal extracted successfully."
                else
                    echo "Failed to extract Drupal."
                    COUNTDOWN 5
                fi
                rm -f /tmp/drupal.tar.gz
            else
                echo "Failed to download Drupal."
                COUNTDOWN 5
            fi
            break
            ;;
        2)
            clear
            echo "Setting up Joomla for $VHOST_NAME"
            if wget -O /tmp/joomla.zip https://downloads.joomla.org/cms/joomla5/5-1-4/Joomla_5-1-4-Stable-Full_Package.zip; then
                if unzip /tmp/joomla.zip -d /var/www/public_html/$VHOST_NAME/cms; then
                    echo "Joomla extracted successfully."
                else
                    echo "Failed to extract Joomla."
                    COUNTDOWN 5
                fi
                rm -f /tmp/joomla.zip
            else
                echo "Failed to download Joomla."
                COUNTDOWN 5
            fi
            break
            ;;
        3)
            clear
            echo "Setting up WordPress for $VHOST_NAME"
            if wget -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz; then
                if tar -xzf /tmp/wordpress.tar.gz -C /var/www/public_html/$VHOST_NAME/cms --strip-components=1; then
                    echo "WordPress extracted successfully."
                else
                    echo "Failed to extract WordPress."
                    COUNTDOWN 5
                fi
                rm -f /tmp/wordpress.tar.gz
            else
                echo "Failed to download WordPress."
                COUNTDOWN 5
            fi
            break
            ;;
        4)
            clear
            echo "Setting up Grav for $VHOST_NAME"
            if wget -O /tmp/grav.zip https://getgrav.org/download/core/grav/latest; then
                if unzip /tmp/grav.zip -d /var/www/public_html/$VHOST_NAME/cms; then
                    echo "Grav extracted successfully."
                else
                    echo "Failed to extract Grav."
                    COUNTDOWN 5
                fi
                rm -f /tmp/grav.zip
            else
                echo "Failed to download Grav."
                COUNTDOWN 5
            fi
            break
            ;;
        5)
            clear
            echo "Setting up MODX for $VHOST_NAME"
            if wget -O /tmp/modx.zip https://modx.com/download/latest; then
                if unzip /tmp/modx.zip -d /var/www/public_html/$VHOST_NAME/cms; then
                    echo "MODX extracted successfully."
                else
                    echo "Failed to extract MODX."
                    COUNTDOWN 5
                fi
                rm -f /tmp/modx.zip
            else
                echo "Failed to download MODX."
                COUNTDOWN 5
            fi
            break
            ;;
        skip)
            echo "Skipping CMS setup for $VHOST_NAME."
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done

cat <<EOL >/etc/apache2/sites-available/$VHOST_NAME.conf
<VirtualHost *:80>
    ServerAdmin webmaster@$VHOST_NAME
    ServerName $VHOST_NAME
    ServerAlias www.$VHOST_NAME
    DocumentRoot /var/www/public_html/$VHOST_NAME

    <Directory /var/www/public_html/$VHOST_NAME>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${VHOST_NAME}_error.log
    CustomLog \${APACHE_LOG_DIR}/${VHOST_NAME}_access.log combined
</VirtualHost>

<VirtualHost *:443>
    ServerAdmin webmaster@$VHOST_NAME
    ServerName $VHOST_NAME
    ServerAlias www.$VHOST_NAME
    DocumentRoot /var/www/public_html/$VHOST_NAME

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    SSLCertificateChainFile /etc/ssl/certs/dhparam.pem


    <Directory /var/www/public_html/$VHOST_NAME>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${VHOST_NAME}_ssl_error.log
    CustomLog \${APACHE_LOG_DIR}/${VHOST_NAME}_ssl_access.log combined
</VirtualHost>
EOL

a2enmod ssl
a2ensite $VHOST_NAME.conf

cp -r web/* /var/www/public_html/$VHOST_NAME

if ! cp /var/www/html/conf/php.ini /var/www/public_html/$VHOST_NAME/cms/; then
    echo "Failed to copy php.ini for $VHOST_NAME"
fi

if ! cp /var/www/html/conf/.htaccess /var/www/public_html/$VHOST_NAME/cms/; then
    echo "Failed to copy .htaccess for $VHOST_NAME"
fi

chown -R www-data:www-data /var/www/public_html/$VHOST_NAME/
chmod -R 2755 /var/www/public_html/$VHOST_NAME
done

if systemctl reload apache2; then
    echo "Apache reloaded successfully."
else
    echo "Failed to reload Apache."
    COUNTDOWN 5
fi
