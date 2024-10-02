#!/bin/bash
clear
export EDITOR=nano
source ./include/variables.sh
source ./include/functions.sh

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


SUDO_CHECK
source ./include/system_check.sh


###################################################
##												 ##
##  SCRIPT START        			   			 ## 
##												 ##
###################################################


clear
NMCLI_DEV_SHOW

###--------------------  OPERATING SYSTEM CONSOLE OUTPUT  --------------------###
##
sleep 2
echo
echo "###---------------------------------------------------------------------------------------------------###"
echo
echo "LAMP (Linux, Apache, MySQL and PHP)"
echo "Managing a Web Server (MAWS_HP2V48)"
echo
echo "${RED}[  Copyright (C) 2024 Neil Jamieson  ]${NORMAL}"
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
if [ -n "$DNS" ]; then
  echo "DNS Addresses: ${LBLUE}[  $DNS  ]${NORMAL}"
fi
echo "Network Interface: ${LBLUE}[  $ENS  ]${NORMAL}" 
echo
echo "###---------------------------------------------------------------------------------------------------###"
echo
echo "${BLINK}${BYELLOW}[  IMPORTANT  ]${RESET}"
echo "Once the script has completed deploying the host will reboot in 30 seconds."
echo "Take note of the URL displayed on the terminal windows for the server configuration."
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
DEPLOY_HTML

###--------------------  VHOST QUESTION  --------------------###
##
read -p "Would you like to deploy vHosts? (Yy/Nn): " CONFIRM
echo
	if [[ "$CONFIRM" == "Y" ]] || [[ "$CONFIRM" == "y" ]] || [[ "$CONFIRM" == "YES" ]] || [[ "$CONFIRM" == "yes" ]] || [[ "$CONFIRM" == "Yes" ]]; then
		source ./include/vhosts.sh
		break
	elif [[ "$CONFIRM" == "N" ]] || [[ "$CONFIRM" == "n" ]] || [[ "$CONFIRM" == "NO" ]] || [[ "$CONFIRM" == "no" ]] || [[ "$CONFIRM" == "No" ]]; then
	    break
    else
	    echo "Invalid choice - try again please. Enter 'Yy' or 'Nn'."
	    echo
    fi

###--------------------  OUTPUT INFORMATION  --------------------###
##
clear
echo "LAMP Stack Server Installed"
echo "---------------------------"
echo "This automation script has now completed and will reboot in 30 seconds!"
echo "Visit http://$IP_ADDRESS for all automation completion details."
echo
COUNTDOWN 30
echo "Time's up! Rebooting!"
sleep 2
reboot

##
###--------------------  END OF LAMP SCRIPT  --------------------###