function [eyelink] = epochSTKEyelink(lsl, photodiode)
eyelink = [];
if  find(contains(fields(lsl),'eyelink'))    
    start_time = photodiode.epoched_timestamp(1);
    end_time = photodiode.epoched_timestamp(end);
    eeg_epoch_Index = epochTimestamp(lsl.eyelink.timestamp, start_time, end_time);
    
    eyelink.data = lsl.eyelink.timeseries(eeg_epoch_Index,:);
    eyelink.fs = lsl.eyelink.fs;
    eyelink.timestamp = lsl.eeg.timestamp(eeg_epoch_Index);
    eyelink.duration = eyelink.timestamp(end) - eyelink.timestamp(1);
end