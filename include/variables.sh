###################################################
##												 ##
##  VARIABLES									 ##
##												 ##
###################################################


###--------------------  COLORS DECLARE  --------------------###
##
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)
LBLUE=$(tput setaf 6)
RED=$(tput setaf 1)
PURPLE=$(tput setaf 5)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BBLACK=$(tput setaf 8)
BRED=$(tput setaf 9)
BGREEN=$(tput setaf 10)
BYELLOW=$(tput setaf 11)
BBLUE=$(tput setaf 12)
BMAGENTA=$(tput setaf 13)
BCYAN=$(tput setaf 14)
BWHITE=$(tput setaf 15)

###--------------------  BLINK DECLARE  --------------------###
##
BLINK=$(tput blink)
RESET=$(tput sgr0)

###--------------------  VERSIONING --------------------###
##
SCRIPTVERSION="v24.9.23"
BUILD="011-ALPHA"
REVDATE="23 September 2024"
FILENAME="maws_hp2v48.$SCRIPTVERSION.linux.deb.sh"

###--------------------  HOST DATA COLLECTION  --------------------###
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

HST=$(hostname)
IP_ADDRESS=$(ip addr show $ENS | grep -oP 'inet \K[\d.]+')
USER_NAME=$(w -h | awk '{print $1}' | head -n 1)