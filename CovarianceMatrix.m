function  [s,v]=CovarianceMatrix(ptCloud,n)
v=zeros(3,ptCloud.Count);
s=zeros(ptCloud.Count,1);
% p=zeros(3,ptCloud.Count);
for i=1:ptCloud.Count
    [indices,~] = findNearestNeighbors(ptCloud,ptCloud.Location(i,:),n);
    x = ptCloud.Location(indices(:),:);
    p_bar = 1/n * sum(x,1);
%     p(:,i)=p_bar';
    P = transpose(x - repmat(p_bar,n,1))*(x - repmat(p_bar,n,1)); 
    [V,lmd] = eig(P);
    [lmds,id]=min(diag(lmd));
    v(:,i)=V(:,id);
    s(i) = lmds/sum(diag(lmd))*100;
end
%   ptCloud = pointCloud(P);
