function [ T ] = f_dbscan( A , eps, ppcluster)
% [ T, eps ] = f_dbscan( A , npb, ppcluster)
% B��squeda de cl��sters mediante una b��squeda previa de vecinos
% Aplicaci��n del algoritmo DBSCAN
% Adri��n Riquelme Guill, mayo 2013  
% Input:
% - A: matriz con las coordenadas de los puntos ���о�������ݼ�
% - eps: radio para b��squeda de vecinos   �뾶
% - ppcluster: n m��nimo de puntos por cl��ster ÿ��cluster���е���С������������������Ǳ���Ϊ���������� cluster �е�С����ɾ��
% Output:
% - T: cl��sters asignados a cada vecino T=zeros(n,1); [n,d]=size(A); ����TΪ n x 1 ���󣬵�ii�е����� ��ʾ A�ж�Ӧ�еĵ� ������һ��cluster
%    Copyright (C) {2015}  {Adri��n Riquelme Guill, adririquelme@gmail.com}
%
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License along
%   with this program; if not, write to the Free Software Foundation, Inc.,
%   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
%    Discontinuity Set Extractor, Copyright (C) 2015 Adri��n Riquelme Guill
%    Discontinuity Set Extractor comes with ABSOLUTELY NO WARRANTY.
%    This is free software, and you are welcome to redistribute it
%    under certain conditions.

[n,d]=size(A);
h=waitbar(0,['Cluster analysis in process. ',num2str(n),' points. Please wait']);

minpts=d+1; %minium number of eps-neighbors to consider into a cluster  ����ȡ��С�����ĵ�Ϊ d + 1��
T=zeros(n,1);   
maxcluster=1; % ��һ��clusterΪ1����1��cluster��
% 0 sin cl��ster asignado
% 1,2.... cl��ster asignado
% calculamos los puntos dentro del radio de eps
[idx, ~] = rangesearch(A,A,eps);
for i=1:n
    NeighborPts=idx{i};
    % si ha encontrado el m��nimo de puntos, hacer lo siguiente
    % cuidado, el primer ��ndice de idx es el mismo punto
    if length(NeighborPts)>=minpts %el punto es un core point
        % ?el punto tiene cl��ster asignado?
        cv=T(NeighborPts); %cl��ster vecinos
        mincv=min(cv); % cv �е���Сֵ
        mincv2=min(cv((cv>0))); % �� cv ��0 ������ֵ��ȡ��Сֵ
        maxcv=max(cv);% cv �е����ֵ
        if maxcv==0
            caso=0; % maxcv==0����һ������������ھӶ�û�б����࣬���ǰ���Щ��鵽maxcluster�С�
        else
            if maxcv==mincv2
                caso=1; % maxcv~=0 && maxcv==mincv2���ڶ�����������������ھӵ��е�û�б����࣬�еı����࣬���ұ�����ĵ�鵽��ͬһ�� ���������ھӵ�ȫ������ͬһ�ࡣ
            else
                caso=2; % maxcv~=0 && maxcv~=mincv2����������������������ھӵ��е�û�б����࣬�еı����࣬���ұ�����ĵ㲻����ͬһ�� ��
            end
        end
        switch caso
            case 0
                % ning��n punto tiene c��ster asingado, se lo asignamos
                T(NeighborPts)=maxcluster; % �������һ�����ǰ����е��������ھӵ�鵽maxcluster�У����� maxcluster=maxcluster+1
                % T(i)=maxcluster;
                maxcluster=maxcluster+1; %
            case 1
                if mincv==0
                    % ��������������ǰ������� δ�������ھӵ� �鵽 �Ѿ���������ھӵ��ͬ��� �У�T(NeighborPts(cv==0))=mincv2;��maxcv==mincv2�������������maxcv����mincv2���У�
                    T(NeighborPts(cv==0))=mincv2;
                end
                % T(i)=mincv2;
            case 2
                %��������������ǰ� δ�������ھӵ� ���ൽ mincv2 �У������� �Ѿ���������ھӵ� ���ڶ��������������ھӣ����Ա�����ͬһ�࣬����Ҫ�����ൽͬһ�����棬
                %            �������е��Ѿ���������ھӵ� ������ĵ����ĵ�ҲҪ�鵽��һ�ࡣ
                T(NeighborPts(cv==0))=mincv2;
                % reagrupamos los puntos que ya tienen cl��ster
                b=cv(cv>mincv2); % cl��sters a reasignar
                [~,n1]=size(b);
                aux=0;
                for j=1:n1
                    if b(j)~=aux
                        T(T==b(j))=mincv2;
                        aux=b(j);
                    end
                end
                % T(i)=mincv2;
        end
    else
        %el punto no tiene suficientes vecinos.�����û���㹻���ھ�
    end
    waitbar(i/n,h);
end
%% homogeneizamos la salida
% si la salida est�� vac��a, es decir que no se encuentra ning��n cluster, no hacemos nada  ������Ϊ�գ���û���ҵ���Ⱥ����ִ���κβ���
if sum(T)==0 
    % no hademos nada, la salida est�� vac��a
    % como todos los puntos tienen valor cero, se eliminar��n despu��s ����ʲô��û�У�����ǿյģ���Ϊ���еĵ㶼���㣬���ǻᱻɾ����
else
    % en esta fase cogemos los cl��sters obtenidos y eliminamos los que no
    % superen los N (ppcluster)
    % se ordenan los cl��sters seg��n mayor a menor n? de puntos obtenidos
    T2=T;
    cluster=unique(T2,'sorted');
    cluster=cluster(cluster>0); % eliminamos los cl��sters ru��do ����������Ⱥ
    [ nclusters,~]=size(cluster);
    % calculamos el n��mero de puntos que pertenecen a cada cluster���Ǽ�������ÿ����Ⱥ�ĵ������
    A=zeros(2,nclusters);
    numeroclusters=zeros(1, nclusters);
    for ii=1:nclusters
        numeroclusters(ii)=length(find(T2(:,1)==cluster(ii,1)));
    end
    A(2,:)=cluster; A(1,:)=numeroclusters;   % A �ĵڶ��б�ʾ��һ�� cluster����һ�б�ʾ���е� cluster ���ж��ٸ���
    % ordeno la matriz seg��n el n��mero de cl��sters encontrados
    [~,IX]=sort(A(1,:),'descend'); A=A(:,IX);
    % buscamos aquellos clusters con m��s de n puntos  ����Ѱ����Щ����n����ļ�Ⱥ
    n=ppcluster;
    I=find(A(1,:)>n);
    J=find(A(1,:)<=n);
    % los cl��sters no significativos le asingamos le valor 0 ���ڲ���Ҫ�ļ�Ⱥ�������� T �н�������Ϊ0
    for ii=1:length(J)
        T(T2==A(2,J(ii)))=0;
    end
    % renombramos los cl��sters seg��n importancia ����Ҫ��������cluster
    for ii=1:length(I)
        T(T2==A(2,I(ii)))=ii;
    end
end
close(h);