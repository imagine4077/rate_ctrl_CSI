load('..\rawdata\distance\dis007_csi.mat')
fl=40;
myf=ones(fl,1)/fl;


[cfo,result]=phase_cali(csidata);
plot(csidata(:,1),angle(result(:,15)));


[cfo,result]=phase_cali2(csidata);
hold on
p=[];
for i=1:5:180; 
    p=[p conv(myf,(conv(myf,result(1.8e4:2e4,i))))];
end
plot(p(80:end-80,:));
