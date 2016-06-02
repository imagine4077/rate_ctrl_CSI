date +%H-%M-%S
iperf -u -s -i 1 &
sleep 3
sudo killall iperf
