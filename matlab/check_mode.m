function check_mode( path )
% module -> col, mode(antanna mode) -> row
%   Detailed explanation goes here
    rateDirs = dir( path);
    for i=3:length(rateDirs)
        % every rate
        if(rateDirs(i).isdir ~= 1)
            continue;
        end
        
        dateDirs = dir(fullfile(path,rateDirs(i).name));
        file = fullfile(path,rateDirs(i).name,dateDirs(3).name,'csi.dat');
        fprintf('%s:(%s)\n',rateDirs(i).name,dateDirs(3).name);
        [module, ant_mode, rate]=get_module(rateDirs(i).name);
        fprintf('\tmodule:%d\tant_mode:%d\trate:%f\n',module, ant_mode, rate);
        
        csi_trace = read_bf_file(file);
        if(length(csi_trace)==0||isequal(csi_trace{1}, []))
            fprintf('NO CSI TRACE\n');
            continue;
        end
        tmp = get_eff_SNRs(csi_trace{1}.csi);
        tmp = db(tmp, 'pow');
        tmp
    end
end