function [video_trigger] = parseVideoFlashEvents(trigger, threshold, quick_fix, is_debug)

timeseries = trigger.timeseries;
timestamp = trigger.timestamp;

if isfield(trigger, 'frame_rate')
    fs = trigger.frame_rate;
else
    fs = trigger.fs;
end
% threshold = max(timeseries) *.85;

if nargin < 4
    is_debug = 1;
end
    
if nargin < 3
    quick_fix = 0;    
end

if quick_fix && find(strcmp(fields(trigger),'re_index'))
    timeseries_= timeseries;
    timestamp_ = timestamp;
    timeseries_(~ trigger.re_index) = 0;
    timestamp_(~ trigger.re_index) = 0;
    [timeseries_, flash_index ] = filter0(timeseries_, threshold);
    debug_plot(is_debug, flash_index, timeseries_, timestamp_)
    flash_index = filter1(timeseries_);
    debug_plot(is_debug, flash_index, timeseries_, timestamp_)
else
    
    % Filter 1 - Find frames where pixel difference is greater than a set threshold.
%     is_debug =1;
    if is_debug; subplot(6,1,1);end
    [timeseries_, flash_index ] = filter0(timeseries, threshold);
    debug_plot(is_debug, flash_index, timeseries_, timestamp)

    if is_debug; subplot(6,1,2);end
    flash_index = filter1(timeseries_);
    debug_plot(is_debug, flash_index, timeseries, timestamp)
    
    % Filter 2  - Check to see that the first timeseries_ is indeed the first
    % timeseries_.
    if is_debug; subplot(6,1,3);end
    flash_index = filter2(timeseries_, flash_index, timestamp);
    debug_plot(is_debug, flash_index, timeseries, timestamp)
    
    if is_debug; subplot(6,1,4);end
    % Filter 3 - Check to see that the last timeseries_ is indeed the last timeseries_
    flash_index = filter3(timeseries_, flash_index, timestamp);
    debug_plot(is_debug, flash_index, timeseries, timestamp)
    
    if is_debug; subplot(6,1,5);end
    % Filter 4 - Check to see that there is no jitter recorded at the end.
    flash_index = filter4(flash_index, timestamp, timeseries_);
    debug_plot(is_debug, flash_index, timeseries, timestamp)
    
    % Filter 5 - Check to see that the true first flash event wasnt missed.
    flash_index = filter5(timeseries_, flash_index, timestamp);
    if is_debug; subplot(6,1,6);end
    debug_plot(is_debug, flash_index, timeseries, timestamp)
    
end
% flash_index = filter6(flash_index, timestamp, timeseries);
% debug_plot(is_debug, flash_index, timeseries, timestamp)
% video_trigger = createTimeseries(timeseries, timestamp, frame_rate, flash_index);

video_trigger.timeseries = timeseries;
video_trigger.timestamp = timestamp;
video_trigger.fs = fs;
video_trigger.flash_index = flash_index;
video_trigger.flash_timestamp = timestamp(flash_index);
video_trigger.duration = video_trigger.flash_timestamp(end) - video_trigger.flash_timestamp(1);
end

function     [timeseries, flash_index] = filter0(timeseries, threshold)

possible_flash_indicator =timeseries > threshold;
timeseries(~possible_flash_indicator) = 0;
flash_index =  find(possible_flash_indicator);
end

function    flash_index = filter1(timeseries)
threshold = 200;
possible_flash_indicator = diff(timeseries);
possible_flash_indicator = possible_flash_indicator > threshold;
flash_index = find(possible_flash_indicator) + 1;
end


function flash_index = filter2(timeseries, flash_index, timestamp)

% find indexes with a lower bound threshold to find all spiking events.
% this bit of code checks to find that the first flash is indeed the first
% frame found in the video.
possible_flash_indicator = diff(timeseries);

possible_flash_indicator = possible_flash_indicator > 10;
flash_index_ = find(possible_flash_indicator) + 1;

current_first_index = flash_index(1);
first_index_ = flash_index_(1);

