function [data1, data2] =  parseFromStartToEndFlash(data1, data2, trigger1, trigger2)
dropped_trigger = false;
if trigger1.flash_dropped || trigger2.flash_dropped
    dropped_trigger = true;
end
    
timeseries1 = data1.timeseries;
timeseries2 = data2.timeseries;

timestamp1 = data1.timestamp;
timestamp2 = data2.timestamp;

flash_index1 = data1.flash_index;
flash_index2 = data2.flash_index;

if ~ dropped_trigger
    
    num_flashes_1 = length(flash_index1);
    num_flashes_2 = length(flash_index2);
    [val, index] = min([num_flashes_1 num_flashes_2]);
    flash_index1 = flash_index1(1:val);
    flash_index2 = flash_index2(1:val);
end

epoch_index1 = flash_index1(1):flash_index1(end);
timeseries1 = timeseries1(epoch_index1, :, :, :);
timestamp1 = timestamp1(epoch_index1, :, :, :);
data1 = createTimeseries(timeseries1, timestamp1, data1.fs, flash_index1);

% data1.flash_index = flash_index1;
% data1.flash_timestamp = timestamp1(flash_index1);
% data1.duration = data1.flash_timestamp(end) - data1.flash_timestamp(1);
% data1.num_flashes = length(flash_index1);

epoch_index2 = flash_index2(1):flash_index2(end);
timeseries2 = timeseries2(epoch_index2, :, :, :);
timestamp2 = timestamp2(epoch_index2, :, :, :);
data2 = createTimeseries(timeseries2, timestamp2, data2.fs, flash_index2);

% data2.flash_index = flash_index2;
% data2.flash_timestamp = timestamp2(flash_index2);
% data2.duration = data2.flash_timestamp(end) - data2.flash_timestamp(1);
% data2.num_flashes = length(flash_index2);

is_debug = false;
if is_debug
    figure_number = 2;    
    fig2 = plotVideoEegLength(data1, data2, data1, data2, is_debug_mode, figure_number);
end



