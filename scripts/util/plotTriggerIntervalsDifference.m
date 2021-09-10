function [time_difference_avg, time_difference_std]  = plotTriggerIntervalsDifference(data_1_interval, data_2_interval, interval_time_difference)
time_difference_avg = mean(abs(interval_time_difference));
time_difference_std = std(abs(interval_time_difference));
hold on;
num_triggers = min(length(data_1_interval), length(data_2_interval));

index = (1:num_triggers)';
plot(data_1_interval(index) - data_2_interval(index),'.k');
ylabel('time')
