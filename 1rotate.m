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
        pc=pca(jo(:,1:3)); %%主成分分析
        vector=pc(:,3)';
        st=acos(dot([0,0,1],vector)/norm(vector));%%st为vector与Z轴的夹角,dot(A,B)返回A和B的标量点积.dot(A,B)=A(1)*B(1)+A(2)*B(2)+A(3)*B(3).
        ctAxis=[1,-vector(1)./vector(2),0];%%ctAxis为旋转轴,与走向线相同.A./B用A的每个元素除以B的对应元素.A和B的大小必须相同或兼容.
        M = makehgtform('axisrotate',ctAxis,st);%%创建 4×4 变换矩阵,M = makehgtform('axisrotate',[ax,ay,az],t) 围绕轴 [ax ay az] 旋转 t 弧度。
        jonew=(M(1:3,1:3)*jo')';
        jointdata{j,2}=jonew;%%旋转变换后的水平面
        jointdata{j,3}=j;
        jointdata{j,4}=i;
        jointdata{j,5}=mean(jonew);%[mean(jonew(:,1)),mean(jonew(:,2)),mean(jonew(:,3))];%%此列为剖面中心
        jointdata{j,6}=ctAxis;%%此列为剖面法向量
        jointdata{j,7}=-jointdata{j,5}*(jointdata{j,6})';%%此列为剖面的D
        joint(j,6)=st;
        joint(j,7:9)=ctAxis;
        joint(j,3:5)=vector(:,1:3);
        joint(j,2)=j;
        joint(j,1)=i;
    end
    jointN=[jointN;joint];
    jointdataN{i,1}=jointdata;%%第1列为原始平面，第2列为旋转后的水平面，第3列为结构面id，第4列为结构面组别，第5列为为剖面中心，第6列为剖面法向量，第7列为剖面的D.
end
%%求取剖面线
% % %% ####################选取距离纵剖面距离小于0.001m的点组成剖面线 ####################% % %%
%load JointdataN.mat;%%第1列为原始平面，第2列为旋转后的水平面，第3列为结构面id，第4列为结构面组别，第5列为为剖面中心，第6列为剖面法向量，第7列为剖面的D.
for i=1:3
    m=max(cell2mat(jointdataN{i,1}(:,3)));
    for j=1:m
        n=size(jointdataN{i,1}{j,2},1);%%旋转后每个结构面包含点的个数
        pmd=[];%%平面点，第1列显示点到拟合结构面的距离，第2列显示点序号，第345列显示点的xyz坐标
        jointdataN{i,1}{j,8}=[];
        %jointdataN{i,1}{j,10}=[];
        for k=1:n
            jointdataN{i,1}{j,2}(k,4)=k;
            dis=abs(jointdataN{i,1}{j,2}(k,1:3)*(jointdataN{i,1}{j,6})'+jointdataN{i,1}{j,7})./norm(jointdataN{i,1}{j,6}); %点到平面之间距离
            if dis<0.0015  %%因为采用的体网格下采样的边长是0.003
                pmd(1,1)=dis;%%第8列显示每个点到剖面的距离
                pmd(1,2)=k;%%点id
                pmd(1,3:5)=jointdataN{i,1}{j,2}(k,1:3);%%id点的xyz坐标
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
% % ###############剖面线旋转至与yoz平面平行（仅考虑10个及以上点数组成的剖面线） ###############  %%
for i=1:3
    m=max(cell2mat(jointdataN{i,1}(:,3)));%%结构面id
    for j=1:m
        n=size(jointdataN{i,1}{j,8},1);
        if n>9  %%只绘制10个点以上的剖面线
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



