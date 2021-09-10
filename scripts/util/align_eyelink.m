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

for i_file = file_index(1:end)
    
    % Get file name for each subject and run combination.
    % filename = stk_subjectNumber_runNumber_condition_trial
    filename = metadata_stk.filename{i_file};

    % load raw eyelink mat.
    eyelink_filename = [filename '_eyelink_processed.mat'];
    out_dir = [my_data.aligned_data_dir.eyelink '/processed_not_aligned'];
    eyelink_processed_filepath = [out_dir '/' eyelink_filename];

    metadata_stk.eye_data_status(i_file) = 0;
    if exist(eyelink_processed_filepath, 'file')
        disp(['aligning: ' filename])
        eyelink = load(eyelink_processed_filepath);

        video_trigger_path = [my_data.epoched_data_dir.video_trigger '/' filename '_video_trigger.mat'];
        video_trigger = load(video_trigger_path); % epoched video trigger
        
        % load photodiode trigger mat (epoched).
        photodiode_trigger_path = [my_data.epoched_data_dir.photodiode_trigger '/' filename  '_photodiode_trigger.mat'];
        photodiode = load(photodiode_trigger_path); % epoched photodiode trigger
        photodiode.flash_dropped=false;
        
        % load video stimulus features.
        stimulus_feature_path = [my_data.epoched_data_dir.optical_flow '/' filename '_' stim_type];
        stim =  load(stimulus_feature_path, 'data', 'timestamp', 'fs', 'duration');

        % epoch video and eyelink based on triggers.
        [stim_epoched] = epochSTKVideo(stim, video_trigger);
        [eyelink_epoched] = epochSTKLabstream(eyelink, photodiode);
        %     fig1 = plotVideoEegLength(stim_epoched, eyelink_epoched, video_trigger, photodiode, is_debug_mode, 1);
        %     suptitle(filename); saveas(fig1, ['output\synchronization_debug_figure\epoched_trigger\trigger_' filename],'jpg')
        
        % Cut the timeseries data at the same start and flash index.
        [stim_parsed, eyelink_parsed] =  parseFromStartToEndFlash(stim_epoched, eyelink_epoched, video_trigger, photodiode);

        % fs_target = stim_parsed.fs;
        % eyelink_parsed.label = eyelink.label;
        % eyelink_filename = [filename '_eyelink_aligned.mat'];
        % eyelink_processed_filepath = [my_data.aligned_data_dir.eyelink '/' eyelink_filename];
        % save(eyelink_processed_filepath,  '-struct', 'eyelink_parsed')

        n_samples = length(eyelink_parsed.timeseries);
        n_bad_samples = sum(eyelink_parsed.timeseries(:,end));

        bad_sample_ratio = n_bad_samples/n_samples;
        if bad_sample_ratio < .1
            metadata_stk.eye_data_status(i_file) = 1;
        end

        %         plot(eyelink_parsed.timeseries(:,end))
        % fig2 = plotVideoEegLength(stim_parsed, eyelink_parsed, video_trigger, photodiode, is_debug_mode, 2);
        
        fs_target = stim_parsed.fs;
        eyelink_aligned.timeseries = resample(double(eyelink_parsed.timeseries),  fs_target,  eyelink_parsed.fs);
        eyelink_aligned.fs = fs_target;
        eyelink_aligned.label = eyelink.label;
        
        if metadata_stk.session(i_file) == 1
            eyelink_aligned.ref_width = 1280;
            eyelink_aligned.ref_height = 720;
        elseif metadata_stk.session(i_file) == 2
            eyelink_aligned.ref_width = 1980;
            eyelink_aligned.ref_height = 1080;
        end

        eyelink_filename = [filename '_eyelink_aligned.mat'];
        eyelink_processed_filepath = [my_data.aligned_data_dir.eyelink '/' eyelink_filename];
        save(eyelink_processed_filepath,  '-struct', 'eyelink_aligned')
    else
        
        disp(['eyelink for ' filename ' does not exist'])

    end
end
my_data.save_metadata(metadata_stk);

% stim_2 = load('E:\Active-Passive-SRC\data\supertuxkart-session-1\mat\processed\video\features\aligned_2d\stk_13_0_1_1_optical_flow_warped.mat')

% stim_1 = load('E:/Active-Passive-SRC-2D/data/aligned/optical_flow/stk_1_1_0_1_1_optical_flow_aligned.mat')

% sum(squeeze((stim_aligned.timeseries(1000,:,:) == stim_2.timeseries(1000,:,:))))