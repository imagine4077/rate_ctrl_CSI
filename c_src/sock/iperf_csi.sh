cd data
if [ ! -d $1 ];then
	mkdir $1
fi
cd $1
time=$(date +%y%m%d-%H%M%S)
mkdir ./${time}
echo ${time}
#sudo /home/wifitest/linux-80211n-csitool-supplementary/netlink/log_to_file ~/Documents/zw/data/${time}/csi.dat &
#iperf -s -i 0.5 -u| tee ~/Documents/zw/data/${time}/iperf.dat &
sudo /home/wifitest/linux-80211n-csitool-supplementary/netlink/log_to_file ./${time}/csi.dat &
iperf -s -i 1 -u| tee ./${time}/iperf.txt &
# sudo ./_clock.sh &
sleep 35
sudo killall iperf
while [ $? -ne 0 ]
do
	sudo killall iperf
done
sudo killall log_to_file
while [ $? -ne 0 ]
do
	sudo killall log_to_file
done
echo 'iperf_csi.sh Done'
exit
