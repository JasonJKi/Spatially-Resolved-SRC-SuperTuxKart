function [photodiode] = epochSTKPhotodiode(photodiode, is_debug, quick_fix)

% Epoch eeg from the flash occurences recorded by phtodiode.
% Figure out time of on-screen flashes from the photodiode
timeseries = photodiode.timeseries;
timestamp = photodiode.timestamp;
event_code = unique(timeseries);
flash_event_code = max(event_code);
num_event_codes = length(event_code);

if num_event_codes > 1
    [flash_index] = parsePhotodiodeFlash1_(photodiode, flash_event_code, is_debug, quick_fix);
elseif num_event_codes == 1
    [flash_index, timeseries] = parsePhotodiodeFlash2_(photodiode, is_debug, quick_fix);
end

epoch_index = (flash_index(1): flash_index(end))';
timeseries = timeseries(epoch_index);
timestamp = timestamp(epoch_index); 
photodiode = createTimeseries(timeseries, timestamp, [], flash_index);
photodiode.flash_dropped = false;
photodiode.manually_corrected_trigger = quick_fix;

