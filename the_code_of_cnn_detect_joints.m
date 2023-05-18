# DisDeeplearning-
the code of cnn detect joint from 3D point clouds using a deep learning 
clear;
close all;
clc;
% input data
[FileName,PathName,~] = uigetfile({'*.pcd';'*.xlsx';'*.xls';'*.dat';'*.txt'},'Select point cloud data');
if(isempty(FileName) || length(FileName)<=1)
    error('No data file selected');
end
switch(FileName(end-2:end))  
    case 'dat'
        pcData=load([PathName,FileName]);
    case 'xls'
        pcData=xlsread([PathName,FileName]);
    case 'lsx'
        pcData=xlsread([PathName,FileName]);
    case 'txt'
        FileID=fopen([PathName,FileName]);
        cell_data=textscan(FileID,'%f %f %f');
        pcData=[cell_data{1},cell_data{2},cell_data{3}];
        fclose(FileID);
    case 'pcd'
        data_temp=pcread([PathName,FileName]);
        pcData=data_temp.Location;
    otherwise
        error('Only .dat/.xls/.xlsx/.pcd type data is supported, this type is not supported yet!');
end

if(~ismatrix(pcData)) 
    error('Inconsistent data dimensions!');
elseif(size(pcData,2)<3) 
    error('The data must be stored separately (x,y,z)!');
else
    pcData=pcData(:,1:3);
    disp('Data imported successfully!');
    disp(['The number of dimensions of your data is:',num2str(size(pcData,1)),'x',num2str(size(pcData,2))]);
end
% downsampling
ptCloud=pointCloud(pcData(:,1:3));
gridStep = 0.003;
ptCloud=pcdownsample(ptCloud,'gridAverage',gridStep);
figure;
pcshow(ptCloud);
pcData=ptCloud.Location;
xlabel(gca,'X (m)','fontname','Times New Roman','fontsize',16 ,'color',[0 0 0] );
ylabel(gca,'Y (m)','fontname','Times New Roman','fontsize',16 ,'color',[0 0 0]);
zlabel(gca,'Z (m)','fontname','Times New Roman','fontsize',16 ,'color',[0 0 0]);
set(gca,'fontname','Times New Roman','fontsize',14,'color',[0 0 0]);
set(gca,'color','w');
set(gcf,'color','w');
set(gca,'xcolor',[0 0 0]);	
set(gca,'ycolor',[0 0 0]);	
set(gca,'zcolor',[0 0 0])
axis equal;
view(45,10)
% pcData(:,4:6)=ptCloud.Color;
colorbar
%point normal calculation
ptCloud=pointCloud(pcData(:,1:3));
k=100;
pitNormal=pcnormals(ptCloud,k);
pcData(:,4:6)=pitNormal;
figure;
pcshow(pcData(:,1:3),pcData(:,4:6));
grid on;
set(gca,'fontname','Times New Roman','fontsize',14,'color',[0 0 0]);
set(gca,'color','w');
set(gcf,'color','w');
xlabel(gca,'X (m)','fontname','Times New Roman','fontsize',16 );
ylabel(gca,'Y (m)','fontname','Times New Roman','fontsize',16 );
zlabel(gca,'Z (m)','fontname','Times New Roman','fontsize',16 );
set(gca,'xcolor',[0 0 0]);	
set(gca,'ycolor',[0 0 0]);	
set(gca,'zcolor',[0 0 0])
axis equal;
view(45,10);

%%  training data selection
%Determine the number of structural plane groups
prompt = 'How many groups in this section?';
dlgtitle = 'Input';
dims = [1 35];
answer = inputdlg(prompt,dlgtitle,dims);
groupNum = str2num(answer{1}); 
pcLearn=[];
for i=1:1:groupNum
    prompt = {'How many points do you want to chose for this data group?'};
    dlgtitle = 'Input';
    dims = [1 35];
    answer = inputdlg(prompt,dlgtitle,dims);
    pointsNum = str2num(answer{1});
    pointsGet=getpointsXYZ(pcData,pointsNum);
%     pointsGet=getpointsXYZ(pitNormal,pointsNum);
    pointsGet(:,10:9+groupNum)=zeros(pointsNum,groupNum);
    pointsGet(:,10+i-1)=ones(pointsNum,1);
    [Lia,Locb]=ismember(pointsGet(:,1:3),pcData(:,1:3),'rows');
    pointsGet(:,1:6)=pcData(Locb,1:6);
    pointsGet(:,9)=Locb;
    pcLearn=[pcLearn;pointsGet];
end



%%
% clear
 clc
% close all
% load ('Dencenet-21lgraph_1.mat');
load ('googlenetlgraph_1.mat');
X=xlsread('训练集2.xlsx');%The dataset is the final training data carefully selected by the operator.


Xtrain1 = X(:,1:6);
for i=1:1:70  %Set 70% of them as training samples
    for j=1:1:6
        Xtrain(1,j,1,i)=Xtrain1(i,j); %The data sample is two-dimensional
    end 
end
ytrain=X (:,7);
ytrain=categorical(ytrain); 

