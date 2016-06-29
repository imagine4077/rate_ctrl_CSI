function [ ts_arr ] = plot_ts( fi )
%PLOT_TS Summary of this function goes here
%   Detailed explanation goes here
    [ ts_arr ] = textread(fi,'%f');
    y = ones(length(ts_arr),1);
    figure;
    plot(ts_arr,y,'bx');
    xlabel('usec');

end

