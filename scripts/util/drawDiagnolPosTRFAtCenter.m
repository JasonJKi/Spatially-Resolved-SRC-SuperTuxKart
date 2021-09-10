function img = drawDiagnolPosTRFAtCenter(A_2d, fs, x_points, new_size)

[height, width,~,~] = size(A_2d);
% fig3 = figure(fig_num);
i_comp = 1;

val = A_2d(:,x_points,:,i_comp);
c_max = max(val(:));
c_min = min(val(:));

vertical_src = squeeze(mean(A_2d(:,x_points,1:fs,i_comp),2));
img = imresize(vertical_src, new_size);

% [height, width] = size(img);
im = imagesc(img);
% imshow(im.CData)
caxis([c_min c_max])

[height_, width_,~,~] = size(img);

xTick = (0:round(width_/2):width_);
xTickLabel = round((0:round(1000/2):1000));
yTick = (0:(height_/2):height_);
yTickLabel = fliplr(round((0:(height/2):height)));

set(gca,'xTick', xTick, 'xTickLabel', xTickLabel, 'yTick',yTick, 'yTickLabel',yTickLabel, 'FontSize', 14)
xlabel('time (ms)')
ylabel('pixel position')
% title('trf c1 at center x position');
axis image
colormap jet
