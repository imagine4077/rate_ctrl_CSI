function [ ret ] = esnr2rate( dir_path ,ant_mode, module)
%ESNR2RATE Summary of this function goes here
%   Detailed explanation goes here
rec_fn = sprintf('%s/dump.pcap.thpt',dir_path)
cmd= sprintf('../C/main %s/dump.pcap 1 0',dir_path)
csi_fn = sprintf('%s/csi.dat',dir_path)

%% get PLR(packet loss rate)
system( cmd);
[rx_loss_rate, rx_thpt, first_ts] = textread(rec_fn,'%f,%fMbps,%s');

%% get packet eSNR

    csi_trace = read_bf_file(csi_fn);
    csi_trace = del_null(csi_trace);
    save(strcat(csi_fn,'_rawCSI.mat'),'csi_trace');
    time = get_time(csi_trace);
    eSNR = get_eSNR(csi_trace,module,ant_mode);
    eSNR_data.time=time;
    eSNR_data.esnr = eSNR;
    save(strcat(csi_fn,'_eSNR.mat'),'eSNR_data');
    
%% get second average eSNR
mean_esnr = [];
std_deviation = [];
upbound=floor(max(eSNR_data.time));
for i=1:upbound
    ind = find(eSNR_data.time<i & eSNR_data.time>=i-1 & eSNR_data.esnr~=Inf);
    mean_esnr = [mean_esnr;mean(eSNR_data.esnr( ind ))];
    std_deviation = [std_deviation; std2( eSNR_data.esnr(ind) )];
end
sesnr.mean_esnr = mean_esnr;
sesnr.std_deviation = std_deviation;
save(strcat(csi_fn,'_s_eSNR.mat'),'sesnr');

%% get ret struct
len=min(length(rx_loss_rate),length(mean_esnr));
ret.esnr = mean_esnr(1:len);
ret.prr = 1-rx_loss_rate(1:len);
save(fullfile(dir_path,'map.mat'),'ret');

end

function [ vec ] = get_time( csi_trace )
    vec=zeros([size(csi_trace,1) 1]);
    base=csi_trace{1}.timestamp_low;
    exp2=2^31;
    for i=1:size(csi_trace,1)
        vec(i)=csi_trace{i}.timestamp_low-base;
        if(vec(i)<0)
            vec(i)=vec(i)+exp2;
        end
    end
    vec=vec/1000000;
end

function [ eSNR] = get_eSNR( csi_trace ,module,mode)
%     eSNR = zeros( size( csi_trace));
    eSNR = [];
    
    if(length(csi_trace)~=0||~isequal(csi_trace{1}, []))
        tmp = get_eff_SNRs(csi_trace{1}.csi);
        tmp = db(tmp, 'pow');
        tmp
        fprintf('%f\n',tmp(mode,module));
    end
    
    for i=1:length( csi_trace)
       tmp = get_eff_SNRs(csi_trace{i}.csi);
       tmp = db(tmp, 'pow'); %new
       eSNR = [ eSNR; tmp(mode,module)];
    end
end

function [ vec_out ] = slide_window( vec_in, w_size )
    vec_out=zeros([size(vec_in,1) 1]);
    half_size=fix(w_size/2);
    for i=1:size(vec_in,1)
        low=max(1,i-half_size+1);
        high=min(size(vec_in,1),i+half_size);
        vec_out(i)=mean(vec_in(low:high));
    end 
end

function  [ csi_tr] = del_null( csi_trace)
% delete [] elements in CSI data
    len = length( csi_trace);
    flag = len;
    while( isequal(csi_trace{flag}, []))
        flag = flag- 1;
    end
    csi_tr = csi_trace(1:flag);
end