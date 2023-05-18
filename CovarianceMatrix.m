function  [s,v]=CovarianceMatrix(ptCloud,n)
v=zeros(3,ptCloud.Count);%count-3D点的数量，创建一个3*数量的零矩阵
s=zeros(ptCloud.Count,1);%创建一个数量*1的矩阵
% p=zeros(3,ptCloud.Count);
for i=1:ptCloud.Count
    [indices,~] = findNearestNeighbors(ptCloud,ptCloud.Location(i,:),n);%对于ptCloud中的每一个点，寻找其在ptCloud中的最近点，n代表寻找点的数量？
    x = ptCloud.Location(indices(:),:);
    p_bar = 1/n * sum(x,1);%寻找附近50个点的平均值，以便于计算法向量长度和方向，sum(x,1)将x按列求和 
%     p(:,i)=p_bar';
    P = transpose(x - repmat(p_bar,n,1))*(x - repmat(p_bar,n,1)); %  repmat-把p-bat的内容堆叠在n行1列的矩阵中，transpose转置
    [V,lmd] = eig(P);%eig-求矩阵P的全部特征值，构成对角阵lmd，并求P的特征向量构成V的列向量
    [lmds,id]=min(diag(lmd));%diag-提取对角线元素，id-最小值位置
    v(:,i)=V(:,id);%点法向量
    s(i) = lmds/sum(diag(lmd))*100;%曲率
end
%矩阵P生成一个点云   ptCloud = pointCloud(P);