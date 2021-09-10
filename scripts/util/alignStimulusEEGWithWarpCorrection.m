function [stim_epoched, fig_debug]= alignStimulusEEGWithWarpCorrection(stim_epoched, eeg_epoched, video_trigger, photodiode, is_debug_mode)
% Correct warped timeseries data.
if  ~(photodiode.flash_dropped || video_trigger.flash_dropped)
    disp('performing warp correction')
    %         in order for the stimulus to have equal number of stimulus to eeg
    %         number of flash we have to check that the trigger beginning and
    %         ends are happening at the same time.

    timestamp_ref = eeg_epoched.timestamp;
    indicator_index_ref = eeg_epoched.flash_index;
    fs_ref = eeg_epoched.fs;
    
    [stim_warp_corrected] = warpCorrectTimeseries(stim_epoched, timestamp_ref, indicator_index_ref, fs_ref);
    
    stim_epoched = stim_warp_corrected;
    
%     figure_number = 2;
%     fig_debug = plotWarpCorrectedTimeseries(stim_epoched, stim_warp_corrected, eeg_epoched, is_debug_mode, figure_number);    
end
