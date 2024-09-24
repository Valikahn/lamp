###################################################
##												 ##
##  PROGRAM 									 ##
##												 ##
###################################################


clear

###--------------------  vHost Creation  --------------------###
##
read -p "How many vHosts would you like to create? " num_vhosts
for ((v=1; v<=num_vhosts; v++)); do
    read -p "Enter the name for vHost $v (e.g., hello_world.local): " VHOST_NAME
        if ! mkdir -p /var/www/public_html/$VHOST_NAME/cms; then
            echo "Failed to create directory for $VHOST_NAME"
            continue
        fi
    while true; 
    do
        read -p "Which CMS would you like to install for $VHOST_NAME? (drupal/joomla/wordpress/skip) " CMS_CHOICE
        case $CMS_CHOICE in
            drupal)
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
            joomla)
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
            wordpress)
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
            skip)
                echo "Skipping CMS setup for $VHOST_NAME."
                break
                ;;
            *)
                echo "Invalid choice. Please try again."
                ;;
        esac
    done

    cp /var/www/html/conf/php.ini /var/www/public_html/$VHOST_NAME/cms/
    cp /var/www/html/conf/.htaccess /var/www/public_html/$VHOST_NAME/cms/  
    chown -R www-data:www-data /var/www/public_html/$VHOST_NAME/cms

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
EOL

    a2ensite $VHOST_NAME.conf
done

if systemctl reload apache2; then
    echo "Apache reloaded successfully."
else
    echo "Failed to reload Apache."
    COUNTDOWN 5
fi
