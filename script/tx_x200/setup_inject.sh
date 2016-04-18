#!/usr/bin/sudo /bin/bash
modprobe -r iwlwifi mac80211 cfg80211
sudo modprobe iwlwifi connector_log=0x1
sudo modprobe iwlwifi debug=0x40000
ifconfig wlan0 2>/dev/null 1>/dev/null
while [ $? -ne 0 ]
do
	        ifconfig wlan0 2>/dev/null 1>/dev/null
done
iw dev wlan0 interface add mon0 type monitor
iw mon0 set channel $1 $2
ifconfig mon0 up
#sudo find /sys -name monitor_tx_rate
echo $3 | sudo tee `find /sys -name monitor_tx_rate`
sudo cat `find /sys -name monitor_tx_rate`
