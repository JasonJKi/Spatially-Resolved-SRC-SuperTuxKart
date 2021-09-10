function video_trigger = extractVideoTriggersFromFrame(video)
localized_view = localizeVideoView(video.data);
trigger = videoMean2(localized_view);
frame_rate = round(video.frame_rate);
timestamp = ((1:length(trigger))'-1)/frame_rate; % estimated timestamp based on fps and duration.

video_trigger.timeseries = trigger;
video_trigger.timestamp = timestamp;
video_trigger.frame_rate = frame_rate;