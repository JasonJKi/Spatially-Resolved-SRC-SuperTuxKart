function timestamp_src_corrected = linearlyAlignTimestamp(indicator_index_src, indicator_timestamp_ref, num_indicators)
num_intervals = num_indicators-1;

timestamp_src_corrected=[];

for f = 1:num_intervals

    % correct timeseries interval
     if f < (num_intervals)
         off_set_index = 1;
     else 
         off_set_index = 0;
     end
    
    trigger_onset_index_src = indicator_index_src(f);
    trigger_off_set_index_src =  indicator_index_src(f+1);
    
     % corrected timestamp interval
     num_samples_between_trigger_src =  trigger_off_set_index_src -trigger_onset_index_src;
     time_between_trigger_ref = indicator_timestamp_ref(f+1) - indicator_timestamp_ref(f);
     
     % scale of time between on-set and offset triggeres between reference and source
     interval_time_warp_scale = time_between_trigger_ref / num_samples_between_trigger_src;
     
     % create a linearly scaled timestamp based on the warped scale for each onset-offset event.
     num_events_between_trigger = trigger_off_set_index_src - trigger_onset_index_src - off_set_index;
     interval_timestamp_corrected =  (0:num_events_between_trigger)' * interval_time_warp_scale + indicator_timestamp_ref(f);
     
     % tq = interp1(x, t, xq);
     timestamp_src_corrected = cat(1, timestamp_src_corrected, interval_timestamp_corrected);     
end
