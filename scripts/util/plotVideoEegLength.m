function [fig] =  plotVideoEegLength(stim_epoched, eeg_epoched, video_trigger, photodiode, is_debug, fig_num)

fig = [];
if ~is_debug
    return
end

fig = figure(fig_num);clf
subplot(3,1,1); hold on; plot(eeg_epoched.timestamp(eeg_epoched.flash_index) - photodiode.timestamp(photodiode.flash_index), '.r')
xlabel('flah event time difference between eeg and photodiode timestamp (same machine clock)')
title(['eeg num flashes = ' num2str(length(eeg_epoched.flash_index)) ' duration = ' num2str(eeg_epoched.duration)])
subplot(3,1,2); hold on; plot(diff(stim_epoched.flash_timestamp),'*b'); plot(diff(video_trigger.timestamp(video_trigger.flash_index)),'.r')
title(['stimulus num flashes = ' num2str(length(stim_epoched.flash_index)) ' duration = ' num2str(stim_epoched.duration)])
subplot(3,1,3); hold on; plot(diff(stim_epoched.flash_timestamp), '.b'); plot(diff(eeg_epoched.flash_timestamp), '.r')
title(['num flash difference = ' num2str(length(stim_epoched.flash_index) - length(eeg_epoched.flash_index)) ' time difference = '   num2str(stim_epoched.duration - eeg_epoched.duration)])