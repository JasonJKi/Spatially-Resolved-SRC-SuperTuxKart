function plotVideoFlashEvent_(video_flash_event)

if isfield(video_flash_event, 'data')
    video_avg_pixel_intensity = video_flash_event.data;
else
    video_avg_pixel_intensity = video_flash_event.timeseries;
end

video_flash_index = video_flash_event.flash_index;
max_val = max(video_avg_pixel_intensity);
min_val = min(video_avg_pixel_intensity);
% video_avg_pixel_intensity = (1-0)/(max_val-min_val)*(video_avg_pixel_intensity-max_val)+1;

h1 = stem(video_flash_event.timestamp, video_avg_pixel_intensity,'.y');
% h2 = plot(video_flash_event.timestamp, repmat(video_flash_event.pixel_intensity_threshold/max_val,1,length(video_avg_pixel_intensity)));
h3 = stem(video_flash_event.timestamp(video_flash_index), video_avg_pixel_intensity(video_flash_index)','*r');
legend([h1  h3], {'pixel intensity', 'flash occurence'}, 'Location', 'south');
% ylim([.75 1.25])

end

