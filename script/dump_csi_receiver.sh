#!/bin/bash

time=$(date +%y%m%d-%H%M%S)
mkdir data/${time}

sudo gnome-terminal -e "sudo tcpdump -i mon0 -w data/${time}/dump.pcap -Q in"
sudo /home/wifitest/linux-80211n-csitool-supplementary/netlink/log_to_file data/${time}/csi.dat
