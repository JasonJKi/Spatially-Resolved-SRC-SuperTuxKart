function [ind, labels] = draw_src_by_electrode_position_separate_figures(src_2d, select_label, h_val_2d, figure_dir, src_range)

[rows, columns] = size(select_label); 
ind = [];
elec_loc_info = readLocationFile(LocationInfo(),'Acticap96.loc');
labels = elec_loc_info.channelLabelsCell;
for i = 1:rows
    for ii = 1:columns        
        [~, elec_ind] = ismember(select_label(i, ii),labels);
        ind(i,ii) = elec_ind;
        img = src_2d(:,:,elec_ind);
        c_axis_all(i,ii,:) = [min(img(:)) max(img(:))];
    end
end

fig = createMatlabFigure(1, 10, 6, 'inches');clf;
% fig = figure;
iter = 1;
for i = 1:rows
    for ii = 1:columns
        % subplot(rows,columns,iter)
        clf; subplot(4,4,[1:4 5:8 9:12])
        elec_ind = ind(i,ii);
        img = src_2d(:,:,elec_ind);
        %         imagesc(img); colormap jet; axis image; axis off
        
        % draw src with significance
        index_sig_val = h_val_2d(:,:,elec_ind);
        draw_transparent_overlay_significant_area(img, index_sig_val);
%         truesize([720 1080]/2)
%         set(fig, 'Units', 'inches', 'Position', [0, 0, 10, 4], 'PaperUnits', 'inches', 'PaperSize', [10, 4])
 
        colormap jet
        [c_min, c_max] = caxis;
        
        val_min_desired = src_range(1);
        val_max_desired = src_range(2);
            
        val_min = min(img(:));
        val_max = max(img(:));
        
        c_min_tick = round(val_min,3);
        c_max_tick = round(val_max,3);
            
        val_range = val_max_desired - val_min_desired;
        new_c_min = -(val_min-val_min_desired)/val_range;
        new_c_max = 1 + (val_max_desired-val_max)/val_range;
                
        if iter == 0 
            cb = colorbar('location','south');
           
            c_min_tick = round(val_min_desired,3);
            c_max_tick = round(val_max_desired,3);
            
            c_min_tick = round(val_min,3);
            c_max_tick = round(val_max,3);
            c_mid_tick = (c_min_tick+c_max_tick)/2;
        
            c_axis_tick = [c_min (c_min+c_max)/2 c_max];
            c_axis_tick_label = round([c_min_tick, c_mid_tick, c_max_tick],3);
            set(cb,'TickLabelInterpreter', 'tex','FontSize',24)
            set(cb,'YTick',c_axis_tick, 'YTickLabel',c_axis_tick_label)
            set(cb,'YLim',[c_min, c_max])
            set(cb,'Position', [0.273958333333333,0.352430555555556,0.037895834091016,0.552413194444444])
            %             set(cb, 'AxisLocation', 'out', 'Position',[0.00,0.3,0.00,0.5]);
        end
        
        caxis([new_c_min new_c_max])

        set(gca, 'Position', get(gca, 'OuterPosition') - ...
        get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
        set(gcf,'color','none')

%         export_fig('filename', '-png', '-transparent', '-r300')
         str = labels{elec_ind};
%         title(labels(elec_ind),'FontSize', 24);
%         export_fig([figure_dir '/' str], '-png');
        print( [figure_dir '/' str],'-dpng')
        iter = iter + 1;
%         saveas(fig,  [figure_dir '/' str], 'png')
    end
end
ind = ind(:);

