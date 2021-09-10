function [rhos, metadata_stk_src] = computeSRCByCondition(stimulus, response, cca_estimator, metadata_stk, deception_index)
metadata_stk_src = metadata_stk;

if sum(deception_index)
    deceived_index   = find(deception_index == 1);
    metadata_stk_src = metadata_stk_src(deceived_index,:);
end
[group_index, ~, ~] =  concatenateGroupByCondition_(metadata_stk_src , 1);

% Compute SRC for each run.
file_index = 1:height(metadata_stk);
rhos = zeros(length(group_index), min(cca_estimator.params.kx, cca_estimator.params.ky));
for i_fold = 1:length(group_index)
    
    %disp(i_fold);
    index =  file_index( group_index{i_fold});
    x_test = cat(1, stimulus{index});
    y_test = cat(1, response{index});
    y_test(isnan(y_test)) = 0;
    
    rho = cca_estimator.predict(x_test, y_test);
    rhos(i_fold,:) = rho;
end