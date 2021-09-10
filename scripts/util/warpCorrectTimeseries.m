function [data_corrected] = warpCorrectTimeseries(data_warped, timestamp_ref, indicator_index_ref, fs_ref)

timeseries_src = data_warped.timeseries;
timestamp_src =data_warped.timestamp;
indicator_index_src = data_warped.flash_index;

trigger_events_timeseries_src = zeros(length(timeseries_src),1);
trigger_events_timeseries_src(indicator_index_src) =1;

% Timeseries and timestamp of the matching moments in warped timeseries data.
indicator_timestamp_src = timestamp_src(indicator_index_src);
indicator_timeseries_src = timeseries_src(indicator_index_src);

% Timestamp of the matching moments in the reference timeseries data.
indicator_timestamp_ref = timestamp_ref(indicator_index_ref); 
time_interval_ref = [0; diff(indicator_timestamp_ref)];
num_indicators = numel(indicator_timestamp_ref);

%% Make sure that there is even number of matching indices.
if num_indicators ~= numel(indicator_timestamp_src)
    error('Indicator lengths do not match');
end

%% linear time alignment  
% to fill in features in between triggers
% linearly interpolate
timestamp_src_corrected = linearlyAlignTimestamp(indicator_index_src, indicator_timestamp_ref, num_indicators);

% timestamp_ref = (indicator_timestamp_ref(1):1/fs_ref:indicator_timestamp_ref(end))';
if ndims(timeseries_src) > 2
    timeseries_src_corrected = interpVideo(timestamp_src_corrected, timeseries_src, timestamp_ref);
else
    timeseries_src_corrected = interp1(timestamp_src_corrected, timeseries_src, timestamp_ref, 'linear', 'extrap')';
end

trigger_corrected = interp1(timestamp_src_corrected, trigger_events_timeseries_src, timestamp_ref, 'linear', 'extrap')';

timestamp_src_corrected = timestamp_ref(indicator_index_ref(1):indicator_index_ref(end)); 
val = min([length(timeseries_src_corrected) length(timestamp_src_corrected)]);

timeseries = timeseries_src_corrected(1:val,:,:);
timestamp = timestamp_src_corrected(1:val);
trigger_corrected(trigger_corrected < 1) = 0;
trigger_index = find(trigger_corrected');

data_corrected = createTimeseries(timeseries, timestamp, fs_ref, trigger_index);

% data_corrected.fs = fs_ref;
% data_corrected.trigger_events = trigger_index_corrected';
% trigger_index_corrected(trigger_index_corrected < 1) = 0;
% data_corrected.trigger_index = find(trigger_index_corrected');
end