% check that the two flash indices are not equal
if ~(first_index_ == current_first_index)
    
    matching_first_flash_index = find(flash_index_ == current_first_index);
    possible_first_index =  flash_index_(matching_first_flash_index-1);
    
    time_interval_between_possible_first_index = abs(timestamp(current_first_index) - timestamp(possible_first_index));
    
    median_interval = median(diff(timestamp(flash_index)));
    std_interval = std(diff(timestamp(flash_index)));
    lower_bound_threshold = abs(median_interval - 2 * std_interval);
    upper_bound_threshold = abs(median_interval + 5 * std_interval);
    
    if (time_interval_between_possible_first_index  > lower_bound_threshold) && (time_interval_between_possible_first_index < upper_bound_threshold)
        first_index = possible_first_index;
        flash_index = [first_index; flash_index];
        disp('filter 3 applied')
    end
    
end

% hold on; plot(timeseries); plot(flash_index_, timeseries(flash_index_),'r.')
% plot(flash_index, timeseries(flash_index),'y.')
% plot(possible_first_index, timeseries(possible_first_index),'k*')
% plot(current_first_index, timeseries(possible_first_index),'g*')


end


function flash_index = filter5(timeseries, flash_index, timestamp)

flash_event_timestamp = timestamp(flash_index);
flash_event_interval = diff(flash_event_timestamp);
std_flash_event_interval = std(flash_event_interval);
median_flash_event_interval = median(flash_event_interval);

lower_bound_threshold = median_flash_event_interval - std_flash_event_interval*2;
upper_bound_threshold = median_flash_event_interval + std_flash_event_interval*10;

current_first_index = flash_index(1);

flash_index_ = find(diff(timeseries) > 10) + 1;
matching_index = find(flash_index_ == current_first_index);

if matching_index == 1
    return
end
possible_first_index = flash_index_(matching_index-1);

time_difference = timestamp(current_first_index) - timestamp(possible_first_index);

if time_difference > lower_bound_threshold && time_difference < upper_bound_threshold
    flash_index = [possible_first_index; flash_index];
    disp('filter 2a applied')
end


end

function flash_index = filter3(timeseries, flash_index, timestamp)

flash_events = timeseries(flash_index);

% threshold = median_flash_event_pixel_intensity - std_flash_event_pixel_intensity * 10;
threshold = 245;
pixel_intensity_last_flash_frame = flash_events(end);

if threshold > pixel_intensity_last_flash_frame
    flash_index(end) = [];
    disp('filter 3 applied')
end

% clf; hold on;
% plot(timestamp, timeseries,'b')
% plot(timestamp(flash_index), timeseries(flash_index), '.r')

end


function flash_index = filter4(flash_index, timestamp, timeseries)

flash_event_timestamp = timestamp(flash_index);
flash_event_interval = diff(flash_event_timestamp);
std_flash_event_interval = std(flash_event_interval);
median_flash_event_interval = median(flash_event_interval);

lower_bound_threshold = median_flash_event_interval - median_flash_event_interval*.2;
upper_bound_threshold = median_flash_event_interval + median_flash_event_interval*.8;

current_last_index = flash_index(end);
possible_last_index = flash_index(end-1);

time_difference = timestamp(current_last_index) - timestamp(possible_last_index);

if time_difference < lower_bound_threshold || time_difference > upper_bound_threshold
    flash_index(end) = [];
    disp('filter 4 applied')
end



end
% 
% function flash_index = filter6(flash_index, timestamp, timeseries)
% 
% % find continuous onset event after the flashes are
% % over and reindex the last timeseries.
% current_last_index = flash_index(end);
% 
% ending_flash_index = current_last_index + find(diff(timeseries(current_last_index:end)) < 0);
% plot(timestamp(ending_flash_index), timeseries(ending_flash_index), '.g')
% first_flash_drop 
% diff
% 
% end
function debug_plot(is_debug, flash_index, timeseries, timestamp)
if is_debug
    %     subplot(4,1,1);
    hold on;
    plot(timestamp, timeseries,'b')
    plot(timestamp(flash_index), timeseries(flash_index), '.r')
    title(['num flash = ' num2str(length(flash_index))])
    
end
end