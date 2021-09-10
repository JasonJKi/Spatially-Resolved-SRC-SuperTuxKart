function draw_src_components(h, w, ryy)

A = forwardModel(w, ryy);

num_comp = 3;
ind = 1:num_comp;
for i = ind
    subplot(2, num_comp, i)
    val = A(:,i);
    
    loc_info = readLocationFile(LocationInfo, 'ActiCap96.loc');
    scalp_plot = ScalpPlot(loc_info);
    scalp_plot.draw(val);
    
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
    
    subplot(2, num_comp, i+num_comp)
    fs = 30;
    y = squeeze(h(1:fs,i));
    x = 0:fs-1;

    p = plot(x,y,'Color',[1 0 0], 'LineWidth', 2); %  stdshade(h,.25, fig_config.barColor{ii}, x)
    set(gca,'XTick',0:fs/4:fs,'XTickLabel',0:1000/4:1000, 'FontSize', 12)
    
    y_max = max(abs(y));
    y_min = -y_max;
    ylim([y_min y_max] )
    set(gca,'color','none')
    xlabel('Time (ms)')
    
    box off
    
    if (i == 1)
        y_axis_tick = [y_min 0 y_max]';
        y_min_label = num2str(y_min, '%0.1f');
        y_max_label = num2str(y_max, '%0.1f');
        y_axis_tick_label = round(y_axis_tick,2);
        set(gca, 'YTick', y_axis_tick, 'YTickLabel', {'min', 0,'max'}, 'FontSize', 12);
        ylabel('a.u.')
    else
        set(gca, 'YTick', y_axis_tick, 'YTickLabel', []);

    end
    
    
end