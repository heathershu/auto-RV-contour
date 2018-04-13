function [sorted_images, slice_loc, images_per_slice] = sortImages(images, info)
loc = zeros(length(info),2);
slice_loc = zeros(length(info),1);
%% Get instance number and slice location from dicom data
for i = 1:length(info)
    loc(i,1) = i;
    loc(i,2) = info(i).data.InstanceNumber;
    slice_loc(i) = info(i).data.SliceLocation;
end
% Sort instance number 
sorted = sortrows(loc,2);
[x,y,z] = size(images);
sorted_images = zeros(x,y,z);
sorted_slice_loc = zeros(z,1);

%% Sort images and slice locations according to instance number
for i = 1:length(sorted)
   sorted_images(:,:,i) = images(:,:,sorted(i,1));
   sorted_slice_loc(i) = slice_loc(sorted(i,1));
end
%% Get number of images per slice
slices = unique(sorted_slice_loc);
tally = zeros(size(slices));
for i = 1:length(slices)
   tally(i) = sum(sorted_slice_loc == slices(i));    
end
images_per_slice = mode(tally);
end

