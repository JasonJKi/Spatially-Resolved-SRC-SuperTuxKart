function   [flash_index]  = epochTimestamp(timestamp, timestamp_ref)


for i = 1:length(timestamp_ref)
    time_ref = timestamp_ref(i);
    [time_src, index] = min(abs(timestamp-time_ref));
%     flash_timestamp(i) = timestamp(index);
    flash_index(i) = index;
end
