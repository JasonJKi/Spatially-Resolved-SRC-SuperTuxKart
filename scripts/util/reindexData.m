function [timeseries, timestamp, keep_index] = reindexData(timeseries, timestamp, start_time, end_time);
timestamp_ = timestamp - timestamp(1);
keep_index = (start_time < timestamp_) & (end_time > timestamp_);
timeseries = timeseries(keep_index);
timestamp = timestamp(keep_index);