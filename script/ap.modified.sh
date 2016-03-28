#!/bin/bash

#● ai hostapd dhcp3-server
#sudo rmmod iwlwifi mac80211 cfg80211
#sudo modprobe iwlwifi connector_log=0x1
iw list|grep '* AP'
[ $? -ne 0 ] && echo "No device support AP mode." && exit

sudo ifconfig wlan0 192.168.0.2 netmask 255.255.255.0
#sudo ifconfig eth1 10.1.1.2 netmask 255.0.0.0
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
#sudo iptables -t nat -A PREROUTING -s 192.168.1.0/24 -i eth1 -j DNAT --to 10.1.1.2
#sudo pkill -9 dhcpd
sudo killall dhcpd

#sudo killall dnsmasq

if [ ! -f /etc/apparmor.d/disable/usr.sbin.dhcpd ]; then
sudo ln -s /etc/apparmor.d/usr.sbin.dhcpd /etc/apparmor.d/disable/
sudo /etc/init.d/apparmor restart
fi

#sudo /etc/init.d/dnsmasq restart

cat > /tmp/dhcpd.conf << EOF
#ddns-update-style none;
ignore client-updates;
default-lease-time 600;
max-lease-time 7200;
subnet 192.168.0.0 netmask 255.255.255.0{
 range 192.168.0.3 192.168.0.250;
 option domain-name-servers 8.8.8.8;
 option routers 192.168.0.1;
 option broadcast-address 192.168.0.255;
}
EOF
   sudo dhcpd wlan0 -cf /tmp/dhcpd.conf -pf /var/run/dhcp-server/dhcpd.pid

sudo cp /home/wifitest/linux-80211n-csitool-supplementary/hostap-config-files/hostapd.conf-real /tmp/hostapd.conf

   sudo hostapd -d /tmp/hostapd.conf
#sudo /home/wifitest/hostapd-0.6.8/hostapd/hostapd -B /tmp/hostapd.conf
