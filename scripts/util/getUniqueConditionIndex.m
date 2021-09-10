function [uniqueSubjectConditionIndex, condition_index] = getUniqueConditionIndex(conditionIndex, subject)

uniqueConditionIndex = subject*100+conditionIndex;
uniqueVals = unique(uniqueConditionIndex);
for i = 1:length(subject)
    currentIndex = uniqueConditionIndex(i);
    for ii = 1:length(uniqueVals)
        if currentIndex == uniqueVals(ii)
            uniqueSubjectConditionIndex(i) = ii;
            condition_index(ii) = conditionIndex(i);
        end
    end
end