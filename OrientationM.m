function [dd,dip] = OrientationM(x,y,z)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

xy=sqrt(x.^2+y.^2);

if z<0
    dip=pi-acos(z);
    if x>=0 && y>=0
        dd=asin(x/xy)+pi;
    elseif x<0 && y>=0
        dd=2*pi-asin(-x/xy)-pi;
    elseif x>=0 && y<0
        dd=pi-asin(x/xy)+pi;
    else
        %elseif x<0 && y<0
        dd=pi+asin(-x/xy)-pi;
    end
else
    dip=acos(z);
    if x>=0 && y>=0
        dd=asin(x/xy);
    elseif x<0 && y>=0
        dd=2*pi-asin(-x/xy);
    elseif x>=0 && y<0
        dd=pi-asin(x/xy);
    else
        %elseif x<0 && y<0
        dd=pi+asin(-x/xy);
    end
end

dip=rad2deg(dip);
dd=rad2deg(dd);

end

