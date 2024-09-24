###################################################
##												 ##
##  STATIC IP ADDRESS							 ##
##												 ##
###################################################


clear
###--------------------  IP ADDRESS ENTRY / CHECK RECALL FUNCTION  --------------------###
##
while true;
do
read -p "Enter the static IP address to set (e.g., 192.168.1.100): " STATIC_IP
    if VALID_IP_ADDRESS $STATIC_IP; then
        break
    else
        echo "Invalid IP address format: $STATIC_IP"
    fi
done

while true;
do
read -p "Enter the default gateway (e.g., 192.168.1.1): " GATEWAY
    if VALID_IP_ADDRESS $GATEWAY; then
        break
    else
        echo "Invalid IP address format: $GATEWAY"
    fi
done

while true; do
    read -p "Enter DNS servers (comma-separated, e.g., 8.8.8.8,8.8.4.4): " DNS
    IFS=',' read -ra DNS_ARRAY <<< "$DNS"
    ALL_VALID_ENTRIES=1  # Assume all IPs are valid initially

    for DNS_IP in "${DNS_ARRAY[@]}"; do
        if ! VALID_IP_ADDRESS "$DNS_IP"; then
            echo "Invalid IP address format: $DNS_IP"
            ALL_VALID_ENTRIES=0  # Set flag to false if any IP is invalid
        fi
    done

    if [ "$ALL_VALID_ENTRIES" -eq 1 ]; then
        echo "All DNS entered IP addresses are valid."
        break  # Exit the while loop since all IPs are valid
    else
        echo "Please enter valid IP addresses."
    fi
done

read -p "Enter the subnet mask in CIDR notation (e.g., 24 for 255.255.255.0): " CIDR

###--------------------  GATHERED DATA  --------------------###
##
INTERFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n 1)

echo
echo "Setting up static IP address:"
echo
echo "IP Address: $STATIC_IP"
echo "Subnet Mask CIDR: $CIDR"
echo "Gateway: $GATEWAY"
echo "DNS Servers: $DNS"
echo "Network Interface: $INTERFACE"
echo

CONFIRM_YES_NO


###################################################
##												 ##
##  SCRIPT RUN									 ##
##												 ##
###################################################


###--------------------  UPDATE SYSTEM AND INSTALL NETWORK MANAGER  --------------------###
##
echo "${GREEN}[ 1. ] INSTALL NETWORK MANAGER AND OPEN VSWITCH AND AUTOSSH${NORMAL}"
apt install -y network-manager > /dev/null 2>&1
apt install -y openvswitch-switch > /dev/null 2>&1
#apt install -y autossh > /dev/null 2>&1

###--------------------  DISABLE SYSTEM NETWORKD SERVICE WAIT WHILE BOOT  --------------------###
##
echo "${GREEN}[ 2. ] DISABLE SYSTEM NETWORKD SERVICE WAIT WHILE BOOT  ]${NORMAL}"
systemctl disable systemd-networkd-wait-online.service > /dev/null 2>&1

###--------------------  EDIT GLOBALLY MANAGED DEVICES  --------------------###
##
echo "${GREEN}[ 3. ] EDIT GLOBALLY MANAGED DEVICES${NORMAL}"
CONF_FILE="/usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf"
tee $CONF_FILE > /dev/null <<EOL
[keyfile]
unmanaged-devices=*,except:type:wifi,except:type:gsm,except:type:cdma,except:type:ethernet,except:type:wireguard
EOL

###--------------------  EDIT NETWORK MANAGER  --------------------###
##
echo "${GREEN}[ 4. ] EDIT NETWORK MANAGER${NORMAL}"
NM_CONF="/etc/NetworkManager/NetworkManager.conf"
    if grep -q "\[ifupdown\]" $NM_CONF; then
      sed -i '/\[ifupdown\]/,/\[/{s/managed=false/managed=true/}' $NM_CONF
    else
      echo -e "\n[ifupdown]\nmanaged=true" | sudo tee -a $NM_CONF > /dev/null 2>&1
    fi

###--------------------  DISABLE CLOUD-INIT NETWORK CONFIGURATION  --------------------###
##
echo "${GREEN}[ 5. ] DISABLE CLOUD-INIT NETWORK CONFIGURATION${NORMAL}"
CLOUD_CFG="/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"
tee $CLOUD_CFG > /dev/null 2>&1 <<EOL
network: {config: disabled}
EOL

###--------------------  RESTART NETWORK MANAGER  --------------------###
##
echo "${GREEN}[ 6. ] RESTART NETWORK MANAGER${NORMAL}"
systemctl restart NetworkManager > /dev/null 2>&1

###--------------------  CONFIGURE NETWORK INTERFACE USING NMCLI  --------------------###
##
echo "${GREEN}[ 7. ] CONFIGURE NETWORK INTERFACE USING NMCLI${NORMAL}"

INTERFACE=$(ip link show | grep '^2:' | awk -F': ' '{ print $2 }' | grep '^ens')
OLD_IP=$(ip -4 addr show dev $ENS | grep 'inet ' | awk '{ print $2 }')

ip addr add $NEW_IP dev $ENS > /dev/null 2>&1
nmcli con mod $ENS ipv4.gateway $GATEWAY > /dev/null 2>&1
nmcli con mod $ENS ipv4.dns $DNS > /dev/null 2>&1
nmcli con mod $ENS ipv4.method manual > /dev/null 2>&1
nmcli con up $ENS > /dev/null 2>&1

###--------------------  REMOVE NETPLAN FILES AND CREATE A NEW  --------------------###
##
echo "${GREEN}[ 8. ] REMOVE NETPLAN FILES AND CREATE A NEW${NORMAL}"
rm -rf /etc/netplan/* > /dev/null 2>&1
NETPLAN_FILE="/etc/netplan/00-installer-config.yaml" > /dev/null 2>&1

sudo tee $NETPLAN_FILE > /dev/null 2>&1 <<EOL
## This is the network config written by Neil Jamieson for Insentrica Lab!
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    $INTERFACE:
      dhcp4: no
      addresses:
      - $STATIC_IP/$CIDR
      nameservers:
        addresses:
$(IFS=','; for ip in $DNS; do echo "        - $ip"; done)
      routes:
      - to: default
        via: $GATEWAY
EOL

###--------------------  NETPLAN SECURE AND APPLY  --------------------###
##
echo "${GREEN}[ 9. ] NETPLAN SECURE AND APPLY${NORMAL}"
sudo chmod 600 /etc/netplan/00-installer-config.yaml
sudo netplan apply

###--------------------  EXECUTION COMPLETE  --------------------###
##
echo "${GREEN}[ 10. ] EXECUTION COMPLETE${NORMAL}"
systemctl restart NetworkManager
