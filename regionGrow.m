function regionGrow(img)
figure; imagesc(img); colormap(gray)
[x,y] = ginput(1);

% Slightly different approach
% I binarized the image (see author's example for when it isn't binary)
% work on extending around all identified pixels at once

% create a vector of x and y coordinates of all pixels already identified
% to be part of the region.  To start we only have 1 of each
xmax = size(img,1);
ymax = size(img, 2);

% initialize at this location
locx = round(x);
locy = round(y);
avg = img(locx, locy);
% generate values to initialize while loop
old_locx = [];
old_locy = [];

% I'll store the segment here
seg_loc = 0*img;

% I'll use this to control the segment number used to identify the segment
% in seg_loc.  This will become more useful in the homework, since you'll
% create multiple segments
seg_label = 1;
% will have to change this everytime you finish a segment

while length(locx)~=length(old_locx)  % suffices to only check x
    old_locx = locx;
    old_locy = locy;
    loc_linear = sub2ind(size(img), old_locx, old_locy);

    avg = mean(img(loc_linear));
    
    

end

 figure
 imagesc(seg_loc)

 imagesc(imfuse(img, seg_loc))
 
end