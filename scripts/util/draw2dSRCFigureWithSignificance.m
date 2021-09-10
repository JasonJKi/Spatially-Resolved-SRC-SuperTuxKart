function draw2dSRCFigureWithSignificance(src_2d, h_2d, num_comp)

[height, width,~] = size(src_2d);

for i_comp = 1:num_comp
    subplot(1,num_comp,i_comp);
    hold on; imshow(ones(height,width,3)*.5); 

    siginficance_img = uint8(h_2d(:,:,i_comp)*255);
    src_img = imadjust(src_2d(:,:,i_comp));
    h = imshow(src_img);
   
    set(h, 'AlphaData', siginficance_img);
    set(gca,'yTickLabel', [], 'xTickLabel', [])
    cbar = colorbar('southoutside');

    vals = src_img(:);
    min_val = 0;
    max_val = max(vals);    
    colorTick = [0 1];
    colorTickLabel = {num2str(0), num2str(round(max_val,3))}; 
    set(cbar, 'XTick', colorTick, 'XTickLabel', colorTickLabel);

    if i_comp == 1
        ylabel('stimulus-response correlation')
    end
    title(['component = ' num2str(i_comp)])
    colormap jet
end