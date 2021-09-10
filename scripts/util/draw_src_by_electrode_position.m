function [ind, labels] = draw_src_by_electrode_position(rho_2d, select_label, h_val_2d, src_range)

[rows, columns] = size(select_label); 
ind = [];
elec_loc_info = readLocationFile(LocationInfo(),'Acticap96.loc');
labels = elec_loc_info.channelLabelsCell;
for i = 1:rows
    for ii = 1:columns        
        [~, elec_ind] = ismember(select_label(i, ii),labels);
        ind(i,ii) = elec_ind;
        img = rho_2d(:,:,elec_ind);
        c_axis_all(i,ii,:) = [(min(img(:))) (max(img(:)))];        
        % c_axis_all(i,ii,:) = [min(img(:)) max(img(:))];
    end
end

colormap jet
iter = 1;
for i = 1:rows
    for ii = 1:columns 
        subplot(rows,columns,iter)
        elec_ind = ind(i,ii);
        img = rho_2d(:,:,elec_ind);
        % imagesc(img); colormap jet; axis image; axis off
        
        %  draw src with significance
        index_sig_val = h_val_2d(:,:,elec_ind);
        draw_transparent_overlay_significant_area(img, index_sig_val);
        colormap jet
     
%         c_min = c_axis(1);
%         c_max = c_axis(2);

%         val_min = c_axis(1);
%         val_max = c_axis(2);
            
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
                
        if iter == 1 
            cb = colorbar('location','south');
           
            c_min_tick = round(val_min_desired,3);
            c_max_tick = round(val_max_desired,3);

            c_mid_tick = (c_min_tick+c_max_tick)/2;
        
            c_min = new_c_min;
            c_max = new_c_max;
            c_axis_tick = [c_min (c_min+c_max)/2 c_max];
            c_axis_tick_label = [c_min_tick, c_mid_tick, c_max_tick];
            set(cb,'TickLabelInterpreter', 'tex','FontSize',16)
            set(cb,'YTick',c_axis_tick, 'YTickLabel',c_axis_tick_label)
            set(cb,'YLim',[c_min, c_max])
            set(cb, 'YAxisLocation','bottom')
            set(cb,'Position', [0.279166666666667,0.077777777777778,0.486458333333334,0.027897700119475])
            %             set(cb, 'AxisLocation', 'out', 'Position',[0.00,0.3,0.00,0.5]);
        end
        
        
        caxis([new_c_min new_c_max])

        
        str = labels{elec_ind};
        title(labels(elec_ind),'FontSize', 16);
        iter = iter + 1;
    end
end
ind = ind(:);

