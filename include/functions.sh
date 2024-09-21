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
[ -z "$genln" ] && genln=16
tr -dc A-Za-z0-9 < /dev/urandom | head -c ${genln} | xargs
}

###--------------------  IS PORT IN USE  --------------------###
##
IS_PORT_IN_USE() {
  lsof -i -P -n | grep LISTEN | grep ":$1 " > /dev/null
  return $?
}

###--------------------  CREATE RANDOM PORT  --------------------###
##
CREATE_RANDOM_PORT() {
    $NEW_PORT=$nil
    while true; 
    do
      NEW_PORT=$((RANDOM % 64512 + 1024))
      if ! IS_PORT_IN_USE $NEW_PORT; then
        break
      fi
    done
}

###--------------------  COLLECTING SYSTEM DATA  --------------------###
##
COLLECTING_SYSTEM_DATA() {
DIST=$nil
PSUEDONAME=$nil
PSWD=$(PASSGEN)
ROOT_PASSWORD=$(PASSGEN)
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

###--------------------  DELETE PURGE  --------------------###
#
DELETE_PURGE() {
# UNINSTALL PRO
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

# DELETE PURGE CLOUD-INIT
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

###--------------------  INDEX.HTML  --------------------###
#
INDEX_HTML() {
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
echo "	<h3 align="center">Apache, MySQL, phpMyAdmin, Webmin and VSFTPD inc FTP and Self-Signed Certificate to work with Apache and VSFTPD.</h3>" >> /var/www/html/index.html
echo "	<br>" >> /var/www/html/index.html
echo "	<h3 align="center">Program Version: $SCRIPTVERSION</h3>" >> /var/www/html/index.html
echo "	<h3 align="center">File Name: $FILENAME</h3>" >> /var/www/html/index.html
echo "	<h3 align="center">Author:  Neil Jamieson (Valikahn)</h3>" >> /var/www/html/index.html
echo "	<br>" >> /var/www/html/index.html
echo "	<h3 align="center">Program designed, developed, and tested while at university studying Computer Science for module 'Managing a Web Server (MAWS_HP2V48)'</h3>" >> /var/www/html/index.html
echo "	<br>" >> /var/www/html/index.html
echo "	<h3 align="center">Please refer to the GitHub README file for specific information about this script.</h3>" >> /var/www/html/index.html
echo "	<h3 align="center">Github: <a href="https://github.com/Valikahn/lamp" target="_blank">Valikahn / lamp</a></h3>" >> /var/www/html/index.html
echo "	<h2 align="center">_________________________________________________</h3><br>" >> /var/www/html/index.html
echo >> /var/www/html/index.html
echo "	<footer>" >> /var/www/html/index.html
echo "	  <div style='text-align: center; padding: 10px; background-color: #333; color: white;'> " >> /var/www/html/index.html
echo "	    <p>&copy; 2024 Copyright (C) 2024 Neil Jamieson <Valikahn></p>" >> /var/www/html/index.html
echo "	    <nav>" >> /var/www/html/index.html
echo "	      <a href="http://$IP_ADDRESS/phpinfo.php" style="color: white; margin-right: 15px;">PHP Info</a>" >> /var/www/html/index.html
echo "	      <a href="https://github.com/Valikahn/lamp/issues" style="color: white; margin-right: 15px;">Bugs & Issues</a>" >> /var/www/html/index.html
echo "	      <a href="https://www.gnu.org/licenses/gpl-3.0.en.html" style="color: white;">GPLv3 Licence</a>" >> /var/www/html/index.html
echo "	    </nav>" >> /var/www/html/index.html
echo "	  </div>" >> /var/www/html/index.html
echo "	</footer>" >> /var/www/html/index.html
#echo "	<h3 align="center"><a href="http://$IP_ADDRESS/phpinfo.php" target="_blank">PHP Info</a></h3>" >> /var/www/html/index.html
#echo "</body>" >> /var/www/html/index.html
#echo "</html>" >> /var/www/html/index.html
}
