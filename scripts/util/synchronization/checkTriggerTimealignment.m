function [data_1_interval,  data_2_interval, interval_time_difference] = checkTriggerTimealignment(data_1_timestamp, data_2_timestamp)

data_1_interval = [diff(data_1_timestamp)];
data_2_interval = [diff(data_2_timestamp)];

minLength = min(length(data_2_interval), length(data_1_interval));
data_1_interval = data_1_interval(1:minLength);
data_2_interval = data_2_interval(1:minLength);

interval_time_difference = data_1_interval(1:minLength) - data_2_interval(1:minLength);





    
    