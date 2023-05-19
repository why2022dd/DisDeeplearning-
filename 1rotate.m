clear;
close all;
clc;
load J1(20220307).mat;
figure;
pcshow(J1(:,1:3),J1(:,4:6));
load J2(20220307).mat;
figure;
pcshow(J2(:,1:3),J2(:,4:6));
load J3(20220307).mat;
figure;
pcshow(J3(:,1:3),J3(:,4:6));
m1=max(J1(:,13));
m2=max(J2(:,13));
m3=max(J3(:,13));
jointN=[];
jointdataN={};
for i=1:3
    eval(['J=','J',num2str(i),';']);
    m=max(J(:,13));
    joint=[];
    jointdata={};
    for j=1:m
        jo=J(find(J(:,13)==j),1:3);
        jointdata{j,1}=jo;
        pc=pca(jo(:,1:3));
        vector=pc(:,3)';
        st=acos(dot([0,0,1],vector)/norm(vector));
        ctAxis=[1,-vector(1)./vector(2),0];
        M = makehgtform('axisrotate',ctAxis,st);
        jonew=(M(1:3,1:3)*jo')';
        jointdata{j,2}=jonew;
        jointdata{j,3}=j;
        jointdata{j,4}=i;
        jointdata{j,5}=mean(jonew);%[mean(jonew(:,1)),mean(jonew(:,2)),mean(jonew(:,3))];
        jointdata{j,6}=ctAxis;
        jointdata{j,7}=-jointdata{j,5}*(jointdata{j,6})';
        joint(j,6)=st;
        joint(j,7:9)=ctAxis;
        joint(j,3:5)=vector(:,1:3);
        joint(j,2)=j;
        joint(j,1)=i;
    end
    jointN=[jointN;joint];
    jointdataN{i,1}=jointdata;
end
%%

%load JointdataN.mat;
for i=1:3
    m=max(cell2mat(jointdataN{i,1}(:,3)));
    for j=1:m
        n=size(jointdataN{i,1}{j,2},1);
        pmd=[];
        jointdataN{i,1}{j,8}=[];
        %jointdataN{i,1}{j,10}=[];
        for k=1:n
            jointdataN{i,1}{j,2}(k,4)=k;
            dis=abs(jointdataN{i,1}{j,2}(k,1:3)*(jointdataN{i,1}{j,6})'+jointdataN{i,1}{j,7})./norm(jointdataN{i,1}{j,6});
            if dis<0.0015  
                pmd(1,1)=dis;
                pmd(1,2)=k;
                pmd(1,3:5)=jointdataN{i,1}{j,2}(k,1:3);
                jointdataN{i,1}{j,8}=[jointdataN{i,1}{j,8};pmd];
            end
        end
    end
end
figure;
pcshow(jointdataN{2,1}{5,8}(:,3:5));
grid on;
set(gca,'fontname','Times New Roman','fontsize',14);
xlabel(gca,'X (m)','fontname','Times New Roman','fontsize',16 );
ylabel(gca,'Y (m)','fontname','Times New Roman','fontsize',16 );
zlabel(gca,'Z (m)','fontname','Times New Roman','fontsize',16 );
axis equal;
% %
for i=1:3
    m=max(cell2mat(jointdataN{i,1}(:,3)));
    for j=1:m
        n=size(jointdataN{i,1}{j,8},1);
        if n>9  
            M = makehgtform('zrotate',atan(-jointdataN{i,1}{j,6}(1,2)));
            N=(M(1:3,1:3)*(jointdataN{i,1}{j,8}(:,3:5))')';
            jointdataN{i,1}{j,9}=[N,jointdataN{i,1}{j,8}(:,2)];
        end
    end
end
figure;
pcshow(jointdataN{2,1}{5,9}(:,1:3));
grid on;
set(gca,'fontname','Times New Roman','fontsize',14);
xlabel(gca,'X (m)','fontname','Times New Roman','fontsize',16 );
ylabel(gca,'Y (m)','fontname','Times New Roman','fontsize',16 );
zlabel(gca,'Z (m)','fontname','Times New Roman','fontsize',16 );
axis equal;
view(135,10);



