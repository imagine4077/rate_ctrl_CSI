function [ time, eSNR ] = draw_eSNR( file, module )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    csi_trace = read_bf_file(file);
    csi_trace = del_null(csi_trace);
    x = get_time(csi_trace);
    y = get_eSNR(csi_trace,module);
    %
    %y = slide_window(y,50);
%     if( draw ==1)
%         figure
%         plot(x,y,'-r');
%     end
    if(module==1) ber=normcdf(sqrt(y.*2)); end
    if(module==2) ber=normcdf(sqrt(y)); end
    if(module==3) ber=3/4*normcdf(sqrt(y./5)); end
    if(module==4) ber=7/12*normcdf(sqrt(y./21)); end
    figure;plot(x,ber,'r-');
    time = x;
    eSNR = y;
    save(strcat(file,'_eSNR.mat'),'eSNR');
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

function [ vec ] = get_csi( csi_trace, tx, rx, sc )
    vec=zeros([size(csi_trace,1) 1]);
    for i=1:size(vec,1)
        vec(i)=abs(csi_trace{i}.csi(tx,rx,sc));
    end 
end

function [ eSNR] = get_eSNR( csi_trace ,module)
%     eSNR = zeros( size( csi_trace));
    eSNR = [];
    len=length( csi_trace);
    for i=1:length( csi_trace)
        fprintf('%d/%d:\n',i,len);
%        eSNR = [ eSNR; get_eff_SNRs(csi_trace{i}.csi)];
       tmp = get_eff_SNRs(csi_trace{i}.csi);
       eSNR = [ eSNR; tmp(1,module)];
%        pause
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

