function draw_2d_src_with_compoents(src_2d, w, h, h_val_2d)

[height, width, n] = size(src_2d);
if nargin < 4 
    h_val_2d = uint8(ones(height, width, n)*255);
end
    
num_comp = 3;
n_columns = num_comp;
plot_trf = false;

if nargin > 2
    n_columns = num_comp*2;
    plot_trf = true;
end

for i = 1:num_comp 
    
    ind = i;
    if plot_trf
        ind = (i*2)-1;
        ind2 = (i*2);
    end
    
    subplot(2, n_columns, ind)
    val = w(:,i);
    scalp_plot = ScalpPlot(readLocationFile(LocationInfo(),'Acticap96.loc'));
    scalp_plot.draw(val)
    title(['Component ' num2str(i)],'FontSize', 16);
    % Draw color bar to indicate color axis scale.
    colorMapVal = jet;
    minVal = min(val);
    maxVal = max(val);
    absMin = min(abs(minVal),abs(maxVal));
    absMax = max(abs(minVal),abs(maxVal));
    minVal = -absMax;
    maxVal = absMax;
    meanVal = mean([minVal maxVal]);
    colorAxisRange = [minVal maxVal];
    c_axis = [minVal meanVal maxVal];
    
    if i == 1
        c_axis_tick_label = {'min', 'a.u. 0', 'max'};
        scalp_plot.drawColorBar(c_axis, c_axis_tick_label, 'westoutside');
        scalp_plot.setColorAxis(colorAxisRange, colorMapVal);
    end
    
    if plot_trf
        subplot(2, n_columns, ind2); hold on
        trf = squeeze(h(:,i));
        plot(1:30, trf(1:30),'k','LineWidth',1.5)
        set(gca, 'XTick', 0:15:30, 'XTickLabel', [0 500 1000], 'FontSize', 13)
        xlabel('time (ms)', 'FontSize', 13)
        ylim([-1 1])
        ylabel('a.u', 'FontSize', 13)
    end
end

for i = 1:num_comp 
    subplot(2, num_comp, i+num_comp)
    
    % draw default background color
    hold on; imshow(ones(height,width,3)*.5); 
    
    % draw src
    img = src_2d(:,:,i);
    h = imshow(imadjust(img));
    
    % make insigificant areas transparent
    img_significant_area = uint8(h_val_2d(:,:,i)*255);
    set(h, 'AlphaData', img_significant_area);
       
    axis tight
    axis off
    colormap jet
    
    cb = colorbar('location','westoutside');
    [c_min, c_max] = caxis;
    val_min = min(img(:));
    val_max = max(img(:));
    c_min_tick = round(val_min,3);
    c_max_tick = round(val_max,3);
    c_mid_tick = (c_min_tick+c_max_tick)/2
    
    c_axis = [c_min (c_min+c_max)/2 c_max];
    if i == 1
        c_axis_tick_label = {c_min_tick, ['\rho = ' num2str(c_mid_tick)], c_max_tick};
    end

    %set(cb,'Position', [0.10,0.37,0.01,0.29])
    set(cb,'YTick',c_axis,'YTickLabel',c_axis_tick_label,'TickLabelInterpreter', 'tex','FontSize',13)
    set(cb,'YLim',[c_min, c_max])
     caxis([c_min c_max])
end
