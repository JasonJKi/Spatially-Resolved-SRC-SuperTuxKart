function drawTRFOverSelectTimeInterval(trf_2d, time_index, fs)

c_max = max(trf_2d(:));
c_min = min(trf_2d(:));
c_range = max(abs([c_min, c_max]));
c_axis = [-c_range, 0, c_range];
c_axis_tick = {round(-c_range,4), 'a.u. 0',round(c_range,4)};
n_intervals = length(time_index);
clf;[ha,p] = tight_subplot(1,n_intervals,[.002 .002],[.2 .2],[.03 .005]);
for i = 1:n_intervals
    i_t = time_index(i);
    t = (i_t/fs)*1000;
    
    axes(ha(i))
    axis off
%     subplot(1,n_intervals,i);
    img = trf_2d(:,:,i_t);
    imagesc(img);
    xlabel([num2str(round(t)) 'ms'], 'FontSize', 24);
    set(gca,'xTickLabel',[],'YTickLabel', []);
    axis image;
    colormap jet;
    if i == 1
        cb = colorbar('westoutside');     
        set(cb,'TickLabelInterpreter', 'tex','FontSize',14);
        set(cb,'YLim',[c_min, c_max]);
        cb.Label.String = 'a.u.';        
        
        set(cb,'TickLabelInterpreter', 'tex','FontSize',24)
        set(cb,'YTick',[c_min, mean([c_min, c_max]), c_max], 'YTickLabel', {'min', 'a.u. 0', 'max'})
        set(cb, 'AxisLocation', 'out', 'Position',[0.024739583333333,0.2125,0.0046875,0.570833333333333]);

    end
    caxis([c_min c_max]);

end
