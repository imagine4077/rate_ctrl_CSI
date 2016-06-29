function [ time,bers_arr ] = draw_BER( file, module )
%DRAW_BER Compute the BER values from a CSI matrix
%   Note that the matrix is expected to have dimensions M x N x S, where
%      M = # TX antennas
%      N = # RX antennas
%      S = # subcarriers
    csi_trace = read_bf_file(file);
    csi_trace = del_null(csi_trace);
    x = get_time(csi_trace);
    time = x;
    
    bers_arr = [];
    len=length(csi_trace);
    for i=1:length( csi_trace)
        fprintf('%d/%d:\n',i,len);
        csi=csi_trace{i}.csi;
    
 %   ret = zeros(7,4) + eps; % machine epsilon is smallest possible SNR

%    [M N S] = size(csi);  % If next line doesn't compile
    [M N ~] = size(csi);
    k = min(M,N);

    % Do the various SIMO configurations (i.e., TX antenna selection)
    if k >= 1
        snrs = get_simo_SNRs(csi);

        bers = bpsk_ber(snrs);
        mean_ber = mean(mean(bers, 3), 2);
        ret((1:length(mean_ber)),1) = bpsk_berinv(mean_ber);

        bers = qpsk_ber(snrs);
        mean_ber = mean(mean(bers, 3), 2);
        ret((1:length(mean_ber)),2) = qpsk_berinv(mean_ber);

        bers = qam16_ber(snrs);
        mean_ber = mean(mean(bers, 3), 2);
        ret((1:length(mean_ber)),3) = qam16_berinv(mean_ber);

        bers = qam64_ber(snrs);
        mean_ber = mean(mean(bers, 3), 2)
        ret((1:length(mean_ber)),4) = qam64_berinv(mean_ber);
    end

    % Do the various MIMO2 configurations (i.e., TX antenna selection)
    if k >= 2
        snrs = get_mimo2_SNRs(csi);

        bers = bpsk_ber(snrs);
        mean_ber = mean(mean(bers, 3), 2);
        ret(3+(1:length(mean_ber)),1) = bpsk_berinv(mean_ber);

        bers = qpsk_ber(snrs);
        mean_ber = mean(mean(bers, 3), 2);
        ret(3+(1:length(mean_ber)),2) = qpsk_berinv(mean_ber);

        bers = qam16_ber(snrs);
        mean_ber = mean(mean(bers, 3), 2);
        ret(3+(1:length(mean_ber)),3) = qam16_berinv(mean_ber);

        bers = qam64_ber(snrs);
        mean_ber = mean(mean(bers, 3), 2);
        ret(3+(1:length(mean_ber)),4) = qam64_berinv(mean_ber);
    end

    % Do the MIMO3 configuration
    if k >= 3
        snrs = get_mimo3_SNRs(csi);

        bers = bpsk_ber(snrs);
        mean_ber = mean(mean(bers, 3), 2);
        ret(6+(1:length(mean_ber)),1) = bpsk_berinv(mean_ber);

        bers = qpsk_ber(snrs);
        mean_ber = mean(mean(bers, 3), 2);
        ret(6+(1:length(mean_ber)),2) = qpsk_berinv(mean_ber);

        bers = qam16_ber(snrs);
        mean_ber = mean(mean(bers, 3), 2);
        ret(6+(1:length(mean_ber)),3) = qam16_berinv(mean_ber);

        bers = qam64_ber(snrs);
        mean_ber = mean(mean(bers, 3), 2);
        ret(6+(1:length(mean_ber)),4) = qam64_berinv(mean_ber);
    end

    % Apparently, sometimes it can be infinite so cap it at 40 dB
    %ret(ret==Inf) = dbinv(40);
    end
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
