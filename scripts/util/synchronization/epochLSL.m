function [stream_out] = epochLSL(stream, photodiode)
% cut up the EEG based on first and last triggers of epoched photodiode

trigger_timestamp = photodiode.timestamp(photodiode.flash_index);
[stream_trigger_index] = epochTimestamp(stream.timestamp, trigger_timestamp);
stream_epoch_index = stream_trigger_index(1):stream_trigger_index(end);

timestamp =  stream.timestamp(stream_epoch_index);
timeseries = stream.timeseries(stream_epoch_index,:);

stream_out = createTimeseries(timeseries, timestamp, stream.fs, stream_trigger_index);
% stream_out.timeseries = double(timeseries);