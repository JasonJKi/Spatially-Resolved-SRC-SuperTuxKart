function [labstream_out] = epochSTKLabstream(labstream, photodiode)
% cut up the EEG based on first and last triggers of epoched photodiode

flash_timestamp = photodiode.timestamp(photodiode.flash_index);
[labstream_flash_index] = epochTimestamp(labstream.timestamp, flash_timestamp);
labstream_epoch_index = labstream_flash_index(1):labstream_flash_index(end);

timestamp =  labstream.timestamp(labstream_epoch_index);
timeseries = labstream.timeseries(labstream_epoch_index,:);

labstream_out = createTimeseries(timeseries, timestamp, labstream.fs, labstream_flash_index);