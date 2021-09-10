function plotPhotodiodeFlashEvent_(photodiode)
% epoch photodiode based on first and last flash of the race.
timeseries = photodiode.timeseries;
timestamp = photodiode.timestamp; 
flash_index = photodiode.flash_index;

timeseries = timeseries/max(timeseries);

stem(timestamp, timeseries ,'.g')
stem(timestamp(flash_index),timeseries(flash_index),'ob')
% plot(timestamp([flash_index(1) flash_index(end)]), 1,'*y')

