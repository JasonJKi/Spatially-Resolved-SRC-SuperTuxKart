function [stimulus, response] = loadPreprocessedStimEeg(metadata_stk, opts, root_dir)

if nargin < 3
    root_dir = '../';
end

version = opts.version;
stimulus_feature_type = opts.stimulus_feature_type;
eeg_alignment_type = opts.eeg_alignment_type;
eeg_preprocessed_str = opts.eeg_preprocessed_str;

is_preprocess_new = opts.is_preprocess_new;
is_draw_figure = opts.is_draw_figure;
is_debug_mode =opts.is_debug_mode;
is_warp_correct = opts.is_warp_correct;
is_rpca_preprocessing = opts.is_rpca_preprocessing;
is_optimal_preprocessing = opts.is_optimal_preprocessing;
is_virtual_eog = opts.is_virtual_eog;
version_str = opts.video_version;
file_index = find(metadata_stk.status == 1)';
num_files = height(metadata_stk);
dropped_index = [ ];
for i_file = file_index(1:end)
    
    filename = metadata_stk.filename{i_file};
    stk_version = metadata_stk.session(i_file);
    stk_data_version = ['supertuxkart-session-' num2str(stk_version)];

    stimulus_aligned_data_dir = [root_dir 'data/' stk_data_version '/mat/processed/video/features' version_str '/aligned']; 
    stimulus_path = [stimulus_aligned_data_dir '/' filename '_' stimulus_feature_type];
    disp(['loading stim:' stimulus_path])    
    stim = load(stimulus_path);
    
    eeg_processed_aligned_dir =   [root_dir 'data/' stk_data_version '/mat/processed/eeg/aligned' version_str];
    eeg_processed_aligned_filenpath = [eeg_processed_aligned_dir '/' filename '_'  eeg_preprocessed_str '.mat'];

    if exist(eeg_processed_aligned_filenpath, 'file') ==2 && ~is_preprocess_new
        eeg_processed = load(eeg_processed_aligned_filenpath);
        disp(['loading:' eeg_processed_aligned_filenpath])
    else
        
        eeg_aligned_mat_dir =   [root_dir 'data/' stk_data_version '/mat/raw/eeg/aligned' version_str];
        eeg_filepath = [eeg_aligned_mat_dir '/' filename '_'  eeg_alignment_type '.mat'];
        disp(['loading eeg: ' eeg_filepath])
        eeg = load(eeg_filepath);

        % remove bad electrodes.
        bad_electrode_index_dir = [root_dir 'data/' stk_data_version '/mat/raw/eeg/mat/bad_electrode_index'];
        bad_electrode = load([bad_electrode_index_dir '/' filename '.mat'], 'index', 'filename');

        % apply preprocessing on EEG
        if  is_rpca_preprocessing
            eeg_processed = eegRPCAPreprocessingPipeline1(eeg);
        elseif is_optimal_preprocessing
            eeg_processed = eegPreprocessingPipelineOptimal(eeg, bad_electrode.index);
        else
            eeg_processed = eegManaulRemovalPreprocessingPipeline1(eeg, bad_electrode.index);
        end
        
        save(eeg_processed_aligned_filenpath,  '-struct', 'eeg_processed')
    end

    x = tplitz(zscore(stim.timeseries), stim.fs);
    y = eeg_processed.timeseries;
    stimulus{i_file} = x;
    response{i_file} = y;
    
    if length(x) ~= length(y)
        return
    end

    clear eeg_processed eeg;
end