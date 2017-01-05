#### 数据收集方式

看这个帖子:[https://github.com/dhalperi/linux-80211n-csitool-supplementary/issues/88](https://github.com/dhalperi/linux-80211n-csitool-supplementary/issues/88)

* 所需设备：5300网卡PC × 2

收集方式：

1. 发送端(PC1)运行 setup_injection.sh 64 HT20 0x4101 (0x4101为MCS速率设置,可根据[CSITOOLS FAQ](http://dhalperi.github.io/linux-80211n-csitool/faq.html)中相关说明设置) 
2. 接收端（PC2）运行 setup_monitor_csi.sh 64 HT20
3. PC1和PC2需置于同一channel
3. 发送端(PC1)运行编译好的random_packets, 参数格式为:

```./random_packets <number> <packetLength> <mode: 0=my MAC, 1=injection MAC> <delay in us>```

4. 接收端(PC2)打开wireshark监听mon0即可收到所发的packet.

#### 目录位置

* ThinkPad T440 : /home/albert/Documents/CODE/lab_experiment/csi_predict/ 

* 盒子： ~/linu..-supplementary/injection/

* X200 : ~/csitool/lin..-supplementary/injection/
