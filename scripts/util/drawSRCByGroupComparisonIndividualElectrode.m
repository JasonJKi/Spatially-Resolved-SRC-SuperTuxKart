function drawSRCByGroupComparisonIndividualElectrode(src_by_group, comparison_grp_index, select_label, grp_name)

[p_left, h_left, p_right, h_right] = compareSRCByGroup2DIndividualElectrode(src_by_group, comparison_grp_index, true);

[rows, columns] = size(select_label); 
ind = [];
elec_loc_info = readLocationFile(LocationInfo(),'Acticap96.loc');
labels = elec_loc_info.channelLabelsCell;
for i = 1:rows
    for ii = 1:columns        
        [~, elec_ind] = ismember(select_label(i, ii),labels);
        ind(i,ii) = elec_ind;
    end
end


iter = 1;
for i = 1:rows
    for ii = 1:columns 
        subplot(rows,columns,iter)
        elec_ind = ind(i,ii);
        
        img = h_right(:,:,elec_ind);
        imshow(img)

        str = labels{elec_ind};
        title(str,'FontSize', 16);
        iter = iter + 1;
    end
end

suptitle([grp_name(1) ' vs' grp_name(2)])