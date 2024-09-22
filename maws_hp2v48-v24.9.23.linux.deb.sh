#!/bin/bash
clear
export EDITOR=nano

###--------------------  START OF LAMP SCRIPT  --------------------###
##


######################################################################################################################################################
######################################################################################################################################################
##																																					##
##  LAMP (Linux, Apache, MySQL and PHP)                                                                                                             ##
##  Apache SSL, phpMyAdmin, Webmin and VSFTPD inc FTP SSL                                                                                           ##
##  Managing a Web Server (MAWS_HP2V48)                                                                                                             ##
##																																					##
##  Written by:  Neil Jamison <000705@uhi.ac.uk>																									##
##  Copyright (C) 2024 Neil Jamieson																												##
##																																					##
######################################################################################################################################################
######################################################################################################################################################
##																																					##
##  Licensed under the GPLv3 License.																												##
##  GPLv3 Licence:  https://www.gnu.org/licenses/gpl-3.0.en.html																					##
##																																					##
##	This program comes with ABSOLUTELY NO WARRANTY; for details type 'show w'. This is free software, and you are welcome to redistribute it		##
##  under certain conditions; type 'show c' for details."																							##
##																																					##
######################################################################################################################################################
######################################################################################################################################################


###--------------------  SUDO/ROOT CHECK  --------------------###
##
clear
if [ "$(id -u)" -ne 0 ]; then 
	echo -n "SUDO PERMISSION CHECK..."; 	sleep 5
	echo -e "\rSUDO PERMISSION CHECK... ${RED}[  ACCESS DENIED  ]${NORMAL}"; sleep 3
	echo
	echo "Error 126: Command cannot execute."
	echo "This error code is used when a command is found but is not executable.  Execute as root/sudo!"
	exit 126
else
	echo -n "SUDO PERMISSION CHECK..."; 	sleep 5
	echo -e "\rSUDO PERMISSION CHECK... ${GREEN}[  ACCESS GRANTED  ]${NORMAL}"; sleep 3
    clear
fi

source ./include/variables.sh
source ./include/functions.sh
source ./include/system_check.sh


###################################################
##												 ##
##  SCRIPT START        			   			 ## 
##												 ##
###################################################


clear

###--------------------  OPERATING SYSTEM CONSOLE OUTPUT  --------------------###
##
sleep 2
echo
echo "###---------------------------------------------------------------------------------------------------###"
echo
echo "LAMP (Linux, Apache, MySQL and PHP)"
echo "Managing a Web Server (MAWS_HP2V48)"
echo
echo "${BLINK}${BYELLOW}[  Copyright (C) 2024 Neil Jamieson  ]${RESET}"
echo "This program comes with ABSOLUTELY NO WARRANTY; for details type 'show w'. This is free software,"
echo "and you are welcome to redistribute it under certain conditions; type 'show c' for details."
echo
echo "###---------------------------------------------------------------------------------------------------###"
echo
echo "Filename: ${LBLUE}[  $FILENAME  ]${NORMAL}"
echo
echo "###---------------------------------------------------------------------------------------------------###"
echo
echo "Currently logged-in as user: ${LBLUE}[  $USER_NAME  ]${NORMAL} with sudo permissions."
echo
echo "Script Version: ${LBLUE}[  $SCRIPTVERSION  ]${NORMAL}"
echo "Build Release: ${LBLUE}[  $BUILD  ]${NORMAL}"
echo "Last Update: ${LBLUE}[  $REVDATE  ]${NORMAL}"
echo
echo "Operating System: ${LBLUE}[  $DIST  ]${NORMAL}"
echo "Hostname: ${LBLUE}[  $HST  ]${NORMAL}"
echo "IP Address / CIDR: ${LBLUE}[  $LIP  ]${NORMAL}"
echo "DNS Addresses: ${LBLUE}[  $DNS  ]${NORMAL}"
echo "Network Interface: ${LBLUE}[  $ENS  ]${NORMAL}" 
echo
echo "###---------------------------------------------------------------------------------------------------###"
echo
echo "${BLINK}${BYELLOW}[  IMPORTANT  ]${RESET}"
echo "Once the script has completed deploying, output infomration will be provided."
echo "This is important!  Once the screen is cleared or the host rebooted the data will be lost!"
echo
echo "###---------------------------------------------------------------------------------------------------###"
echo
sleep 2

CONFIRM_YES_NO

###--------------------  PROGRAM EXECUTE FUNCTIONS  --------------------###
##
source ./include/program.sh

DETACH_PRO
PURGE_CLOUD_INIT
UPDATE_DEB_HOST
INSTALL_APACHE
INSTALL_IONCUBE
INSTALL_MYSQL
INSTALL_PHPMYADMIN
INSTALL_DEPENDENCIES
INSTALL_WEBMIN
INSTALL_VSFTPD
SELF_SIGNED_CERT
GENERATE_SSH_PORT
FIREWALL

###--------------------  HTML PAGE CREATION  --------------------###
##
clear

cp /var/www/html/index.html /var/www/html/index.html.bak
rm -rf /var/www/html/index.html
touch /var/www/html/index.html

source ./conf/html.sh

cp -r web/* /var/www/html/

###--------------------  OUTPUT INFORMATION  --------------------###
##
clear
echo "LAMP Stack Server Installed"
echo "---------------------------"
echo "Visit http://$IP_ADDRESS for all automation completion details."
echo
echo "It is advisible to reboot this host as soon as possible!"
CONFIRM_YES_NO
reboot

##
###--------------------  END OF LAMP SCRIPT  --------------------###