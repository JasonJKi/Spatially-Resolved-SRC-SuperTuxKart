clear all; dependencies install
my_data = MyData('E:/Active-Passive-SRC-2D/data');
metadata_stk = my_data.metadata;

file_index = find(metadata_stk.status == 1)';
num_files = length(file_index);

stim_type = 'optical_flow';
is_debug_mode = true;
is_warp_correct = true;
alignment_type = '';
if is_warp_correct; alignment_type = 'warp_corrected';end


for i_file = file_index(186:303)
    
    filename = metadata_stk.filename{i_file};
    disp(['processing: ' filename])
    
    eeg_filename = [filename '_eeg_' alignment_type '_rpca.mat'];
    eeg_processed_aligned_filenpath = [my_data.aligned_data_dir.eeg '/' eeg_filename];
    
    if exist(eeg_processed_aligned_filenpath, 'file') ==2
        eeg_processed = load(eeg_processed_aligned_filenpath);
        disp(['loading:' eeg_processed_aligned_filenpath])
    else
        
        eeg_filename = [filename '_eeg_' alignment_type '.mat'];
        eeg_aligned_filepath = [my_data.aligned_data_dir.eeg '/' eeg_filename];
        
        eeg = load(eeg_aligned_filepath);
        
        eeg_processed = eegRPCAPreprocessingPipeline1(eeg);
        save(eeg_processed_aligned_filenpath,  '-struct', 'eeg_processed')
    end
end
    