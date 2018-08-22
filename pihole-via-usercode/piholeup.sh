#!/bin/bash
echo "setting up pihole via usercode"
echo "------------------------------"
PIHOLE_DIR=/etc/pihole
mkdir -p $PIHOLE_DIR

# script used to detect the ip
cat <<'EOF' > $PIHOLE_DIR"/detect_ip.sh"
#!/bin/bash
route=$(ip route get 8.8.8.8)
IPv4dev=$(awk '{for (i=1; i<=NF; i++) if ($i~/dev/) print $(i+1)}' <<< "${route}")
IPv4bare=$(awk '{print $7}' <<< "${route}")
IPV4_ADDRESS=$(ip -o -f inet addr show | grep "${IPv4bare}" |  awk '{print $4}' | awk 'END {print}')
echo $IPV4_ADDRESS
EOF
chmod a+x $PIHOLE_DIR"/detect_ip.sh"

# script used to detect the network
cat <<'EOF' > $PIHOLE_DIR"/detect_network.sh"
#!/bin/bash
echo $(ip --oneline link show up | grep -v "lo" | grep -v "wlan" | awk '{print $2}' | cut -d':' -f1 | cut -d'@' -f1 | head -1)
EOF
chmod a+x $PIHOLE_DIR"/detect_network.sh"

# write list of adlists we are going to use for pihole
cat <<EOF > $PIHOLE_DIR"/adlists.list"
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://mirror1.malwaredomains.com/files/justdomains
http://sysctl.org/cameleon/hosts
https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist
https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
https://hosts-file.net/ad_servers.txt
EOF
echo $PIHOLE_DIR"/adlists.list" 
echo "------------------------------"
cat $PIHOLE_DIR"/adlists.list"
echo "------------------------------"

# write the setupVars pihole file needed for unattended install
cat <<EOF > $PIHOLE_DIR"/setupVars.conf"
PIHOLE_INTERFACE=$($PIHOLE_DIR"/detect_network.sh")
IPV4_ADDRESS=$($PIHOLE_DIR"/detect_ip.sh")
IPV6_ADDRESS=
PIHOLE_DNS_1=8.8.8.8
PIHOLE_DNS_2=8.8.4.4
QUERY_LOGGING=true
INSTALL_WEB_SERVER=true
INSTALL_WEB_INTERFACE=true
LIGHTTPD_ENABLED=true
WEBPASSWORD=f8e65f4be87d281b7d9fd0cb7a541182b60ce02bca8f70b5ae909c65e81ebde9
EOF
echo $PIHOLE_DIR"/setupVars.conf" 
echo "------------------------------"
cat $PIHOLE_DIR"/setupVars.conf"
echo "------------------------------"

# run the installer script
echo "running the pihole unattended setup script"
echo "------------------------------"
curl -sSL https://install.pi-hole.net > /tmp/piholesetup.sh
chmod +x /tmp/piholesetup.sh
/tmp/piholesetup.sh --unattended
echo "------------------------------"