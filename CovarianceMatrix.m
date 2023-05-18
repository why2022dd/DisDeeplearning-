function  [s,v]=CovarianceMatrix(ptCloud,n)
v=zeros(3,ptCloud.Count);%count-3D�������������һ��3*�����������
s=zeros(ptCloud.Count,1);%����һ������*1�ľ���
% p=zeros(3,ptCloud.Count);
for i=1:ptCloud.Count
    [indices,~] = findNearestNeighbors(ptCloud,ptCloud.Location(i,:),n);%����ptCloud�е�ÿһ���㣬Ѱ������ptCloud�е�����㣬n����Ѱ�ҵ��������
    x = ptCloud.Location(indices(:),:);
    p_bar = 1/n * sum(x,1);%Ѱ�Ҹ���50�����ƽ��ֵ���Ա��ڼ��㷨�������Ⱥͷ���sum(x,1)��x������� 
%     p(:,i)=p_bar';
    P = transpose(x - repmat(p_bar,n,1))*(x - repmat(p_bar,n,1)); %  repmat-��p-bat�����ݶѵ���n��1�еľ����У�transposeת��
    [V,lmd] = eig(P);%eig-�����P��ȫ������ֵ�����ɶԽ���lmd������P��������������V��������
    [lmds,id]=min(diag(lmd));%diag-��ȡ�Խ���Ԫ�أ�id-��Сֵλ��
    v(:,i)=V(:,id);%�㷨����
    s(i) = lmds/sum(diag(lmd))*100;%����
end
%����P����һ������   ptCloud = pointCloud(P);