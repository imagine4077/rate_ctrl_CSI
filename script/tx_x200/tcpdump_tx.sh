#!/bin/bash

time=$(date +%y%m%d-%H%M%S)
echo $time".pcap"
sudo tcpdump -i mon0 -w pcap/${time}.pcap -Q out -s 65535
#sudo tcpdump -i wlan0 -w pcap/${time}.pcap -Q in
