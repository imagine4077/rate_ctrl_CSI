function [ ret ] = parse_all( path )
%PARSE_ALL Summary of this function goes here
%   Detailed explanation goes here
    ret.esnr = [];ret.prr = [];ret.rate=[];

    rateDirs = dir( path);
    for i=3:length(rateDirs)
        % every rate
        if(rateDirs(i).isdir ~= 1)
            continue;
        end
        
        dateDirs = dir(fullfile(path,rateDirs(i).name));
        for j=3:length(dateDirs)
            parse_one_path = fullfile(path,rateDirs(i).name,dateDirs(j).name);
            fprintf('%s:(%s)\n',rateDirs(i).name,dateDirs(j).name);
            [module, ant_mode, rate]=get_module(rateDirs(i).name);
            fprintf('\tmodule:%d\tant_mode:%d\trate:%f\n',module, ant_mode, rate);
            
            one_ret = parse_one(parse_one_path,ant_mode, module);
            ret.esnr = [ret.esnr;one_ret.esnr];
            ret.prr=[ret.prr;one_ret.prr];
            rate_arr=rate.*ones(size(one_ret.esnr));
            ret.rate=[ret.rate;rate_arr];
        end
    end
    
    fid = fopen(fullfile(path,'map.txt'),'at+');
    for k =1:length(ret.esnr)
        fprintf(fid,'%f,%f,%f\n',ret.esnr(k),ret.prr(k),ret.rate(k));
    end
    fclose(fid);

end