a=400;%Changing the size of the a-value allows discussing the effect of the number of training rounds on the results
options = trainingOptions('sgdm', ... 
'ExecutionEnvironment','cpu', ...
'InitialLearnRate',0.001,...
'MaxEpochs',a,...    
'MiniBatchSize',4, ...   
'GradientThreshold',1, ...  
'Verbose',false, ...    
'Plots','training-progress');
[net,info] = trainNetwork(Xtrain,ytrain,lgraph_1,options); %After training, the network is this and needs to be saved
%
XX=xlsread('测试集2.xlsx');%The dataset is the final test data carefully selected by the operator.
 Xtest1=XX(:,1:6);
 for ii=1:1:252
    for jj=1:1:6    
        Xtest(1,jj,1,ii)=Xtest1(ii,jj); 
    end   
end
ytest1=XX(:,7);
ytest=categorical(ytest1); 
YPred = classify(net,Xtest); 
YPred1 =double(YPred); 
accuracy_test = sum(YPred == ytest)/numel(ytest)%
% net, X_train and y_train are the trained convolutional neural network, training set data and labels respectively
y_pred = classify(net, Xtrain); % Classification of the training set
accuracy_train = sum(y_pred == ytrain) / numel(ytrain) % 
error_train=1-accuracy_train;
error_test=1-accuracy_test;

figure('Position', [100, 100, 800, 400]); 
plot(info.TrainingLoss);
grid on;
xlabel('Number of Iterations');
ylabel('Training Loss');
xticks(0:100:a*11);
xlim([0, a*11]);
figure('Position', [100, 100, 800, 400]); 
plot(info.TrainingAccuracy);
grid on;
xlabel('Number of Iterations');
ylabel('Training Accuracy');
xticks(0:100:a*11);
xlim([0, a*11]);
%%
figure;
plot(info.BaseLearnRate);
grid on;
xlabel('Number of Iterations');
ylabel('BaseLearnRate');
%% 
clear
clc
% close all '
load ('全部数据.mat');%Apply to all point clouds
Xtest1=pcData(:,1:6);
for ii=1:1:2161140
    for jj=1:1:6
        Xtest(1,jj,1,ii)=Xtest1(ii,jj);
    end
end

[preds,scores]= classify(net,Xtest);
pcData(:,16)=preds;
%%
figure;
pcshow(pcData(:,1:3),pcData(:,16));
colormap(jet) 
grid on;
set(gca,'fontname','Times New Roman','fontsize',14 ,'color',[0 0 0]);
set(gca,'color','w');
set(gcf,'color','w');
set(gca,'xcolor','k');
set(gca,'ycolor','k');
set(gca,'zcolor','k');
xlabel(gca,'X (m)','fontname','Times New Roman','fontsize',16 );
ylabel(gca,'Y (m)','fontname','Times New Roman','fontsize',16 );
zlabel(gca,'Z (m)','fontname','Times New Roman','fontsize',16 );
axis equal;
view(45,10);

%% DBSCAN algorithm was utilized to separate the individual discontinuity
groupNum=4;
k=100; 
for ii=1:groupNum
     jointset=find(pcData(:,16)==ii);
     nvecinos=k+1;
     [m,~]=size(pcData);
     density=[];
     if nvecinos > m
         nvecinos=m;
         [~,dist]=knnsearch(pcData(jointset,1:3),pcData(jointset,1:3),'NSMethod','kdtree','distance','euclidean','k',nvecinos);
         data=dist(:,nvecinos); 
     else
         [~,dist]=knnsearch(pcData(jointset,1:3),pcData(jointset,1:3),'NSMethod','kdtree','distance','euclidean','k',nvecinos);
         if m<nvecinos 
             data=dist(:,m);
         else
             data=dist(:,2);
         end
     end
     data=unique(data,'sorted');
     eps=mean(data)+2*std(data);
     disp(eps);

     e=1;
     while e==1
         prompt = {'Please input eps:';'Please input ppcluster:'};
         dlgtitle = 'Input';
         dims = [1 50];
         answer = inputdlg(prompt,dlgtitle,dims);
         eps = str2num(answer{1}); 
         ppcluster = str2num(answer{2});   %#ok<*ST2NM>
         disp(ppcluster);
         if isempty(ppcluster)  
             ppcluster=100;
         end
         disp(ppcluster);
         disp(eps);
         pcData(jointset,9+groupNum)=f_dbscan( pcData(jointset,1:3) , eps, ppcluster);
         J=pcData(find(pcData(:,16)==ii &pcData(:,9+groupNum)~=0),:);%#ok<FNDSB>
         eval(['J',num2str(ii-1),'=J',';']);  
         figure;
         pcshow(J(:,1:3),J(:,4:6));
         grid on;
         set(gca,'fontname','Times New Roman','fontsize',18 ,'color',[0 0 0]);
         set(gca,'color','w');
         set(gcf,'color','w');
         set(gca,'xcolor',[0 0 0]);	
         set(gca,'ycolor',[0 0 0]);
         set(gca,'zcolor',[0 0 0]);
         xlabel(gca,'X (m)','fontname','Times New Roman','fontsize',20 ,'color',[0 0 0] );
         ylabel(gca,'Y (m)','fontname','Times New Roman','fontsize',20 ,'color',[0 0 0] );
         zlabel(gca,'Z (m)','fontname','Times New Roman','fontsize',20 ,'color',[0 0 0] );
         axis equal;
         view(45,10);
         pause
         answer = questdlg('Are the clustering results satisfactory?');
         switch answer
             case 'Yes' 
                 e=0;
             case 'No' 
                 e=1;
         end
     end
 end
 disp('Clustering done!');
 % Plotting the point cloud of 3 groups of structural surfaces after clustering
 for i=0:3
     eval(['J=','J',num2str(i),';']);   
     figure;
     pcshow(J(:,1:3),J(:,4:6))
     grid on;
  grid on;
         set(gca,'fontname','Times New Roman','fontsize',14 ,'color',[0 0 0]);
         set(gca,'color','w');
         set(gcf,'color','w');
         set(gca,'xcolor',[0 0 0]);	
         set(gca,'ycolor',[0 0 0]);	
         set(gca,'zcolor',[0 0 0])
         xlabel(gca,'X (m)','fontname','Times New Roman','fontsize',16 ,'color',[0 0 0] );
         ylabel(gca,'Y (m)','fontname','Times New Roman','fontsize',16 ,'color',[0 0 0] );
         zlabel(gca,'Z (m)','fontname','Times New Roman','fontsize',16 ,'color',[0 0 0] );     axis equal;
     view(45,10);
 end
 
