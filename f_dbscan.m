function [ T ] = f_dbscan( A , eps, ppcluster)
% [ T, eps ] = f_dbscan( A , npb, ppcluster)
% Búsqueda de clústers mediante una búsqueda previa de vecinos
% Aplicación del algoritmo DBSCAN
% Adrián Riquelme Guill, mayo 2013  
% Input:
% - A: matriz con las coordenadas de los puntos 进行聚类的数据集
% - eps: radio para búsqueda de vecinos   半径
% - ppcluster: n mínimo de puntos por clúster 每个cluster含有的最小数量，少于这个数我们便认为聚类出的这个 cluster 有点小，便删除
% Output:
% - T: clústers asignados a cada vecino T=zeros(n,1); [n,d]=size(A); 所以T为 n x 1 矩阵，第ii行的内容 表示 A中对应行的点 属于哪一个cluster
%    Copyright (C) {2015}  {Adrián Riquelme Guill, adririquelme@gmail.com}
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
%    Discontinuity Set Extractor, Copyright (C) 2015 Adrián Riquelme Guill
%    Discontinuity Set Extractor comes with ABSOLUTELY NO WARRANTY.
%    This is free software, and you are welcome to redistribute it
%    under certain conditions.

[n,d]=size(A);
h=waitbar(0,['Cluster analysis in process. ',num2str(n),' points. Please wait']);

minpts=d+1; %minium number of eps-neighbors to consider into a cluster  我们取最小数量的点为 d + 1；
T=zeros(n,1);   
maxcluster=1; 
% 0 sin clúster asignado
% 1,2.... clúster asignado
% calculamos los puntos dentro del radio de eps
[idx, ~] = rangesearch(A,A,eps);
for i=1:n
    NeighborPts=idx{i};
    % si ha encontrado el mínimo de puntos, hacer lo siguiente
    % cuidado, el primer índice de idx es el mismo punto
    if length(NeighborPts)>=minpts %el punto es un core point
        % ?el punto tiene clúster asignado?
        cv=T(NeighborPts); %clúster vecinos
        mincv=min(cv); 
        mincv2=min(cv((cv>0))); 
        maxcv=max(cv);
        if maxcv==0
            caso=0; 
        else
            if maxcv==mincv2
                caso=1;
            else
                caso=2;
            end
        end
        switch caso
            case 0
                % ningún punto tiene cúster asingado, se lo asignamos
                T(NeighborPts)=maxcluster;
                % T(i)=maxcluster;
                maxcluster=maxcluster+1; 
            case 1
                if mincv==0
              
                    T(NeighborPts(cv==0))=mincv2;
                end
                % T(i)=mincv2;
            case 2
              
                T(NeighborPts(cv==0))=mincv2;
                % reagrupamos los puntos que ya tienen clúster
                b=cv(cv>mincv2); % clústers a reasignar
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
        %el punto no tiene suficientes vecinos.
    end
    waitbar(i/n,h);
end
%% homogeneizamos la salida
% si la salida está vacía, es decir que no se encuentra ningún cluster, no hacemos nada  
if sum(T)==0 
    % no hademos nada, la salida está vacía
    % como todos los puntos tienen valor cero, se eliminarán después 
else
    % en esta fase cogemos los clústers obtenidos y eliminamos los que no
    % superen los N (ppcluster)
    % se ordenan los clústers según mayor a menor n? de puntos obtenidos
    T2=T;
    cluster=unique(T2,'sorted');
    cluster=cluster(cluster>0); % eliminamos los clústers ruído 
    [ nclusters,~]=size(cluster);
    % calculamos el número de puntos que pertenecen a cada cluster
    A=zeros(2,nclusters);
    numeroclusters=zeros(1, nclusters);
    for ii=1:nclusters
        numeroclusters(ii)=length(find(T2(:,1)==cluster(ii,1)));
    end
    A(2,:)=cluster; A(1,:)=numeroclusters;   % 
    % ordeno la matriz según el número de clústers encontrados
    [~,IX]=sort(A(1,:),'descend'); A=A(:,IX);
    % buscamos aquellos clusters con más de n puntos  
    n=ppcluster;
    I=find(A(1,:)>n);
    J=find(A(1,:)<=n);
    % los clústers no significativos le asingamos le valor 0 
    for ii=1:length(J)
        T(T2==A(2,J(ii)))=0;
    end
    % renombramos los clústers según importancia 
    for ii=1:length(I)
        T(T2==A(2,I(ii)))=ii;
    end
end
close(h);
