###################################################
##												 ##
##  SYSTEM CHECK								 ##
##												 ##
###################################################


###--------------------  NETWORK MANAGER (NMCLI) CHECK  --------------------###
##
if command -v nmcli >/dev/null 2>&1; then
    ENS=$(nmcli dev status | grep '^ens' | awk '{ print $1 }')
    DOM=$(nmcli dev status | grep '^ens' | awk '{ print $4 }')
    LIP=$(nmcli -f ipv4.addresses con show $DOM | awk '{ print $2 }')
    DNS=$(nmcli -f ipv4.dns con show $DOM | awk '{ print $2 }' | paste -sd ',')
else
    echo "This script works best with NMCLI (Network Manager)"
    read -p "NMCLI is not installed. Do you want to install it? (y/n): " INSTALL_NMCLI

    if [[ "$INSTALL_NMCLI" == "y" || "$INSTALL_NMCLI" == "Y" ]]; then
    clear
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
echo -n "DATA COLLECTION..."
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
echo -e "\rDATA COLLECTION... ${GREEN}[  OK!  ]${NORMAL}"
sleep 3

## DEBIAN
elif [ -f /etc/debian_version ] ; then
	DIST=`cat /etc/lsb-release | sed 's/"//g' | grep '^DISTRIB_DESCRIPTION' | awk -F=  '{ print $2 }'`
	PSUEDONAME=`cat /etc/lsb-release | sed 's/"//g' | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
	if [[ "$PSUEDONAME" == "Ubuntu" ]]; then
		DISTRO='Debian'
	fi
echo -e "\rDATA COLLECTION... ${GREEN}[  OK!  ]${NORMAL}"
sleep 3

else
	echo -e "\rDATA COLLECTION... ${BOLD}${RED}[  FAILED!  ]${NORMAL}"
	sleep 3
	echo "ERROR: RHEL or DEBIAN release files could not be found! [OPERATING SYSTEM DETECTION]"
	exit 1
fi

###--------------------  STATIC IP ADDRESS CHECK  --------------------###
##
if command -v nmcli > /dev/null 2>&1; then
    CHECK_STATIC_IP_NMCLI
else
    echo "nmcli is not installed, using default method."
    INTERFACES=$(ip link show | grep 'state UP' | awk -F: '{print $2}' | tr -d ' ')
    for INTERFACE in $INTERFACES; do
        CHECK_STATIC_IP_DEFAULT "$INTERFACE"
    done
fi