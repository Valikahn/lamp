###################################################
##												 ##
##  SYSTEM CHECK								 ##
##												 ##
###################################################


clear
echo "SYSTEM CHECK..."
sleep 3

###--------------------  SUDO/ROOT CHECK  --------------------###
##
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

###--------------------  PASSWORD COLLECTION  --------------------###
##
PSWD=$(PASSGEN)
ROOT_PASSWORD=$(PASSGEN)

###--------------------  COLLECTING SYSTEM DATA  --------------------###
##
HST=$(hostname)
IP_ADDRESS=$(ip addr show $ENS | grep -oP 'inet \K[\d.]+')
USER_NAME=$(w -h | awk '{print $1}' | head -n 1)

DIST=$nil
PSUEDONAME=$nil
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

###--------------------  NETWORK MANAGER (NMCLI) CHECK  --------------------###
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