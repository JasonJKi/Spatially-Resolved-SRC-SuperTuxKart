function [group_index, condition_index, subject_index, deception_index] =  concatenateGroupByCondition_(metadata, grouping)

if ~ grouping
    file_index = find(metadata.status==1)';
    group_index = num2cell(file_index,1);
    condition_index = metadata.condition(:);
    subject_index = metadata.subject_id(:);
    return
end

% group trials
[uniqueSubjectConditionIndex] = getUniqueConditionIndex(metadata.condition, metadata.subject_id);
grouping = unique(uniqueSubjectConditionIndex);
deception_ind = metadata.bci_deception_success;
deception_ind(find(deception_ind ~= 1 )) = 0;
for i = 1:length(grouping)
    
    group = find(uniqueSubjectConditionIndex==i);
    stim_group_ = []; response_group_ = []; grouping_index_= [];
    for ii = 1:length(group)
        subject = mean(metadata.subject_id(group));
        condition = mean(metadata.condition(group));
        deceived = mean(deception_ind(group));
    end
    group_index{i} = group;
    condition_index(i,:) = condition;
    subject_index(i,:) = subject;
    deception_index(i,:) = deceived;
end

end