%%3 groups of structural surfaces are clustered separately
 clc
for ii=1:1:groupNum 
    jointset=find(pcData(:,16)==ii);  
    m=max(pcData(jointset,9+groupNum));
    cx=rand(m,1);
    cy=rand(m,1);
    cz=rand(m,1);
    figure;
    for mm=1:m
    j=pcData(find(pcData(:,16)==ii&pcData(:,9+groupNum)==mm),:);   %#ok<FNDSB>
    pcshow(j(:,1:3),[cx(mm,:),cy(mm,:),cz(mm,:)])
    grid on;
     grid on;
         set(gca,'fontname','Times New Roman','fontsize',16 ,'color',[0 0 0]);
         set(gca,'color','w');
         set(gcf,'color','w');
         set(gca,'xcolor',[0 0 0]);
         set(gca,'ycolor',[0 0 0]);
         set(gca,'zcolor',[0 0 0])
         xlabel(gca,'X (m)','fontname','Times New Roman','fontsize',16 ,'color',[0 0 0] );
         ylabel(gca,'Y (m)','fontname','Times New Roman','fontsize',16 ,'color',[0 0 0] );
         zlabel(gca,'Z (m)','fontname','Times New Roman','fontsize',16 ,'color',[0 0 0] );
    axis equal;
    view(45,10);
    hold on;
    end
 end 
 
 %%3 groups of structural surfaces are drawn on 1 drawing, each structural surface is colored separately
 figure;
 for ii=1:1:groupNum
     jointset=find(pcData(:,16)==ii);
     m=max(pcData(jointset,9+groupNum));
     cx=rand(m,1);
     cy=rand(m,1);
     cz=rand(m,1);
     for mm=1:m
         j=pcData(find(pcData(:,16)==ii&pcData(:,9+groupNum)==mm),:);  %#ok<FNDSB>
         pcshow(j(:,1:3),[cx(mm,:),cy(mm,:),cz(mm,:)])
         grid on;
                set(gca,'fontname','Times New Roman','fontsize',16 ,'color',[0 0 0]);
         set(gca,'color','w');
         set(gcf,'color','w');
         set(gca,'xcolor',[0 0 0]);
         set(gca,'ycolor',[0 0 0]);
         set(gca,'zcolor',[0 0 0])
         xlabel(gca,'X (m)','fontname','Times New Roman','fontsize',16 ,'color',[0 0 0] );
         ylabel(gca,'Y (m)','fontname','Times New Roman','fontsize',16 ,'color',[0 0 0] );
         zlabel(gca,'Z (m)','fontname','Times New Roman','fontsize',16 ,'color',[0 0 0] );
         axis equal;
         view(45,10);
         hold on;
     end
 end




%% Orientation measurement
clc;
% load ('聚类.mat');%Save clustering results
a=1;
Orientation=cell(groupNum,1);
for ii=1:groupNum
    jointset=find(pcData(:,16)==ii);
    m=max(pcData(jointset,9+groupNum));
    for mm=1:m
        j=pcData(find(pcData(:,16)==ii&pcData(:,9+groupNum)==mm),:); %#ok<FNDSB>
        pc=pca(j(:,1:3));
        normal=pc(:,3)';
        [dd,dip] = OrientationM(normal(:,1),normal(:,2),normal(:,3));
        [n,~]=size(j);
        Orientation{ii}(a,1)=ii;
        Orientation{ii}(a,2)=mm;
        Orientation{ii}(a,3)=dd;
        Orientation{ii}(a,4)=dip;
        a=a+1;
    end
end
