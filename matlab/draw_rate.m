function [ csi_trace ] = draw_rate( file )
%DRAW_RATE Summary of this function goes here
%   Detailed explanation goes here
    csi_trace = read_bf_file(file);
    csi_trace = del_null(csi_trace);
    save(strcat(file,'_rawCSI.mat'),'csi_trace');
%     load(strcat(file,'_rawCSI.mat'));
    arr=zeros(length(csi_trace),1);
    for i=1:1:length(csi_trace)
        arr(i)=csi_trace{i}.rate;
    end
    figure;
    plot(1:length(arr),arr,'r.');

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