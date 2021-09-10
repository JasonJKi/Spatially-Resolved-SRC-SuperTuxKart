function fig = visualizeTriggerAlignment(photodiode, video_trigger, metadata, i_file, figure_path)

fig = figure('units','normalized','outerposition', [0 0 1 1]); clf
plot_title_str = ['file #:' num2str(i_file) ' filename: ' metadata.filename_str{i_file}];
subplot(6,1,1); hold on;
plotVideoFlashEvent_(video_trigger);
title(['video flash: '  plot_title_str ' n=' num2str(length(video_trigger.flash_index)) ' t: ' num2str(video_trigger.duration) 's'])

subplot(6,1,2); hold on;
plotPhotodiodeFlashEvent_(photodiode);
ylim([.75 1])
title(['photodiode flash: ' plot_title_str ' n=' num2str(length(photodiode.flash_index)) ', t=' num2str(photodiode.duration) 's'])
legend({'events on screen','flash marker', 'start & end'},'Location','south');

subplot(6,1,3); hold on
time_to_show = 40;
plotVideoPhotodiodeEvent(video_trigger, photodiode) ;
xlim([0  time_to_show]);
legend({'video flash', 'photodiode flash'});
flash_interval_time =median(diff(photodiode.flash_timestamp));
title(['last ' num2str(time_to_show)  ' sec, flash occurs every ' num2str(flash_interval_time) 'secs']);

subplot(6,1,4); hold on
plotVideoPhotodiodeEvent(video_trigger, photodiode) ;
xlim([video_trigger.timestamp(end) - time_to_show video_trigger.timestamp(end)]);
num_additional_flash = length(photodiode.flash_index) -  length(video_trigger.flash_index);
time_difference = photodiode.duration - video_trigger.duration;
title(['last ' num2str(time_to_show)  ' sec, num extra photodide flash: ' num2str(num_additional_flash) ', time difference: ' num2str(time_difference)]);
xlim([ video_trigger.timestamp(end) - time_to_show  video_trigger.timestamp(end) + 3]);

subplot(6,1,5); hold on
% Check the precision of trigger timing between video and photodiode.
[video_trigger_interval,  photodiode_flash_interval, interval_time_difference] = ...
    checkTriggerTimealignment(video_trigger.flash_timestamp, photodiode.flash_timestamp);

plotTriggerIntervals(video_trigger_interval,  photodiode_flash_interval, interval_time_difference);
legend({'video', 'photodiode'});

subplot(6,1,6); hold on
% Check the precision of trigger timing between video and photodiode.
plotTriggerIntervalsDifference(video_trigger_interval,  photodiode_flash_interval, interval_time_difference);
legend({'time difference'});

saveas(fig, [figure_path '.png']);
% savefig(fig, [figure_path '.fig'])
close all
