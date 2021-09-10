function [video_epoched] = epochSTKVideo(video, video_trigger)
% Epoch video_epoched from the flash occurences on screen.
% Localize the video_epoched view to isolate the flash events in the
% video_epoched and compute the mean of the flash events efficiently.
% Parse the flash events from the video_epoched and find the start and
% end index of the flash on screen.


% Epoch video_epoched
epoched_index = video_trigger.flash_index(1):video_trigger.flash_index(end);
flash_index =  video_trigger.flash_index- video_trigger.flash_index(1)+1;

if isfield(video, 'data_mean')
    timeseries = video.data_mean(epoched_index);
else
    timeseries = video.data(epoched_index,:,:,:);
end

timestamp = video.timestamp(epoched_index);

if isfield(video, 'fs')
    fs = round(double(video.fs));
elseif getfield(video, 'frame_rate')
    fs = round(double(video.frame_rate));
end

video_epoched = createTimeseries(timeseries, timestamp, fs, flash_index);

% video_epoched.timeseries = double(data);
% video_epoched.timestamp = timestamp;
% % video_epoched.timestamp = (1:length(data))'/fs;
% 
% video_epoched.fs = fs;
% video_epoched.flash_index = flash_index;
% video_epoched.flash_timestamp = double(video_epoched.timestamp(flash_index));
% video_epoched.duration = video_epoched.flash_timestamp(end)-video_epoched.flash_timestamp(1);
