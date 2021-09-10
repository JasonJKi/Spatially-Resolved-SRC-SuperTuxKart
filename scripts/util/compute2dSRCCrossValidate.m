function [src_2d, A_2d, B_2d] = compute2dSRCCrossValidate(stimulus, response, fold, fs, kx, ky, out_path)
%% compute 2d src with cross validation.

num_files = length(stimulus);
num_select = floor(3*(num_files/5));

for i_cv = 1:fold

    random_index = randsample(num_files, num_select);   
    train_index = zeros(num_files,1);
    train_index(random_index) = 1;
    test_index = ~train_index;
    
    stim_train = cat(1, stimulus{find(train_index)});
    resp_train = cat(1, response{find(train_index)});
    
    stim_test = cat(1, stimulus{find(test_index)});
    resp_test = cat(1, response{find(test_index)});
        
    disp(['cross validation' num2str(i_cv)]);
    [src_2d, A_2d, B_2d] = compute2dSRC(stim_train, resp_train, kx, ky, fs, stim_test, resp_test);
    
    iter_num = get_max_iteration_num(out_path) + 1;
    filepath = [out_path '\src_2d_' num2str(iter_num) '.mat'];
    save(filepath, 'src_2d', 'A_2d', 'B_2d')
end

function iter_num = get_max_iteration_num(out_path)
dir_list = ls(out_path);
iter_num = 0;
if length(dir_list) > 2
    dir_list = dir_list(3:end,:);
    for i = 1:size(dir_list,1)
        n(i) = str2double(dir_list(i,end-4));
    end
  iter_num = max(n);
end

