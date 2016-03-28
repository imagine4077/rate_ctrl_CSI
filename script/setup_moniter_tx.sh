#!/usr/bin/sudo /bin/bash
modprobe -r iwlwifi mac80211 cfg80211
modprobe iwlwifi
#modprobe iwlwifi debug=0x40000
# Setup monitor mode, loop until it works
iwconfig wlan0 mode monitor 2>/dev/null 1>/dev/null
while [ $? -ne 0  ]
do
		iwconfig wlan0 mode monitor 2>/dev/null 1>/dev/null
done
iw dev wlan0 interface add mon0 type monitor
iw mon0 set channel $1 $2
ifconfig mon0 up

path_name=`sudo find /sys -name monitor_tx_rate`
#sudo find /sys -name monitor_tx_rate
echo $path_name
sudo echo $3 | sudo tee $path_name
sudo cat $path_name
echo -e '\n'
