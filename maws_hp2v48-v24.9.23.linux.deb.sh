#!/bin/bash
clear
export EDITOR=nano
chmod +x include/variables.sh
chmod +x include/functions.sh

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


source ./include/variables.sh
source ./include/functions.sh


###################################################
##												 ##
##  SCRIPT START        			   			 ## 
##												 ##
###################################################

SUDO_CHECK
COLLECTING_SYSTEM_DATA
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
echo "Filename: $FILENAME"
echo
echo "###---------------------------------------------------------------------------------------------------###"
echo
echo "Currently logged-in as user: ${LBLUE}[  $USER_NAME  ]${NORMAL} with sudo permissions."
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
echo "###---------------------------------------------------------------------------------------------------###"
echo
echo "${BLINK}${YELLOW}[  IMPORTANT  ]${RESET}"
echo "Once the script has completed deploying, output infomration will be provided."
echo "This is important!  Once the screen is cleared or the host rebooted the data will be lost!"
echo
echo "###---------------------------------------------------------------------------------------------------###"
echo
sleep 2

CONFIRM_YES_NO

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

###--------------------  HTML PAGE CREATION  --------------------###
##
clear
source ./conf/html.sh

cp /var/www/html/index.html /var/www/html/index.html.bak
rm -rf /var/www/html/index.html
touch /var/www/html/index.html

INDEX_HTML

cp -r web/* /var/www/html/

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