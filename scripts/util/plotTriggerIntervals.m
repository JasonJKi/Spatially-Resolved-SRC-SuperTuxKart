function [time_difference_avg, time_difference_std]  = plotTriggerIntervals(data_1_interval, data_2_interval, interval_time_difference)
time_difference_avg = mean(abs(interval_time_difference));
time_difference_std = std(abs(interval_time_difference));
hold on;
p1 = plot(data_1_interval,'.b');
p2 = plot(data_2_interval,'.r');
std_str = num2str(time_difference_std);
num_triggers = min(length(data_1_interval), length(data_2_interval)) + 1;
mean_str = num2str(time_difference_avg);
title(['trigger interval difference: mean=' mean_str ', std=' std_str])
xlabel(['trigger (N= ' num2str(num_triggers) ')'] )
ylabel('trigger interval (trigger)')
