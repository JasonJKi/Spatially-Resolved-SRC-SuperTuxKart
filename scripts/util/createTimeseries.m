function data = createTimeseries(timeseries, timestamp, fs, flash_index)

timestamp = double(timestamp(:));
data.timeseries = double(timeseries);
data.timestamp = timestamp;
data.fs = double(round(fs));
data.duration = double(timestamp(end) - timestamp(1));
if nargin > 3
    flash_index = double(flash_index-flash_index(1)+1);
    data.flash_index = flash_index(:);
    data.flash_timestamp = timestamp(data.flash_index);
end

