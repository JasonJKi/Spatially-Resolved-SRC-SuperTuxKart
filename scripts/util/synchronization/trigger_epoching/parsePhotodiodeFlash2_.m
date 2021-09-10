function  [flash_index, timeseries] = parsePhotodiodeFlash2_(photodiode, is_debug, quick_fix)
disp('Epoching Flash Event From the photodioderiggers. single event')
timeseries = photodiode.timeseries;
timeseries = ones(length(timeseries),1);
timestamp = photodiode.timestamp;

if quick_fix
%     timeseries(~photodiode.keep_index) = 0;
    timestamp(~photodiode.keep_index) = 0;
    flash_index = quick_fix_filter(timestamp);
    return
end

[flash_index] =  filter1(timestamp);

[flash_index] =  filter3(timestamp, flash_index);

[flash_index] =  filter4(timestamp, flash_index);

 [flash_index] =  filter5(timestamp, flash_index);

% [flash_index] =  filter5(timestamp, flash_index);

[flash_index] =  filter6(timestamp, flash_index);
  
if is_debug
    figure;clf;hold on;
    timestamp = timestamp - timestamp(1);
    stem(timestamp, timeseries,'.b')
    plot(timestamp(flash_index),timeseries, 'oy')
    plot(timestamp([flash_index(1) flash_index(end)]), 1,'*r')
    legend('events on screen','flash marker', 'start & end','Location','southwest');
    pause; close
end

end

function [flash_index] =  filter1(timestamp)
flash_index = find(diff(timestamp) > .1) + 1;
end

function [flash_index] =  quick_fix_filter(timestamp)
flash_index = find(diff([0; timestamp]) > .10) + 1;
end

function [flash_index] =  filter2(timestamp, flash_index)
% apply a second order filter on the current flash indices to check that
% the interval lengths arel similar. Re-indexing;.

flash_timestamp = timestamp(find(diff(timestamp) > .1) + 1);

median_interval_time = median(diff(timestamp(flash_index)));

upper_bound_threshold = median_interval_time + .9 * median_interval_time;
flash_index_ = find(diff(flash_timestamp) < upper_bound_threshold);
possible_last_index= flash_index(flash_index_(end) +1);
flash_index  = flash_index(flash_index_);

% Check that the first timeseries is not some errant flash.
possible_end_time =  timestamp(possible_last_index);
current_end_time = timestamp(flash_index(end));
median_interval_time = median(diff(timestamp(flash_index)));

lower_bound_threshold = median_interval_time -  median_interval_time;
upper_bound_threshold = median_interval_time +  median_interval_time;
time_difference =  possible_end_time - current_end_time;

if (time_difference > lower_bound_threshold ) && (time_difference < upper_bound_threshold )
    flash_index = [flash_index; possible_last_index];
end

end

function  [flash_index] =  filter3(timestamp, flash_index)

% Check that the first timeseries is not some errant flash.
possible_start_index = flash_index(1);
possible_start_time =  timestamp(possible_start_index);
start_event_time = timestamp(flash_index(1));
median_interval_time = median(diff(timestamp(flash_index)));

std_interval_time = std(diff(timestamp(flash_index)));
lower_bound_threshold = median_interval_time -  median_interval_time;
upper_bound_threshold = median_interval_time +  median_interval_time;
time_difference =  start_event_time - possible_start_time;

if (time_difference > lower_bound_threshold ) && (time_difference < upper_bound_threshold )
    flash_index = [possible_start_index; flash_index];
end
end

function [flash_index, flash_timestamp] =  filter4(timestamp, flash_index)

% Check that the first timeseries is not missing
flash_timestamp = timestamp(flash_index);
start_flash_time =  flash_timestamp(1);
start_event_time = timestamp(1);
median_interval_time = median(diff(timestamp(flash_index)));
std_interval_time = std(diff(timestamp(flash_index)));
lower_bound_threshold = median_interval_time - .7 * median_interval_time;
upper_bound_threshold = median_interval_time + .7 *median_interval_time;
time_difference = start_flash_time - start_event_time;

if (time_difference > lower_bound_threshold ) && (time_difference < upper_bound_threshold )
    flash_index = [1; flash_index];
end
end

function  [flash_index] =  filter5(timestamp, flash_index)
% Check that last timeseries is not some errant recording

flash_timestamp = timestamp(flash_index);
last_flash_time = flash_timestamp(end);
second_to_last_flash_time = flash_timestamp(end-1);
time_difference = last_flash_time - second_to_last_flash_time;
median_interval_time = median(diff(timestamp(flash_index)));
std_interval_time = std(diff(timestamp(flash_index)));
lower_bound_threshold = median_interval_time - .2 * median_interval_time;
upper_bound_threshold = median_interval_time + .2 * median_interval_time;

if (time_difference < lower_bound_threshold ) || (time_difference > upper_bound_threshold )
    flash_index(end) = [];
end

end

function [flash_index, flash_timestamp] =  filter6(timestamp, flash_index)
% check that last on event is not a run on and that it ends at a given
% moment.

    current_end_flash =  timestamp(flash_index(end):end);
%     median_interval = median(diff(current_end_flash));
    time_threshold = .06;
    end_index = flash_index(end) + find(diff(current_end_flash) > time_threshold)-1;
    if isempty(end_index)
        end_index = length(timestamp);
    end
    n_current_end_flash = length(current_end_flash);
    current_end_flash = timestamp(end_index);
    current_end_flash_duration = current_end_flash(end) - current_end_flash(1);

    possible_end_flash =  timestamp(flash_index(end-1):flash_index(end));
    possible_end_index  = flash_index(end-1) + find(diff(possible_end_flash) > time_threshold)-1;
    possible_end_flash = timestamp(possible_end_index);
    possible_end_flash_duration = possible_end_flash(end) - possible_end_flash(1);
    n_possible_end_flash = length(possible_end_flash);
    
    if current_end_flash_duration > possible_end_flash_duration * 2
        flash_index(end) = [];
    end
    
    return
%     figure;clf;hold on;
%     timestamp = timestamp;
%     stem(timestamp, ones(length(timestamp),1),'.b')
%     plot(timestamp(flash_index),ones(length(flash_index), 1),'oy')
%     plot(timestamp([flash_index(1) flash_index(end)]), 1,'*r')
%     plot(current_end_flash, ones(length(current_end_flash), 1),'og')
%     plot(possible_end_flash, ones(length(possible_end_flash), 1),'ob')
% 
%     legend('events on screen','flash marker', 'start & end','Location','southwest');
%     pause; close
    
end
