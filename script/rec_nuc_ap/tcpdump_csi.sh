time=$(date +%y%m%d-%H%M%S)
#cd pcap
mkdir ./${time}
echo ${time}
#sudo /home/wifitest/linux-80211n-csitool-supplementary/netlink/log_to_file ~/Documents/zw/data/${time}/csi.dat &
#iperf -s -i 0.5 -u| tee ~/Documents/zw/data/${time}/iperf.dat &
sudo /home/wifitest/linux-80211n-csitool-supplementary/netlink/log_to_file ./${time}/csi.dat &
sudo tcpdump -i wlan0 -w ./${time}/dump.pcap -Q in -s 63 ether host 00:16:ea:12:34:56 &
# sudo ./_clock.sh &
sleep 120
sudo killall tcpdump
sudo killall log_to_file
echo 'tcpdump_csi.sh Done'
exit
