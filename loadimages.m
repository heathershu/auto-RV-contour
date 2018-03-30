function [images, hires_images, info] = loadimages(folder)
files = dir(folder);

h = waitbar(0,'Loading images...');
for i = 1:length(files)
    if ~strcmp(files(i).name, '.') && ~strcmp(files(i).name, '..')
        path = [files(i).folder filesep files(i).name];
        img = dicomread(path);
        [x,y] = size(img);
        resx = x*2;
        resy = y*2;
        z = length(files) - i;
        start = i;
        break
    end
end

hires_images = zeros(resx,resy,z);
images = zeros(x,y,z);

files = files(start:end);
for i = 1:length(files)
   path = [files(i).folder filesep files(i).name];

   images(:,:,i) = dicomread(path);
   % Bicubic interpolation
   hires_images(:,:,i) = imresize(images(:,:,i),2);
   info(i).data = dicominfo(path); 
   waitbar(i / length(files))
end
close(h)
end