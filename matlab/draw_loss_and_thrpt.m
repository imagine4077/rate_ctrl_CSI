% tx_fn='../data/160425-125538.13.1k/0x4101.13mbps/160425-125531.pcap.thpt';
% rec_fn = '../data/160425-125538.13.1k/dump.pcap.thpt';
% load('/home/albert/Documents/CODE/lab_experiment/csi_predict/data/160425-125538.13.1k/csi.dat_eSNR.mat')
% csi_fn= '../data/160424-213829/csi.dat';
% pic_name = '160425-125538.13.1k';

% tx_fn='../data/160509-150505/tx.pcap.thpt';
% rec_fn = '../data/160509-150505/dump.pcap.thpt';
% load('/home/albert/Documents/CODE/lab_experiment/csi_predict/data/160509-150505/csi.dat_eSNR.mat')
pic_name = '160510-132841';
%pic_name='160529/160529-174720/160529-174723';

tx_fn=strcat('../data/',pic_name,'/tx.pcap.thpt');
rec_fn = strcat('../data/',pic_name,'/dump.pcap.thpt');
load(strcat('../data/',pic_name,'/csi.dat_eSNR.mat'));

[tx_num, tx_thpt] = textread(tx_fn,'%f,%fMbps');
[rec_num, rec_thpt] = textread(rec_fn,'%f,%fMbps');

len = min(length(tx_num),length(rec_num));
loss_rate = zeros(len,1);
i=1;
while(i<=len)
   loss_rate(i) = 1-rec_num(i); 
   i = i+1;
end

x=1:len;
figure('name',pic_name);
subplot(4,1,1),plot(x(1:len-1),tx_thpt(1:len-1),'r-',x(1:len-1),rec_thpt(1:len-1),'g-'),title('throughput'),
legend('tx','rx');
% subplot(4,1,2),plot(x(1:len-1),loss_rate(1:len-1),'r-'),title('loss rate');
subplot(4,1,2),plot(x(1:len-1),rec_num(1:len-1),'r-'),title('PRR');
subplot(4,1,3),plot(eSNR_data.time,eSNR_data.esnr,'r-'),xlim([0,len]),title('eSNR');

%% new average eSNR
mean_esnr = [];
upbound=floor(max(eSNR_data.time));
for i=1:upbound
    mean_esnr = [mean_esnr;mean(eSNR_data.esnr( find(eSNR_data.time<i & eSNR_data.time>=i-1 & eSNR_data.esnr~=Inf) ))];
end
subplot(4,1,4),plot(1:length(mean_esnr),mean_esnr,'r-'),title('average eSNR');