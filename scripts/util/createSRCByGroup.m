function src_by_group = createSRCByGroup(src_2d, metadata_stk)
group_names = {'active', 'sham', 'passive', 'count'}; 
num_conditions = numel(unique(metadata_stk.condition));

for i_group = 1:num_conditions
    
    ind = find((metadata_stk.status) == 1 & (metadata_stk.condition == i_group));
    
    src = src_2d(:,:,:, ind);
    src_by_group{i_group} = src;
    src_group_avg(:,:,:,i_group) = mean(src,4);
    
end