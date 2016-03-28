#!/bin/bash

time=$(date +%y%m%d-%H%M%S)
sudo tcpdump -i mon0 -w pcap/${time}.pcap -Q out
#sudo tcpdump -i wlan0 -w pcap/${time}.pcap -Q in
