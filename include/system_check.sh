###################################################
##												 ##
##  SYSTEM CHECK								 ##
##												 ##
###################################################


###--------------------  NETWORK MANAGER (NMCLI) CHECK  --------------------###
##
if command -v nmcli >/dev/null 2>&1; then
    NMCLI_DEV_SHOW
else
	ENS=$(ip link show | grep '^2:' | awk -F': ' '{ print $2 }' | grep '^ens')
    LIP=$(ip -4 addr show dev $ENS | grep 'inet ' | awk '{ print $2 }')
    DNS=$(grep -A 4 'nameservers:' /etc/netplan/*.yaml | grep '-' | awk '{ print $2 }' | paste -sd ',')
fi

###--------------------  PASSWORD COLLECTION  --------------------###
##
PSWD=$(PASSGEN)
ROOT_PASSWORD=$(PASSGEN)

###--------------------  CHECK FOR STATIC IP ADDRESS  --------------------###
#
IFACE=$(ip link show | awk -F': ' '/^[0-9]+: [^lo]/ {print $2; exit}')
IP_DATA=$(ip -4 addr show dev $IFACE | grep 'inet ' | awk '{ print $2 }' | cut -d'/' -f1)

if [ -n "$IP_DATA" ]; then
    IP_ADDRESS=$IP_DATA
    if grep -q "iface $IFACE inet static" /etc/network/interfaces 2>/dev/null || \
       grep -q "addresses:" /etc/netplan/* 2>/dev/null; then
        clear
        echo "Static IP is configured for interface $IFACE"
        COUNTDOWN 5
    else
        clear
        echo "Interface $IFACE is likely using DHCP (Dynamic IP)"
        echo "A static IP address is preferable when installing a LAMP server, for several reasons!"
        echo
        echo "Please note!  If connected using SSH, by continuing this could disrupt your connection and the installation will fail."
        echo
        echo -e "${RED}[  WARNING  ]${NORMAL} Continue at your own risk!"
        echo
        
        while true; 
        do
            read -rp "Would you like to configure a static IP address? (y/n)" CONF_STATIC_IP
            case "$CONF_STATIC_IP" in
                y|Y)
                    echo "Redirecting to static IP configuration..."
                    COUNTDOWN 5
                    source ./conf/static_ip.sh
                    break
                    ;;
                n|N)
                    echo "Proceeding without a static IP address... Redirecting..."
                    apt install -y network-manager > /dev/null 2>&1
                    apt install -y openvswitch-switch > /dev/null 2>&1
                    COUNTDOWN 5
                    break
                    ;;
                *)
                    echo "Please enter y/Y or n/N."
                    ;;
            esac
        done
    fi
else
    clear
    echo "No IP address is assigned to interface $IFACE"
    echo "Script cannot continue until the adapter is online with an IP Address assigned."
    exit 1
fi

###--------------------  COLLECTING SYSTEM DATA  --------------------###
##
clear

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
