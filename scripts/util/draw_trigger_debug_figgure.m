function draw_trigger_debug_figgure(data, time_to_show)

flash_index = data.flash_index;
timestamp = data.timestamp - data.timestamp(1);
timeseries = data.timeseries;

num_samples = length(timestamp);
fs =  round(num_samples/(timestamp(end)-timestamp(1)));

subplot(2,1,1);hold on
plotFlashTriggerEvent(timeseries, timestamp, flash_index)

%% show first t seconds
min_index  = flash_index(1) - fs * 3;
if 1 > min_index
    min_index = 1;
    xmin = - 2;
else
    xmin =  timestamp(min_index);
end
max_index = min_index+time_to_show*fs;
xmax = timestamp(max_index);

subplot(2,2,3);hold on
plotFlashTriggerEvent(timeseries, timestamp, flash_index)
xlim([xmin xmax])
title(['first ' num2str(time_to_show) ' s'])

%% show last  t seconds
subplot(2,2,4);hold on
plotFlashTriggerEvent(timeseries, timestamp, flash_index)

max_index = flash_index(end) + fs * 3;
if num_samples < max_index
    max_index = num_samples;
    xmax =  timestamp(max_index) +  2;
else
    xmax = timestamp(max_index);
end
min_index = max_index-time_to_show*fs;
xmin = timestamp(min_index);
xlim([xmin xmax])
title(['last ' num2str(time_to_show) ' s'])