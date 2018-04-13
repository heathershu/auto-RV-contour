function regionGrow(img)
figure; imagesc(img); colormap(gray)
[x,y] = ginput(1);
close;
% Slightly different approach
% I binarized the image (see author's example for when it isn't binary)
% work on extending around all identified pixels at once

% create a vector of x and y coordinates of all pixels already identified
% to be part of the region.  To start we only have 1 of each
xmax = size(img,1);
ymax = size(img, 2);

% initialize at this location
locx = round(y);
locy = round(x);
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
j = 1;
while length(locx)~=length(old_locx)  % suffices to only check x
    j
    old_locx = locx;
    old_locy = locy;
    % First create the "grown" coordinates
    newlocx = [old_locx; old_locx; old_locx+1; old_locx-1];
    newlocy = [old_locy-1; old_locy+1; old_locy; old_locy];
    bad = newlocx<1 | newlocx>xmax | newlocy<1 | newlocy>ymax;
    newlocx = newlocx(bad==0);
    newlocy = newlocy(bad==0);
    
    avg = mean(mean(img(old_locx, old_locy)));

    for i = 1:min(length(newlocx), length(newlocy))
        if i<= min(length(newlocx), length(newlocy))
            if abs(img(newlocx(i), newlocy(i)) - avg) > 0.03 * avg
                newlocx(i) = [];
                newlocy(i) = [];
            end
        else
            break
        end
    end
    
    
%     locx = [old_locx; old_locx; old_locx; old_locx+1;...
%         old_locx-1];
%     locy = [old_locy; old_locy-1; old_locy+1; old_locy;...
%         old_locy];
    locx = [old_locx; newlocx];
    locy = [old_locy; newlocy];
    % remove values out of range
    bad = locx<1 | locx>xmax | locy<1 | locy>ymax;
    locx = locx(bad==0);
    locy = locy(bad==0);   

    coord_all = [locx, locy];
    coord_all = unique(coord_all, 'rows');
    % MATLAB can only extract values from a matrix according to multiply
    % (x,y) locations if you first translate to the linear index
    loc_linear = sub2ind(size(img), coord_all(:,1), coord_all(:,2));
    seg_loc(loc_linear) = seg_label;
    % Since we already converted img to 0s and 1s, the right hand side of
    % the above will only create labels for the pixels that should be
    % labeled
    % Last, regenerate the x,y indices that made it to the end
    [locx, locy] = find(seg_loc == seg_label);
    
    
j = j+1;
end

 figure
 imagesc(seg_loc)

 imagesc(imfuse(img, seg_loc))
 
end