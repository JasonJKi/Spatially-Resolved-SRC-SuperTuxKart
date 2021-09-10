function  [h1, h2] = plotVideoPhotodiodeEvent(video_trigger, photodiode)
video_trigger_timestamp = video_trigger.timestamp;
video_trigger_timeseries = video_trigger.timeseries;
video_flash_index = video_trigger.flash_index;
photodiode_timestamp =  photodiode.timestamp;
photodiode_timeseries = photodiode.timeseries;
photodiode_timeseries = photodiode_timeseries/max(photodiode_timeseries);
photodiode_flash_index = photodiode.flash_index;

time_video = video_trigger_timestamp;
% video_trigger_timestamp = video_trigger_timestamp ;
video_start_time = video_trigger_timestamp(video_flash_index(1)); 


rescaled_video_trigger_timeseries = rescaleData(video_trigger_timeseries, 0, 1);

hold on;
stem(time_video, rescaled_video_trigger_timeseries, '.y');
h1 = stem(time_video(video_flash_index), rescaled_video_trigger_timeseries(video_flash_index), '*r');

photodiode_timeseries = photodiode_timeseries -.125;
photodiode_timestamp = photodiode_timestamp - photodiode_timestamp(1);
photodiode_start_time = photodiode_timestamp(photodiode_flash_index(1));
time_to_shift = photodiode_start_time - video_start_time;

stem(photodiode_timestamp - time_to_shift, photodiode_timeseries ,'.g');
h2 = stem(photodiode_timestamp(photodiode_flash_index) - time_to_shift, photodiode_timeseries(photodiode_flash_index),'ob');
ylim([0 1])


