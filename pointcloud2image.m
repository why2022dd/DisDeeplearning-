function I = pointcloud2image( data,numr,numc )
% This function converts a point cloud (given in x,y,z) to a gray scale image
% We assume the ToF camera is alligned with 'x-axis' 
%
% x,y,z: coordinate vectors of all points in the cloud
% numr: desired number of rows of output image
% numc: desired number of columns of output image
% I   : output gray scale image
%
% Example useage:
%   I = pointcloud2image( x,y,z,250,250 );
%   figure;  imshow(I,[]);

% depth calculation
x=data(:,1);
y=data(:,2);
z=data(:,3);
d = sqrt( x.^2 + y.^2 + z.^2);

%% yz方向投影

% grid construction
yl = min(y); yr = max(y); zl = min(z); zr = max(z);
yy = linspace(yl,yr,numc); zz = linspace(zl,zr,numr);
[Y,Z] = meshgrid(yy,zz);
grid_centers = [Y(:),Z(:)];

% classification
class = knnsearch(grid_centers,[y,z]); 

% defintion of local statistic
local_stat = @(x)mean(x);
%local_stat = @(x)min(x); 

% data_grouping
class_stat = accumarray(class,d,[numr*numc 1],local_stat);

% 2D reshaping
class_stat_M  = reshape(class_stat , size(Y)); 

% Force un-filled cells to the brightest color
class_stat_M (class_stat_M == 0) = max(max(class_stat_M));

% flip image horizontally and vertically水平和垂直翻转图像
Iyz = class_stat_M(end:-1:1,end:-1.:1);


%% xy方向投影
xl = min(x); xr = max(x); yl = min(y); yr = max(y);
xx = linspace(xl,xr,numc); yy = linspace(yl,yr,numr);
[X,Y] = meshgrid(xx,yy);
grid_centers = [X(:),Y(:)];

% classification
class = knnsearch(grid_centers,[x,y]); 

% defintion of local statistic
local_stat = @(x)mean(x);
%local_stat = @(x)min(x); 

% data_grouping
class_stat = accumarray(class,d,[numr*numc 1],local_stat);

% 2D reshaping
class_stat_M  = reshape(class_stat , size(X)); 

% Force un-filled cells to the brightest color
class_stat_M (class_stat_M == 0) = max(max(class_stat_M));

% flip image horizontally and vertically水平和垂直翻转图像
Ixy = class_stat_M(end:-1:1,end:-1.:1);

%% xz方向投影
xl = min(x); xr = max(x); zl = min(z); zr = max(z);
xx = linspace(xl,xr,numc); zz = linspace(zl,zr,numr);
[X,Z] = meshgrid(xx,zz);
grid_centers = [X(:),Z(:)];

% classification
class = knnsearch(grid_centers,[x,z]); 

% defintion of local statistic
local_stat = @(x)mean(x);
%local_stat = @(x)min(x); 

% data_grouping
class_stat = accumarray(class,d,[numr*numc 1],local_stat);

% 2D reshaping
class_stat_M  = reshape(class_stat , size(X)); 

% Force un-filled cells to the brightest color
class_stat_M (class_stat_M == 0) = max(max(class_stat_M));

% flip image horizontally and vertically水平和垂直翻转图像
Ixz = class_stat_M(end:-1:1,end:-1.:1);

%%
I=Iyz+Ixy+Ixz;

end

