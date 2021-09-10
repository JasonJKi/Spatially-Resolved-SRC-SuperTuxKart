function [src_by_group] = averageRacesByIndivdiualSubjectsPaired(src_2d, metadata_stk, paired_index)
num_conditions = numel(unique(metadata_stk.condition));
subject_index = unique(metadata_stk.subject_id);

for i_group = 1:num_conditions

    iter = 1;
    src_all = [];
    for i = 1:length(subject_index)
        subject_id = subject_index(i);
        ind = find((metadata_stk.status) == 1 & (metadata_stk.condition == i_group) & metadata_stk.subject_id == subject_id);
        if ~isempty(ind)
            src = mean(src_2d(:,:,:, ind),4);
            src_all(:,:,:,iter) = src;
            iter = iter +1;
        end
    end
    src_by_group{i_group} = src_all;
%     src_group_avg(:,:,:,i_group) = mean(src_all,4);
end

