% there are three different experimental recording sessions organized into
% 3 different folders with same structure.
root_dir = '../';
stk_data_version = ['supertuxkart-session-' num2str(session)];

% data directories for raw files.
raw_data_dir = [root_dir 'data/' stk_data_version '/raw'];
mat_data_dir =  [root_dir 'data/' stk_data_version '/mat'];

labstream_data_dir = [raw_data_dir '/labstreams'];
% files and folders that are manually generated that are manually 
video_dir = [raw_data_dir '/video/resized' version];
video_timestamp_dir = [raw_data_dir '/video/timestamp/']; 

% mat files unprocessed
eyelink_mat_dir =  [mat_data_dir '/unprocessed/eyelink/']; %mkdir(eyelink_mat_dir);
eeg_mat_dir = [mat_data_dir '/unprocessed/eeg/']; %mkdir(eeg_mat_dir);
eeg_aligned_mat_dir  = [mat_data_dir '/unprocessed/eeg/aligned' ]; %mkdir(eeg_aligned_mat_dir);
bad_electrode_index_dir = [eeg_mat_dir 'bad_electrode_index']; %mkdir(bad_electrode_index_dir);
photodiode_trigger_dir = [mat_data_dir '/unprocessed/photodiode/' ]; %mkdir(photodiode_trigger_dir)
video_trigger_dir = [mat_data_dir '/unprocessed/video/trigger']; %mkdir(video_trigger_dir)

% processed data directories
processed_data_dir =  [mat_data_dir '/processed']; %mkdir(processed_data_dir)

video_trigger_epoched_dir = [processed_data_dir '/triggers_epoched/video' ]; %mkdir(video_trigger_epoched_dir)
photodiode_trigger_epoched_dir = [processed_data_dir '/triggers_epoched/photodiode'];%    %mkdir(photodiode_trigger_epoched_dir)
eeg_processed_mat_dir = [processed_data_dir '/eeg']; %mkdir(eeg_processed_mat_dir)
eeg_processed_aligned_mat_dir =   [processed_data_dir '/eeg/aligned' ]; %mkdir(eeg_processed_aligned_mat_dir)
stimulus_feature_dir = [processed_data_dir '/video/features' ]; %mkdir(stimulus_feature_dir)
stimulus_aligned_data_dir = [processed_data_dir '/video/features/aligned']; %mkdir(stimulus_aligned_data_dir)
eyelink_processed_aligned_data_dir = [processed_data_dir '/eyelink/aligned']; %mkdir(eyelink_processed_aligned_data_dir)
% analysis ready dir
analysis_ready_data_dir = [root_dir 'data/' stk_data_version '/analysis_ready'];

% figure directories
figure_dir = [root_dir 'output/figures/' stk_data_version]; %mkdir(figure_dir);

photodiode_trigger_figure_dir = [figure_dir '/photodiode_trigger'];%mkdir(photodiode_trigger_figure_dir);
video_trigger_figure_dir = [figure_dir '/video_trigger' version]; %mkdir(video_trigger_figure_dir);
trigger_synchronization_figure_dir = [figure_dir '/stim_eeg_synchronization' version];  %mkdir(trigger_synchronization_figure_dir);
preliminary_results_figure_dir = [figure_dir '/prelim_results']; %mkdir(preliminary_results_figure_dir);
eeg_signal_check_dir = [figure_dir '/eeg_signal_quality']; %mkdir(eeg_signal_check_dir);
eeg_artefact_rejection_visualization_dir = [figure_dir '/artefact_rejection']; %mkdir(eeg_artefact_rejection_visualization_dir);
