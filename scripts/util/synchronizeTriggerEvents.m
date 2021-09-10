function [video_flash_corrected, photodiode_corrected] = synchronizeTriggerEvents(video_flash, photodiode)

video_flash_interval = diff(video_flash.flash_timestamp);
photodiode_flash_interval = diff(photodiode.flash_timestamp);

min_length = min(length(photodiode_flash_interval), length(video_flash_interval));
t_window_video_flash = 10;
t_window_photodiode_flash = 10;
video_flash_interval_ = video_flash_interval(1:min_length);
photodiode_flash_interval_ = photodiode_flash_interval(1:min_length);

iter = 1;
for i = -t_window_video_flash:t_window_photodiode_flash
    
    if i < 0
        i_ = abs(i);
        time_difference = video_flash_interval_(1+i_:end) - photodiode_flash_interval_(1:end-i_);
    elseif i > 0
        i_ = abs(i);
        time_difference = photodiode_flash_interval_(1+i_:end) -  video_flash_interval_(1:end-i_);
    else
        time_difference = photodiode_flash_interval_ - video_flash_interval_;
    end
    
    interval_difference_mean(iter) = mean(time_difference);
    interval_difference_std(iter) = std(time_difference);
    iter = iter + 1;
end
% [~, index_min_interval_difference_mean] = min(abs(interval_difference_mean));
% index_min_interval_difference_mean = index_min_interval_difference_mean-11;

[~, index_min_interval_difference_std] = min(interval_difference_std);
index_min_interval_difference_std = index_min_interval_difference_std-11;

if index_min_interval_difference_std < 0
    i_ = abs(index_min_interval_difference_std);
    photodiode_flash_index = photodiode.flash_index(1:end-i_);
    video_flash_index = video_flash.flash_index(1+i_:end);
elseif i > 0
    i_ = abs(index_min_interval_difference_std);
    photodiode_flash_index = photodiode.flash_index(1+i_:end);
    video_flash_index = video_flash.flash_index(1:end-i_);
else
    photodiode_flash_index = photodiode.flash_index;
    video_flash_index = video_flash.flash_index;
end

photodiode_flash_timestamp = photodiode.timestamp(photodiode_flash_index);
video_flash_timestamp = video_flash.timestamp(video_flash_index);

video_flash_corrected.video_flash_index = video_flash_index;
video_flash_corrected.timestamp = video_flash.timestamp;
video_flash_corrected.flash_timestamp = video_flash_timestamp;
video_flash_corrected.epoched_timestamp = video_flash.timestamp(video_flash_index);
video_trigger_corrected.flash_timestamp
photodiode_corrected.flash_index = photodiode_flash_index;
photodiode_corrected.timestamp = photodiode.timestamp;
photodiode_corrected.flash_timestamp = photodiode_flash_timestamp;
photodiode_corrected.epoched_timestamp = photodiode.timestamp(photodiode_flash_index);
% photodiode_flash_timestamp = photodiode_flash_timestamp-photodiode_flash_timestamp(1);
% video_flash_timestamp = video_flash_timestamp-video_flash_timestamp(1);




    