function fig = draw2dSRCFigure(src_2d, num_comp)
for i_comp = 1:num_comp
    subplot(1,num_comp,i_comp);
    img = src_2d(:,:,i_comp);
    imagesc(img);
%     title(['c' num2str(i_comp)],'FontSize',14) 
    if i_comp ==1
        ylabel('stimulus-response correlation')
    end
    set(gca,'yTickLabel', [], 'xTickLabel', [])
    axis off
    axis image
%     if i_comp ==1
        c_min = min(img(:));
        c_max = max(img(:));
        c_axis = [c_min, (c_max+c_min)/2, c_max];
        cb = colorbar('location','westoutside');
        %             set(cb,'Position', [0.10,0.37,0.01,0.29])
        set(cb,'YTick',c_axis,'YTickLabel',round(c_axis,3))
        set(cb,'TickLabelInterpreter', 'tex','FontSize',14)
        set(cb,'YLim',[c_min, c_max])
%     end
    caxis([c_min, c_max]);
    colormap jet
end

return
% [height, width, ~] = size(src_2d);
% % plot 2d video dynamic
% for i = 1:height
%     for ii = 1:width
%         std_img(i,ii) = var(stim(:,i,ii));
%     end
% end
% subplot(1,num_comp+1,num_comp+1);
% imagesc(std_img)
% title('optical flow variance')
% caxis([0 2000])
% cbar = colorbar('west');
% set(gca,'yTickLabel', [], 'xTickLabel', [])
% colormap jet

