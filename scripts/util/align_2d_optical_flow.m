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

    stim_filename =  [filename '_' stim_type '_' alignment_type '.mat'];
    stimulus_aligned_path = [my_data.aligned_data_dir.(stim_type) '/' stim_filename];
    if exist(stimulus_aligned_path,'file')
        continue
        %         disp('load processed stim: filename')
        %         stim_aligned = load(stimulus_aligned_path);        
    else
        disp(['aligning: ' filename])
        video_trigger_path = [my_data.epoched_data_dir.video_trigger '/' filename '_video_trigger.mat'];
        video_trigger = load(video_trigger_path); % epoched video trigger
        
        % load photodiode trigger mat (epoched).
        photodiode_trigger_path = [my_data.epoched_data_dir.photodiode_trigger '/' filename  '_photodiode_trigger.mat'];
        photodiode = load(photodiode_trigger_path); % epoched photodiode trigger
        photodiode.flash_dropped=false;
        
        % load video stimulus features.
        stimulus_feature_path = [my_data.epoched_data_dir.optical_flow '/' filename '_' stim_type];
        stim =  load(stimulus_feature_path, 'data', 'timestamp', 'fs', 'duration');

        % load raw eeg mat.
        eeg_mat_filenpath = [my_data.raw_data_dir.eeg '/' filename '_eeg.mat'];
        eeg = load(eeg_mat_filenpath);
        
        % epoch video and eeg based on triggers.
        [stim_epoched] = epochSTKVideo(stim, video_trigger);
        [eeg_epoched] = epochSTKEeg(eeg,  photodiode);
        fig1 = plotVideoEegLength(stim_epoched, eeg_epoched, video_trigger, photodiode, is_debug_mode, 1);
        suptitle(filename); saveas(fig1, ['output\synchronization_debug_figure\epoched_trigger\trigger_' filename],'jpg')
        
        % Cut the timeseries data at the same start and flash index.
        [stim_parsed, eeg_parsed] =  parseFromStartToEndFlash(stim_epoched, eeg_epoched, video_trigger, photodiode);
        % fig2 = plotVideoEegLength(stim_parsed, eeg_parsed, video_trigger, photodiode, is_debug_mode, 2);
        
        stim_parsed.timeseries = resizeVideo(stim_parsed.timeseries,1/2,0);

        if is_warp_correct
            [stim_aligned] = alignStimulusEEGWithWarpCorrection(stim_parsed, eeg_parsed, video_trigger, photodiode);
            fig2 = plotWarpCorrectedTimeseries(stim_parsed, stim_aligned, eeg_parsed, is_debug_mode, 2);
            suptitle(filename); saveas(fig2, ['output\synchronization_debug_figure\warping\warped_data_' filename],'jpg')
            
            [stim_aligned, eeg_aligned] = alignTimeseriesLength(stim_aligned, eeg_parsed,  stim_parsed.fs);
            
            stim_filename =  [filename '_' stim_type  '_' alignment_type '.mat'];
            stimulus_aligned_path = [my_data.aligned_data_dir.(stim_type) '/' stim_filename];
            
            save(stimulus_aligned_path,  '-struct', 'stim_aligned') 
            
            eeg_filename = [filename '_eeg_' alignment_type '.mat'];
            eeg_aligned_filepath = [my_data.aligned_data_dir.eeg '/' eeg_filename];
            save(eeg_aligned_filepath,  '-struct', 'eeg_aligned')

        else
            % Match sample eeg and stim fs and cut to match the length.
            [stim_aligned, eeg_aligned] = alignTimeseriesLength(stim_parsed, eeg_parsed,  stim_parsed.fs);            

            stim_filename =  [filename '_' stim_type '_aligned.mat'];
            save(stimulus_aligned_path,  '-struct', 'stim_aligned')
            
            eeg_filename = [filename '_eeg_' alignment_type '.mat'];
            eeg_aligned_filepath = [my_data.aligned_data_dir.eeg '/' eeg_filename]
            save(eeg_aligned_filepath,  '-struct', 'eeg_aligned')

        end
        
    end
end

% stim_2 = load('E:\Active-Passive-SRC\data\supertuxkart-session-1\mat\processed\video\features\aligned_2d\stk_13_0_1_1_optical_flow_warped.mat')

% stim_1 = load('E:/Active-Passive-SRC-2D/data/aligned/optical_flow/stk_1_1_0_1_1_optical_flow_aligned.mat')

% sum(squeeze((stim_aligned.timeseries(1000,:,:) == stim_2.timeseries(1000,:,:))))