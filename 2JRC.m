clear;
close all;
clc;
load JointdataN.mat;%
for i=1:3
    m=max(cell2mat(jointdataN{i,1}(:,3)));
    for j=1:m
        if ~isempty(jointdataN{i,1}{j,9})
            [D,ind_D]=sortrows(jointdataN{i,1}{j,9},2);
            L=max(D(:,2))-min(D(:,2));
            n=size(D,1);
            d=0;
            for k=2:n
                a=(D(k,3)-D(k-1,3))^2;
                b=D(k,2)-D(k-1,2);
                c=a/b;
                d=d+c;
            end
            Z2=abs(sqrt(d/L));
            jointdataN{i,1}{j,10}=Z2;
            JRC2D=32.2+34.27*log10(Z2);
            jointdataN{i,1}{j,11}=JRC2D;
        end
    end
end
jointdataNnew=jointdataN;
for i=1:3
    m=max(cell2mat(jointdataNnew{i,1}(:,3)));
    for j=1:m
        if ~isempty(jointdataNnew{i,1}{j,9})
            [D,ind_D]=sortrows(jointdataNnew{i,1}{j,9},2);
            jointdataNnew{i,1}{j,12}=D(:,2:3);
            a1=jointdataNnew{i,1}{j,12}(:,1);
            a2=jointdataNnew{i,1}{j,12}(:,2);
            maxy=max(a1);
            miny=min(a1);
            maxz=max(a2);
            minz=min(a2);
            sp=(1/50)*(maxy-miny);
            Y=miny:sp:maxy;
            Z=interp1(a1,a2,Y,"linear");
            jointdataNnew{i,1}{j,13}(:,1)=Y;
            jointdataNnew{i,1}{j,13}(:,2)=Z;
        end
    end
end
figure;
plot(jointdataNnew{2,1}{36,12}(:,1),jointdataNnew{2,1}{36,12}(:,2),'.r');
grid on;
set(gca,'fontname','Times New Roman','fontsize',14);
xlabel(gca,'X (m)','fontname','Times New Roman','fontsize',16 );
ylabel(gca,'Y (m)','fontname','Times New Roman','fontsize',16 );
axis equal;
figure;
plot(jointdataNnew{2,1}{36,13}(:,1),jointdataNnew{2,1}{36,13}(:,2),'.g');
grid on;
set(gca,'fontname','Times New Roman','fontsize',14);
xlabel(gca,'X (m)','fontname','Times New Roman','fontsize',16 );
ylabel(gca,'Y (m)','fontname','Times New Roman','fontsize',16 );
axis equal;
figure;
plot(jointdataNnew{2,1}{36,12}(:,1),jointdataNnew{2,1}{36,12}(:,2),'.r',jointdataNnew{2,1}{36,13}(:,1),jointdataNnew{2,1}{36,13}(:,2),'.g');
grid on;
set(gca,'fontname','Times New Roman','fontsize',14);
xlabel(gca,'X (m)','fontname','Times New Roman','fontsize',16 );
ylabel(gca,'Y (m)','fontname','Times New Roman','fontsize',16 );
axis equal;
for i=1:3
    m=max(cell2mat(jointdataNnew{i,1}(:,3)));
    for j=1:m
        if ~isempty(jointdataNnew{i,1}{j,13})
            E=jointdataNnew{i,1}{j,13}(:,1);
            F=jointdataNnew{i,1}{j,13}(:,2);
            L=max(E)-min(E);
            n=size(E,1);
            d=0;
            for k=2:n
                a=(F(k,1)-F(k-1,1))^2;
                b=E(k,1)-E(k-1,1);
                c=a/b;
                d=d+c;
            end
            Z2=abs(sqrt(d/L));
            jointdataNnew{i,1}{j,14}=Z2;
            JRC2D=32.2+34.27*log10(Z2);
            jointdataNnew{i,1}{j,15}=JRC2D;
        end
    end
end
JRC=[];
JRNum=[];
for i=1:3
    m=max(cell2mat(jointdataNnew{i,1}(:,3)));
    JR=[];
    for j=1:m
        if ~isempty(jointdataNnew{i,1}{j,15})
            JR=[JR;jointdataNnew{i,1}{j,15}];
            JRN=size(JR,1);
        end
    end
    JRC=[JRC;JR];
    JRNum=[JRNum;JRN];
end
JRC(1:JRNum(1),3)=1;
JRC((JRNum(1)+1):(JRNum(1)+JRNum(2)),3)=2;
JRC((JRNum(1)+JRNum(2)+1):(JRNum(1)+JRNum(2)+JRNum(3)),3)=3;
maxJRC=max(JRC(:,1));
minJRC=min(JRC(:,1));
meanJRC=mean(JRC(:,1));
interval=(maxJRC-minJRC)/5;
if meanJRC>=minJRC & meanJRC<minJRC+interval
    Rr=0;
elseif meanJRC>=minJRC+interval & meanJRC<minJRC+2*interval
    Rr=1;
elseif meanJRC>=minJRC+2*interval & meanJRC<minJRC+3*interval 
    Rr=3;
elseif meanJRC>=minJRC+3*interval & meanJRC<minJRC+4*interval 
    Rr=5;
else meanJRC>=minJRC+4*interval & meanJRC<maxJRC
    Rr=6;
end
   
