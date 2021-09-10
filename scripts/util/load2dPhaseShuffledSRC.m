function [src_2d_phase_shuffled] = load2dPhaseShuffledSRC(file_dir)
%% compute 2d src with cross validation.

dir_list = ls(file_dir);
filenames = dir_list(3:end,:);
num_files = size(filenames,1);

for i_fold = 1:num_files    
    filepath = [file_dir '\' filenames(i_fold,:)];
    load(filepath, 'src_2d')
    src_2d_phase_shuffled(:,:,:,i_fold) = src_2d;
%     A_2d_phase_shuffled(:,:,:,:,i_fold) = A_2d;
%     B_2d_phase_shuffled(:,:,:,:,i_fold) = B_2d;
end