function [stimulus, response] = loadProcessedSTKData(metadata, stimulus_aligned_data_dir, eeg_processed_mat_dir, feature_type, eeg_type)

stimulus={}; response={};
fileIndex = find(metadata.status==1)';
num_files = length(fileIndex);
% version_str =[]; % version_str = _v0.01;
for i_file = fileIndex
    
    % Get race information and assign num and string variables.
    filename = metadata.filename{i_file};
    stimulus_filename = [filename '_' feature_type];
    stimulus_path = [stimulus_aligned_data_dir '/' stimulus_filename];
    disp(['loading stim:' stimulus_path])
    
    stim = load(stimulus_path);
    %  x = videoTRF(stim.data, stim.fs);
    x = tplitz(zscore(stim.timeseries(:)), stim.fs); % tplitz for temporal response filter
    
    % load eeg.
    eeg_filename = [filename '_eeg' eeg_type '.mat'];
    eeg_processed_path = [eeg_processed_mat_dir '/' eeg_filename];
    disp(['loading response:' eeg_processed_path])
    
    eeg = load(eeg_processed_path);
    y = eeg.timeseries;
    
    num_samples = min(length(x), length(y));
    % duration = floor(num_samples;/fs);
    
    stimulus{i_file} = x;
    response{i_file} =  y;
    
end


end