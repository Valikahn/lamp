###################################################
##												 ##
##  SYSTEM CHECK								 ##
##												 ##
###################################################


echo -n "SYSTEM CHECK..."; 	sleep 3

###--------------------  HOST REQUIREMENT CHECK  --------------------###
##
# COMING SOON

###--------------------  NETWORK MANAGER (NMCLI) CHECK  --------------------###
##
echo -n "NETWORK MANAGER (NMCLI) CHECK..."; 	sleep 3
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
echo -e "\rSNETWORK MANAGER (NMCLI) CHECK... ${GREEN}[  OK!  ]${NORMAL}"; sleep 3

###--------------------  PASSWORD COLLECTION  --------------------###
##
PSWD=$(PASSGEN)
ROOT_PASSWORD=$(PASSGEN)

###--------------------  COLLECTING SYSTEM DATA  --------------------###
##
clear
HST=$(hostname)
IP_ADDRESS=$(ip addr show $ENS | grep -oP 'inet \K[\d.]+')
USER_NAME=$(w -h | awk '{print $1}' | head -n 1)

DIST=$nil
PSUEDONAME=$nil
echo -n "Collecting Host/System Data..."
sleep 3

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
sleep 3

## DEBIAN
elif [ -f /etc/debian_version ] ; then
	DIST=`cat /etc/lsb-release | sed 's/"//g' | grep '^DISTRIB_DESCRIPTION' | awk -F=  '{ print $2 }'`
	PSUEDONAME=`cat /etc/lsb-release | sed 's/"//g' | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
	if [[ "$PSUEDONAME" == "Ubuntu" ]]; then
		DISTRO='Debian'
	fi
echo -e "\rCollecting Host/System Data... ${GREEN}[  OK  ]${NORMAL}"
sleep 3

else
	echo -e "\rCollecting Host/System Data... ${BOLD}${RED}[  FAIL  ]${NORMAL}"
	sleep 3
	echo "ERROR: RHEL or DEBIAN release files could not be found! [OPERATING SYSTEM DETECTION]"
	exit 1
fi

##
###
echo -e "\rSYSTEM CHECK... ${GREEN}[  OK!  ]${NORMAL}"; sleep 3