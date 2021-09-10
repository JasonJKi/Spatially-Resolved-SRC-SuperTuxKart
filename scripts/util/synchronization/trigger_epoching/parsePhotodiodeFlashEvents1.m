function [flash_index, photodiode_event_] = parsePhotodiodeFlashEvents1(photodiode_event, event_code, photodiode_timestamp, is_debug, quick_fix)
disp('Epoching Flash Event From the photodiode_eventriggers. on and off event')

min_val = min(unique(photodiode_event));
max_val = max(unique(photodiode_event));
photodiode_event_ = (1-0)/(max_val-min_val)*(photodiode_event-max_val)+1;

% get ppt flash and frame marker events
% index frame marking events based on the trigger identifier
flash_index = find(photodiode_event==event_code);

flash_index = filter1(flash_index);
if quick_fix
    return
end
% index flash events on the monitor based on the trigger identifier.
flash_index = filter2(flash_index);

% Check that the first trigger is not some errant flash.
flash_index = filter3(flash_index, photodiode_timestamp);

% Check that the last trigger is not some errant flash.
[flash_index] =  filter4(photodiode_timestamp, flash_index);

% Check to see if that last trigger is doesnt have run-off onset events (_||_||_||||||||___).
[flash_index] =  filter5(flash_index, photodiode_timestamp, photodiode_event_);


% is_debug = 1;
if is_debug
    figure;clf;hold on;
    time = photodiode_timestamp;
    plot(time, photodiode_event_); % plot all events
    plot(time(flash_index), photodiode_event_(flash_index),'.r');
    plot(time([flash_index(1) flash_index(end)]), photodiode_event_([flash_index(1) flash_index(end)]),'*g');
    legend('events on screen','flash marker', 'start & end','Location','southwest');
    close
end
end

function flash_index = filter1(flash_index)
% find any on event that
flash_index_ = find(abs(diff([0; flash_index]) > 2));

flash_index = flash_index(flash_index_);
end

function flash_index = filter2(flash_index)
% find flash events based on interval length threshold
flash_interval_2nd_order = diff(flash_index); 
avg_flash_interval = median(flash_interval_2nd_order);
flash_interval_threshold = avg_flash_interval * .3;
flash_interval_boolean = abs(flash_interval_2nd_order-flash_interval_threshold) > flash_interval_threshold;
flash_index_2nd_order = find(flash_interval_boolean);

% there may be two separate long sequential flash event intervals. find the longest one.
longest_interval = findLongestInterval(flash_index_2nd_order);
flash_index = flash_index(longest_interval);
% flash_index = checkEndIndex1(flash_index, longest_interval);
end


function longest_interval = findLongestInterval(flash_index)
% finding the longest interval.
flash_index_ = [-1; flash_index;-1];
intervals = find(abs(diff(flash_index_ )) >1);
if length(intervals) < 2
    longest_interval =flash_index;
else
    intervalDiff = diff(intervals);
    maxInterval = find(max(intervalDiff) == intervalDiff);
    i0_ = intervals(maxInterval);
    iT_ = intervals(maxInterval+1);
    longest_interval = flash_index(i0_:(iT_-1));
end
end

function flash_index = checkEndIndex1(flash_index, longest_interval) 

% median_interval_time = median(diff(photodiode_timestamp(flash_index)));
% std_interval_time = std(diff(photodiode_timestamp(flash_index)));
% lower_bound_threshold = median_interval_time - 4 * std_interval_time;
% upper_bound_threshold = median_interval_time + 4 *std_interval_time;

diffFlashThresh =  flash_index(longest_interval)*.1;
last_index = flash_index(longest_interval(end));
last_indexNew = flash_index(longest_interval(end)+1);
if abs(last_index - last_indexNew) < diffFlashThresh
    longest_interval = [longest_interval; longest_interval(end)+1];
end

flash_index =  flash_index(longest_interval);
end

function [flash_index] =  filter4(photodiode_timestamp, flash_index)
% Check that the first trigger is not some errant flash.
possible_start_index = flash_index(2);
possible_start_time =  photodiode_timestamp(possible_start_index);
current_start_index = flash_index(1);
start_event_time = photodiode_timestamp(current_start_index);
median_interval_time = median(diff(photodiode_timestamp(flash_index)));

std_interval_time = std(diff(photodiode_timestamp(flash_index)));
lower_bound_threshold = median_interval_time -  .5* median_interval_time;
upper_bound_threshold = median_interval_time +  median_interval_time;
time_difference =  possible_start_time - start_event_time;

if (time_difference < lower_bound_threshold ) || (time_difference > upper_bound_threshold )
    flash_index(1) = [];
end

end

function flash_index = filter3(flash_index, photodiode_timestamp)
% Check that last trigger is not some errant recording
flash_timestamp = photodiode_timestamp(flash_index);

median_interval_time = median(diff(flash_timestamp));
std_interval_time = std(diff(flash_timestamp));
lower_bound_threshold = median_interval_time - .2 * median_interval_time;
upper_bound_threshold = median_interval_time + .2 *median_interval_time;

last_flash_time = flash_timestamp(end);
second_to_last_flash_time = flash_timestamp(end-1);
time_difference = last_flash_time - second_to_last_flash_time;

if (time_difference < lower_bound_threshold ) || (time_difference > upper_bound_threshold )
    flash_index(end) = [];
end
end

function [flash_index] =  filter5(flash_index, photodiode_timestamp, photodiode_event)
% check that last on event is not a run on and that it ends at a given
% moment.

    timestamp = photodiode_timestamp;
    timestamp(photodiode_event==0) = 0;
    flash_boolean = diff([0; timestamp])>0.1;
%     flash_event_index = find(flash_boolean);
    timestamp(find(flash_boolean~=0)+1) = 0;
%     clf
%     subplot(2,1,1); plot(photodiode_event)
%     subplot(2,1,2); hold on; plot(photodiode_timestamp, photodiode_event); plot(photodiode_timestamp(flash_index),flash_boolean(flash_index),'.r')
    
    time_threshold = .4;
    current_last_index = flash_index(end);
    possible_last_index = flash_index(end-1);
    
    current_end_flash_ =  timestamp(current_last_index:end);
    interval_ending = find(diff(current_end_flash_) > time_threshold);
    if isempty(interval_ending)
        return
    end
    interval_ending_first_drop = interval_ending(1);
    end_index = current_last_index:current_last_index+interval_ending_first_drop;
    
    n_current_end_flash = length(end_index);
    current_end_flash = photodiode_timestamp(end_index);
    current_end_flash_duration = current_end_flash(end) - current_end_flash(1);

    possible_end_index = possible_last_index:current_last_index;
   	possible_end_flash = photodiode_timestamp(possible_end_index);
    possible_end_flash_duration = possible_end_flash(end) - possible_end_flash(1);
    n_possible_end_flash = length(possible_end_flash);
    
    if current_end_flash_duration > possible_end_flash_duration * 2
        flash_index(end) = [];
    end
    
    figure;clf;hold on;
    stem(photodiode_timestamp, photodiode_event,'.b')
    plot(photodiode_timestamp(flash_index),ones(length(flash_index), 1),'oy')
    plot(photodiode_timestamp([flash_index(1) flash_index(end)]), 1,'*r')    
%     plot(photodiode_timestamp(end_index), ones(length(current_end_flash), 1),'og')
%     plot(photodiode_timestamp(possible_end_index), ones(length(possible_end_flash), 1),'*k')

%     legend('events on screen','flash marker', 'start & end','Location','southwest');
    
end

