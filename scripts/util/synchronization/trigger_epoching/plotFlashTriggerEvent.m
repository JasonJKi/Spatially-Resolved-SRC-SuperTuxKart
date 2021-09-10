function plotFlashTriggerEvent(timeseries, timestamp, flash_index)

first_index = flash_index(1);
last_index = flash_index(end); 
stem(timestamp, timeseries ,'.b')
plot(timestamp(flash_index), timeseries(flash_index), 'or')
plot(timestamp([first_index last_index]), timeseries(first_index), '*y')
legend('events on screen', 'flash marker', 'start & end', 'Location', 'south');
end