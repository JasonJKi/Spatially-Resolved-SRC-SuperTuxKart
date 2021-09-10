function  draw_transparent_overlay_significant_area(img, index_sig_val)
hold on;
% draw default background color
[height,width,~] = size(img);
imshow(ones(height,width,3)*.5); 
h = imshow(imadjust(img));    

%draw transparent overlay for significant regions
transparent_overlay = index_sig_val;
zero_index = (transparent_overlay == 0)*.05;
transparent_overlay = transparent_overlay + zero_index;
img_significant_area = uint8(transparent_overlay*255);
set(h, 'AlphaData', img_significant_area);
axis tight
axis off