function [ cfo, result ] = phase_cali2( csidata )
cfo=[];
result=[];
subcarriers=[-28,-26,-24,-22,-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,-1,1,3,5,7,9,11,13,15,17,19,21,23,25,27,28];

for i=1:6
    id=i*30-15;
    p(i)=mean(abs(csidata(:,id+1)));    
end
%find the best antenna, larger abs, smaller changes caused by movement
[Y id]=max(p);
anglecali=(angle(csidata(:,id*30-15+1))+angle(csidata(:,id*30-15+1)))/2; %use subcarrier 0

%remove the CFO
for i=2:181
    result(:,i-1)=csidata(:,i).*exp(-anglecali*1i);
end

%remove sampling offset
X=[ones(30,1) subcarriers']; %prepare linear regression;
cfo=zeros(size(csidata,1),1);
for i=1:size(csidata,1) % do this for each sample, it takes time
    %t=zeros(6,1);
    %for j=id
    
    %donot use the subcarriers on the edge
    skip=2;
        b=X(1+skip:end-skip,:)\phase(result(i,30*id-29+skip:30*id-skip))';
    %    t(j)=b(2);
    %    cfo(i,j)=b(2);
    %end
    t=b(2);
    cfo(i)=t;
    for j=1:6
        result(i,30*j-29:30*j)=result(i,30*j-29:30*j).*exp(-subcarriers*t*1i);
    end
end
end