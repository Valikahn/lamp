###################################################
##												 ##
##  MULTIPLE USE FUNCTIONS						 ##
##												 ##
###################################################


###--------------------  CHECK FOR STATIC IP ADDRESS  --------------------###
#
CHECK_STATIC_IP_DEFAULT() {
    IFACE=$(ip link show | awk -F': ' '/^[0-9]+: [^lo]/ {print $2; exit}')
    IP_DATA=$(ip -4 addr show dev $IFACE | grep 'inet ' | awk '{ print $2 }' | cut -d'/' -f1)
    if [ -n "$IP_DATA" ]; then
        IP_ADDRESS=$IP_DATA
        if grep -q "iface $IFACE inet static" /etc/network/interfaces 2>/dev/null || \
           grep -q "addresses:" /etc/netplan/* 2>/dev/null; then
            echo "Static IP is configured for interface $IFACE"
            echo "IP Address: $IP_ADDRESS"
            sleep 5
        else
            echo "Interface $IFACE is likely using DHCP (Dynamic IP)"
            echo "A static IP address will need to be configured."
            sleep 5
            source ./conf/static_ip.sh
        fi
    else
        clear
        echo "No IP address is assigned to interface $IFACE"
        echo "Script cannot continue until the adapter is online with an IP Address assigned."
        exit 1
    fi
}

CHECK_STATIC_IP_NMCLI() {
    INTERFACES=$(nmcli -t -f NAME,DEVICE connection show --active)
    while IFS= read -r LINE; do
        INTERFACE=$(echo "$LINE" | cut -d: -f2)
        IPV4_METHOD=$(nmcli -g ipv4.method connection show "$INTERFACE")
        if [ "$IPV4_METHOD" = "manual" ]; then
            echo "Static IP is configured for interface $INTERFACE"
            IP_ADDR=$(nmcli -g ip4.address connection show "$INTERFACE")
            echo "IP Address: $IP_ADDR"
            sleep 5
        else
            echo "Interface $INTERFACE is not configured with a static IP."
            sleep 5
            source ./conf/static_ip.sh
        fi
    done <<< "$INTERFACES"
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
    echo "Time's up! Rebooting!"
}
