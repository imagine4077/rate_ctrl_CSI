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
sudo pkill -9 dhcpd

#sudo killall dnsmasq

if [ ! -f /etc/apparmor.d/disable/usr.sbin.dhcpd ]; then
sudo ln -s /etc/apparmor.d/usr.sbin.dhcpd /etc/apparmor.d/disable/
sudo /etc/init.d/apparmor restart
fi

#sudo /etc/init.d/dnsmasq restart
# option routers 192.168.0.1;
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

   cat > /tmp/hostapd.conf << EOF
interface=wlan0
driver=nl80211
ssid=csitool
hw_mode=g
channel=6
#channel=5
auth_algs=1
#auth_algs=3
max_num_sta=255


logger_syslog=-1
logger_syslog_level=2
logger_stdout=-1
logger_stdout_level=2
#acs_num_scans=5
beacon_int=100

#start_disabled
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0

dtim_period=2

rts_threshold=2347
fragm_threshold=2346


wmm_enabled=1
wmm_ac_bk_cwmin=4
wmm_ac_bk_cwmax=10
wmm_ac_bk_aifs=7
wmm_ac_bk_txop_limit=0
wmm_ac_bk_acm=0

wmm_ac_be_aifs=3
wmm_ac_be_cwmin=4
wmm_ac_be_cwmax=10
wmm_ac_be_txop_limit=0
wmm_ac_be_acm=0

wmm_ac_vi_aifs=2
wmm_ac_vi_cwmin=3
wmm_ac_vi_cwmax=4
wmm_ac_vi_txop_limit=94
wmm_ac_vi_acm=0

wmm_ac_vo_aifs=2
wmm_ac_vo_cwmin=2
wmm_ac_vo_cwmax=3
wmm_ac_vo_txop_limit=47
wmm_ac_vo_acm=0

ieee80211n=1
own_ip_addr=127.0.0.1

ignore_broadcast_ssid=0

#radius_acct_interim_interval=600

ht_capab=SHORT-GI-40

macaddr_acl=0
#
# 如果需要开启密码，wpa=1。
wpa=0
wpa_passphrase=yc12345678
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
#wpa_group_rekey=6000
ap_table_max_size=255
EOF
   sudo hostapd -d /tmp/hostapd.conf
#sudo /home/wifitest/hostapd-0.6.8/hostapd/hostapd -B /tmp/hostapd.conf
