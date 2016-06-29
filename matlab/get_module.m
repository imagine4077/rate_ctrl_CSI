function [ module, ant_mode, rate ] = get_module( rate_str )
%GET_MODULE Summary of this function goes here
%   Detailed explanation goes here
bpsk = 1;
qpsk = 2;
qam16 = 3;
qam64 = 4;
switch rate_str
    case '1c100'
        module=bpsk;ant_mode=1;rate=6.5;return;
    case '4100'
        module=bpsk;ant_mode=1;rate=6.5;return;
    case '1c101'
        module=qpsk;ant_mode=1;rate=13;return;
    case '4101'
        module=qpsk;ant_mode=1;rate=13;return;
    case '1c102'
        module=qpsk;ant_mode=1;rate=19.5;return;
    case '4102'
        module=qpsk;ant_mode=1;rate=19.5;return;
    case '1c103'
        module=qam16;ant_mode=1;rate=26;return;
    case '4103'
        module=qam16;ant_mode=1;rate=26;return;
    case '1c104'
        module=qam16;ant_mode=1;rate=39;return;
    case '4104'
        module=qam16;ant_mode=1;rate=39;return;
    case '1c105'
        module=qam64;ant_mode=1;rate=52;return;
    case '4105'
        module=qam64;ant_mode=1;rate=52;return;
    case '1c106'
        module=qam64;ant_mode=1;rate=58.5;return;
    case '4106'
        module=qam64;ant_mode=1;rate=58.5;return;
    case '1c107'
        module=qam64;ant_mode=1;rate=65;return;
    case '4107'
        module=qam64;ant_mode=1;rate=65;return;
    case '1c108'
        module=bpsk;ant_mode=4;rate=13;return;
    case '1c109'
        module=qpsk;ant_mode=4;rate=26;return;
    case '1c10a'
        module=qpsk;ant_mode=4;rate=39;return;
    case '1c10b'
        module=qam16;ant_mode=4;rate=52;return;
    case '1c10c'
        module=qam16;ant_mode=4;rate=78;return;
    case '1c10d'
        module=qam64;ant_mode=4;rate=104;return;
    case '1c10e'
        module=qam64;ant_mode=4;rate=117;return;
    case '1c10f'
        module=qam64;ant_mode=4;rate=130;return;
    case '1c110'
        module=bpsk;ant_mode=7;rate=19.5;return;
    case '1c111'
        module=qpsk;ant_mode=7;rate=39;return;
    case '1c112'
        module=qpsk;ant_mode=7;rate=58.5;return;
    case '1c113'
        module=qam16;ant_mode=7;rate=78;return;
    case '1c114'
        module=qam16;ant_mode=7;rate=117;return;
    case '1c115'
        module=qam64;ant_mode=7;rate=156;return;
    case '1c116'
        module=qam64;ant_mode=7;rate=175.5;return;
    case '1c117'
        module=qam64;ant_mode=7;rate=195;return;
end


end

