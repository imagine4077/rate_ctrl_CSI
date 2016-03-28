#### 数据收集方式

* 所需设备：5300网卡PC × 2

收集方式：

1. 发送端运行 setup_monitor_tx.sh 64 HT20 0x4101
2. 接收端运行 setup_rc.sh 64 HT20
3. 发送端运行 ap.modified.sh, 接收端连接至ssid：csitool
4. 发送端运行GDB打开random_packets，调整tx_packet->txrate, 并在新terminal中运行tcpdump.sh
5. 接收端收取CSI信息，并在新terminal中运行tcpdump.sh

#### 目录位置

* ThinkPad T440 : /home/albert/Documents/CODE/lab_experiment/csi_predict/matlab

* 盒子： ~/linu..-supplementary/injection/

* X200 : ~/csitool/lin..-supplementary/injection
