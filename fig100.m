
tainImPath = 'E:\MVCNN\二维深度学习\test\0\';
fileTrain = dir([tainImPath, '*.jpg']);
subpath = 'E:\MVCNN\二维深度学习\训练\0\';
 
for i = 1:length(fileTrain)
    name = fileTrain(i).name;
    im = imread([tainImPath,name]);
    im196 = imresize(im,[100 875],"bicubic");
    imwrite(im196,strcat(subpath, name));
end
fprintf("finish!")