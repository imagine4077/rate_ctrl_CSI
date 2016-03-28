function [ retVec ] = allCSI_OneSubcarrier( path, x, y, z, draw)
% visit all directories under path, and extract all the
% CSI data which measure the specilized channel
fileDirs = dir( path);
retVec = [];
bar = waitbar(0,'Collecting Data');
for i=3:length(fileDirs)
    if(fileDirs(i).isdir ~= 1)
        continue;
    end
    str = strcat('Collecting Data',num2str(i),'/',num2str(length(fileDirs)));
    waitbar(i/length(fileDirs),bar,str);
    [tmpStruct.time,tmpStruct.csi] = CSI(fullfile(path,fileDirs(i).name,'csi.dat'),x,y,z,draw);
    tmpStruct.name = fileDirs(i).name;
    tmpStruct.mean = mean(tmpStruct.csi);
    tmpStruct.std = std(tmpStruct.csi);
    
    retVec = [ retVec; tmpStruct];
    clear tmpStruct;
end
close(bar);
end

function [ x, y ] = CSI( file, tx, rx, sc, draw)
    csi_trace = read_bf_file(file);
    csi_trace = del_null(csi_trace);
    x = get_time(csi_trace);
    y = get_csi(csi_trace, tx, rx, sc);
    y = slide_window(y,50);
    if( draw )
        figure
        plot(x,y,'-r');
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