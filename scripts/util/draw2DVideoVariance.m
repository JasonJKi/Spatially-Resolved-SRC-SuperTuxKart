function draw2DVideoVariance(stim)

if iscell(stim)
    stim = cat(1, stim{:});
end

[~,height, width] = size(stim);
% plot 2d video dynamic
for i = 1:height
    for ii = 1:width
        std_img(i,ii) = var(stim(:,i,ii));
    end
end
% subplot(1,1,1)
imagesc(std_img)
cbar = colorbar('southoutside');
colormap jet
caxis([0 2000])
set(gca,'yTickLabel', [], 'xTickLabel', [])
title('optical flow variance')
axis image