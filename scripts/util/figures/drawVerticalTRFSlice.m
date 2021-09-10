function img = drawVerticalTRFSlice(A_2d, fs, x_points, new_size, line_pos, line_color)

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

xTick = [0 round(width_/2) width_]+.5;
xTickLabel = num2cell(round((0:round(1000/2):1000)));
%yTickLabel = fliplr(round((0:(height/2):height)));
yTick = [0, height_]+.5;
yTickLabel = {'top' ,'bottom'};

ax = gca;
ax.XColor = [0, .5, .5];
ax.YColor = [0, .5, .5];
ax.LineWidth = 4;

xlabel('\color{black} time (ms)')
% ylabel('\color{black} Screen Position', 'Position', [-5.311658856045526,24.020158618020357,1])
% title('trf c1 at center x position');
axis image
colormap jet

% prepend a color for each tick label
ticklabels = yTickLabel;
y_tick_label_new = cell(size(yTickLabel));
for i = 1:length(y_tick_label_new)
    y_tick_label_new{i} = ['\color{black} ' ticklabels{i}];
end

% set the tick labels
ticklabels = xTickLabel;
x_tick_label_new = cell(size(ticklabels));
for i = 1:length(ticklabels)
    x_tick_label_new{i} = ['\color{black} ' num2str(ticklabels{i})];
end

% set the x and y ticks
set(gca,'xTick', xTick, 'xTickLabel', x_tick_label_new, 'yTick',yTick, 'yTickLabel',y_tick_label_new, 'FontSize', 14)

% set colorbar
[c_min, c_max] = caxis;
cb = colorbar('location','eastoutside');
set(cb,'TickLabelInterpreter', 'tex','FontSize',14)
set(cb,'YTick',[c_min, mean([c_min, c_max]), c_max], 'YTickLabel', {'min', 'a.u. 0', 'max'})
%             set(cb,'Position', [0.10,0.37,0.01,0.29])
%             set(cb,'YTick',c_axis,'YTickLabel',c_axis_tick_label)

hold on
% pos = [1 4 10];
for i = 1:3
    y(i) = abs(height_-(line_pos(i)*2)+1);
    plot(1:width_,repmat(y(i), 1, width_),'Color',line_color(i,:),'LineWidth',8)
end



