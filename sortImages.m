function sorted_images = sortImages(images, info)
loc = zeros(length(info),2);
for i = 1:length(info)
    loc(i,1) = i;
    loc(i,2) = info(i).data.InstanceNumber;
end
sorted = sortrows(loc,2);
[x,y,z] = size(images);
sorted_images = zeros(x,y,z);
for i = 1:length(sorted)
   sorted_images(:,:,i) = images(:,:,sorted(i,1)); 
end
end

