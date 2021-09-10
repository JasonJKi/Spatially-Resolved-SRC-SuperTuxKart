function [eeg_out] = epochSTKEeg(eeg, photodiode)
% cut up the EEG based on first and last triggers of epoched photodiode

flash_timestamp = photodiode.timestamp(photodiode.flash_index);
[eeg_flash_index] = epochTimestamp(eeg.timestamp, flash_timestamp);
eeg_epoch_index = eeg_flash_index(1):eeg_flash_index(end);

timestamp =  eeg.timestamp(eeg_epoch_index);
timeseries = eeg.timeseries(eeg_epoch_index,:);

eeg_out = createTimeseries(timeseries, timestamp, eeg.fs, eeg_flash_index);
% eeg_out.timeseries = double(timeseries);
% eeg_out.timestamp = double(timestamp);
% eeg_out.flash_timestamp = double(flash_timestamp');
% eeg_out.flash_index = double(flash_index-flash_index(1)+1)';
% eeg_out.fs = fs; 
% eeg_out.duration = double(timestamp(end) - timestamp(1));
