tx_fn='../data/pcap/160418-1959/tx/160418-195911.pcap.dat';
rec_fn='../data/pcap/160418-1959/rec/160418-195913.pcap.dat';

rec_fn='../data/pcap/160418-2138/rec/160418-213417.pcap.dat';
tx_fn = '../data/pcap/160418-2138/tx/160418-213416.pcap.dat';
pic_name = '160418-2138';

[tx_num, tx_thpt] = textread(tx_fn,'%u,%fMbps');
[rec_num, rec_thpt] = textread(rec_fn,'%u,%fMbps');

len = min(length(tx_num),length(rec_num));
loss_rate = zeros(len,1);
i=1;
while(i<=len)
   loss_rate(i) = 1-rec_num(i)/tx_num(i); 
   i = i+1;
end

x=1:len;
figure('name',pic_name);
subplot(2,1,1),plot(x(1:len-1),tx_thpt(1:len-1),'r-',x(1:len-1),rec_thpt(1:len-1),'g-'),title('throughput'),
legend('tx','rec');
subplot(2,1,2),plot(x(1:len-1),loss_rate(1:len-1),'r-'),title('loss rate');