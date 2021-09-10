function [src_2d, A_2d, B_2d] = compute2dPhaseShuffledSRC(stimulus, response, fold, fs, kx, ky, out_path)
%% compute 2d src with cross validation.

num_files = length(stimulus);
num_select = floor(3*(num_files/4));

for i_fold = 1:fold
    random_index = randsample(num_files, num_select);
    
    stim_train = cat(1, stimulus{find(random_index)});
    response_train = cat(1, response{find(random_index)});    
    response_train = randomizePhase(response_train); % shuffle phase.
    
    disp(['phase_shuffle' num2str(i_fold)]);
    [src_2d, A_2d, B_2d] = compute2dSRC(stim_train, response_train, kx, ky, fs);

    dir_list = ls(out_path);
    n_files = length(dir_list) - 2;
    filepath = [out_path '\src_2d_' num2str(n_files) '.mat'];
    save(filepath, 'src_2d', 'A_2d', 'B_2d')
end

function iter_num = get_max_iteration_num(out_path)
dir_list = ls(out_path);
iter_num = 1;
if length(dir_list) > 2
  dir_list = dir_list(3:end,:);
  for i = 1:size(dir_list,1)
     n(i) = str2double(dir_list(i,end-4));
  end
  iter_num = max(n);
end

