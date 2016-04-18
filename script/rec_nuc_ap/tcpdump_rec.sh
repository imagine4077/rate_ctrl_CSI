#!/bin/bash

time=$(date +%y%m%d-%H%M%S)
echo $time".pcap"
#sudo tcpdump -i mon0 -w pcap/${time}.pcap -Q out
sudo tcpdump -i mon.wlan0 -w pcap/${time}.pcap -Q in -s 65535
