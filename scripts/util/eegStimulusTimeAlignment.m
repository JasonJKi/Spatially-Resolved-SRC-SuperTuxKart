function [eeg_aligned, stim_aligned] = eegStimulusTimeAlignment(eeg, stim, photodiode, video_trigger, fs_target, is_warp_correct)
is_debug_mode = false;
[stim_epoched] = epochSTKVideo(stim, video_trigger);
[eeg_epoched] = epochSTKEeg(eeg,  photodiode);

plotVideoEegLength(stim_epoched, eeg_epoched, photodiode, photodiode, is_debug_mode, 1);

% Cut the timeseries data at the same start and flash index.
    [stim_aligned, eeg_aligned] =  parseFromStartToEndFlash(stim_epoched, eeg_epoched, video_trigger, photodiode);

% Apply warping correction to timeseries data.
if is_warp_correct
        stim_aligned = alignStimulusEEGWithWarpCorrection(stim_aligned, eeg_aligned, video_trigger, photodiode, 0);
end

% Match sample eeg and stim and cut match the length.
[stim_aligned, eeg_aligned] = alignTimeseriesLength(stim_aligned, eeg_aligned, fs_target);