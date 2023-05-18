
% 读取数据
X = xlsread('训练集2.xlsx');
y = X(:, end); % 假设标签在数据最后一列

% 分离训练集和验证集（随机抽取30%做验证集）
cv_ratio = 0.3; % 验证集比例
cv_size = round(size(X, 1) * cv_ratio);
cv_indices = randperm(size(X, 1), cv_size);
cv_set = X(cv_indices, :);
X(cv_indices, :) = [];
load ('googlenetlgraph_1.mat');
% 训练模型
a=50;%改变a值大小，可以讨论训练轮数对结果的影响
options = trainingOptions('sgdm', ... 
'ExecutionEnvironment','cpu', ...
'InitialLearnRate',0.001,...
'MaxEpochs',a,...    
'MiniBatchSize',4, ...   
'GradientThreshold',1, ...  
'Verbose',false, ...    
'Plots','training-progress');%参数调节
[net,info] = trainNetwork(Xtrain,ytrain,lgraph_1,options); %训练完后，网络就是这个，需要保存

%导入测试集，出准确率和损失率图，记得保存准确率
XX=xlsread('测试集2.xlsx');%下面是测试赝本，格式与训练样本一致
 Xtest1=XX(:,1:6);
 for ii=1:1:252
    for jj=1:1:6    
        Xtest(1,jj,1,ii)=Xtest1(ii,jj); 
    end   
end
ytest1=XX(:,7);
ytest=categorical(ytest1); 


% 在训练集和验证集上测试模型
train_preds = net(X');
cv_preds = net(cv_set(:, 1:end-1)');
train_acc = mean(y' == (train_preds > 0.5));
cv_acc = mean(cv_set(:, end)' == (cv_preds > 0.5));