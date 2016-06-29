function [ cfo, result ] = phase_cali( csidata )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

cfo=[];
result=[];
timediff=diff(csidata(:,1));
pid=1;
for i=16:30:166 %only use the center part
    anglediff=diff(angle(csidata(:,i)));
    anglediff=anglediff+(anglediff>pi)*(-2*pi)+(anglediff<-pi)*(2*pi);

    phasediff=[];
    lastphase=0;
    phaseadj=0;
    for t=3.5e-4:1e-6:4e-4
        tid=find(abs(timediff-t)<0.5e-6);
        tempdata=[];
        tempdata(2,:)=anglediff(tid)+phaseadj;
        tempdata(1,:)=t;   
        
        %first move data to their mean
        meandata=mean(tempdata(2,:));
        tempdata(2,:)=tempdata(2,:)-((tempdata(2,:)-meandata)>pi)*2*pi+((tempdata(2,:)-meandata)<-pi)*2*pi;
        %adjust the phase
        if(lastphase-mean(tempdata(2,:))<-pi)
            phaseadj=phaseadj-2*pi;
            tempdata(2,:)=tempdata(2,:)-2*pi;
        elseif(lastphase-mean(tempdata(2,:))>pi)
            phaseadj=phaseadj+2*pi;
            tempdata(2,:)=tempdata(2,:)+2*pi;
        end
        lastphase=mean(tempdata(2,:));
        phasediff=[phasediff tempdata];
    end
    %scatter(phasediff(1,:),phasediff(2,:),1);
    %axis([3.5e-4 4.0e-4 min(phasediff(2,:)) max(phasediff(2,:))]);
    X=[ones(length(phasediff(1,:)),1) phasediff(1,:)'];
    b=X\(phasediff(2,:)');
    cfo(pid)=b(2);
    pid=pid+1;
    %pause
end

calicfo=csidata(:,15).*exp(-csidata(:,1)*mean(cfo)*1i);

caliphase=phase(calicfo);
cfo=cfo+(caliphase(end)-caliphase(1))/(csidata(end,1)-csidata(1,1));
for i=2:181
    result(:,i-1)=csidata(:,i).*exp(-csidata(:,1)*mean(cfo)*1i);
end

for i=1:180
    presult(:,i)=phase(result(:,i));
end
p=mean(presult,2);
fl=200;
myf=ones(fl,1)/fl;
p=conv(p,myf,'same');
for i=1:180
    result(:,i)=result(:,i).*exp(-p*1i);
end

end

