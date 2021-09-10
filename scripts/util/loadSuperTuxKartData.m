function [stimulus, response, eyelink] = loadSuperTuxKartData(my_data, metadata_stk, is_warp_correct)
num_files = height(metadata_stk);

alignment_type = '';
stim_type = 'optical_flow';

if is_warp_correct; alignment_type = 'warp_corrected';end

for i_file = 1:num_files
    
    filename = metadata_stk.filename{i_file};
    
    eeg_filename = [filename '_eeg_' alignment_type '_rpca.mat'];
    eeg_processed_aligned_filenpath = [my_data.aligned_data_dir.eeg '/' eeg_filename];
    disp(['loading: ' eeg_filename])
    
    stim_filename =  [filename '_' stim_type '_' alignment_type '.mat'];
    stimulus_aligned_path = [my_data.aligned_data_dir.(stim_type) '/' stim_filename];

    eyelink_filename = [filename '_eyelink_aligned.mat'];
    eyelink_aligned_filepath = [my_data.aligned_data_dir.eyelink '/' eyelink_filename];

    stim_aligned = load(stimulus_aligned_path);
    eeg_processed_aligned = load(eeg_processed_aligned_filenpath);

    stim = stim_aligned.timeseries;
    res = eeg_processed_aligned.timeseries;

    n_eye = length(res);
    eye = zeros(n_eye,1);  
    if exist(eyelink_aligned_filepath,'file')
        eyelink_processed_aligned = load(eyelink_aligned_filepath);
        eye = eyelink_processed_aligned.timeseries;

        w = eyelink_processed_aligned.ref_width;
        h = eyelink_processed_aligned.ref_height;
        
        x_pos = eye(:,1)/w;
        y_pos = eye(:,2)/h;
        
        eye(:,7) = x_pos;
        eye(:,8) = y_pos;

        n_eye = length(eye);
    end

    n_stim = length(stim);
    n_response = length(res);

    n = min([n_stim n_response, n_eye]);
    disp(n)
    metadata_stk.race_time{i_file} = n/30;
    stim = stim(1:n,:,:);
    res = res(1:n,:);
    eye = eye(1:n,:);

    stimulus{i_file} = stim;
    response{i_file} = res;
    eyelink{i_file}.data = eye;
    eyelink{i_file}.ref_width = w;
    eyelink{i_file}.ref_height = h;
end