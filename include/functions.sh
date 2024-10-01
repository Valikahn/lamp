###################################################
##												 ##
##  MULTIPLE USE FUNCTIONS						 ##
##												 ##
###################################################


###--------------------  SUDO/ROOT CHECK  --------------------###
##
SUDO_CHECK() {
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
}

###--------------------  VALID IP ADDRESS CHECK  --------------------###
##
VALID_IP_ADDRESS() {
    local ip=$1
    local stat=1

    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

###--------------------  NMCLI CONFIGURATOIN  --------------------###
##
NMCLI_DEV_SHOW() {
    ENS=$(nmcli dev status | grep '^ens' | awk '{ print $1 }')
    DOM=$(nmcli dev status | grep '^ens' | awk '{ print $4 }')
    LIP=$(nmcli -f ipv4.addresses con show $DOM | awk '{ print $2 }')
    DNS=$(nmcli -f ipv4.dns con show $DOM | awk '{ print $2 }' | paste -sd ',')
    HST=$(hostname)
    IP_ADDRESS=$(ip addr show $ENS | grep -oP 'inet \K[\d.]+')
    USER_NAME=$(w -h | awk '{print $1}' | head -n 1)
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

###--------------------  CONFIRM_YES_NO  --------------------###
#
CONFIRM_YES_NO () {
while true;
	do
	read -p "Please confirm you're happy to proceed? (Yy/Nn): " CONFIRM
    echo
    if [[ "$CONFIRM" == "Y" ]] || [[ "$CONFIRM" == "y" ]] || [[ "$CONFIRM" == "YES" ]] || [[ "$CONFIRM" == "yes" ]] || [[ "$CONFIRM" == "Yes" ]]; then
		break
    elif [[ "$CONFIRM" == "N" ]] || [[ "$CONFIRM" == "n" ]] || [[ "$CONFIRM" == "NO" ]] || [[ "$CONFIRM" == "no" ]] || [[ "$CONFIRM" == "No" ]]; then
	    clear
        exit
    else
	    echo "Invalid choice - try again please. Enter 'Yy' or 'Nn'."
	    echo
    fi
done
}

###--------------------  COUNTDOWN  --------------------###
#
COUNTDOWN() {
    local SECS=$1
    while [ $SECS -gt 0 ]; do
        echo -ne "$SECS\033[0K\r"
        sleep 1
        : $((SECS--))
    done
}
