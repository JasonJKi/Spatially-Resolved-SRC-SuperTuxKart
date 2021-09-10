function  fig = plotWarpCorrectedTimeseries(data_warped, data_unwarped, trigger, is_debug, figure_num)
if ~is_debug; return;  end

if ndims(data_warped.timeseries) > 2
    data_warped.timeseries = videoMean2( data_warped.timeseries);
    data_unwarped.timeseries = videoMean2( data_unwarped.timeseries);
end
        
timestamp_warped = data_warped.timestamp-data_warped.timestamp(1);
timestamp_unwarped =  data_unwarped.timestamp-data_unwarped.timestamp(1);
timestamp_trigger = trigger.timestamp-trigger.timestamp(1); 
rescaled_timeseries_warped =  rescaleData(data_warped.timeseries);
rescaled_timeseries_unwarped = rescaleData(data_unwarped.timeseries);

fig = figure(figure_num);clf
subplot 311; hold on
plot(timestamp_warped, data_warped.timeseries, 'b');
plot(timestamp_unwarped, data_unwarped.timeseries,'-.r');
legend({'before', 'after correction'} )
title('data before vs after correction')

subplot 312; hold on;
time_range = 25;
plot(timestamp_warped,rescaled_timeseries_warped, 'b');
plot(timestamp_unwarped, rescaled_timeseries_unwarped,'-.r');
s1 = stem(timestamp_trigger(trigger.flash_index), ones(length(trigger.flash_index),1), '-.g');
s2 = stem(timestamp_warped(data_warped.flash_index), rescaled_timeseries_warped(data_warped.flash_index),'-*b');
s3 = stem(timestamp_unwarped(data_unwarped.flash_index), rescaled_timeseries_unwarped(data_unwarped.flash_index),'-.r');
legend([s1, s2, s3],  {'reference trigger', 'data original', 'data corrected'}, 'Location', 'north' )
xlim([-1 time_range]); ylim([0 .7]); title(['first ' num2str(time_range) ' seconds'])

subplot 313; hold on;
time_range = 10;
plot(timestamp_warped,rescaled_timeseries_warped, 'b');
plot(timestamp_unwarped, rescaled_timeseries_unwarped,'-.r');
s1 = stem(timestamp_trigger(trigger.flash_index), ones(length(trigger.flash_index),1), '-.g');
s2 = stem(timestamp_warped(data_warped.flash_index), rescaled_timeseries_warped(data_warped.flash_index),'-*b');
s3 = stem(timestamp_unwarped(data_unwarped.flash_index), rescaled_timeseries_unwarped(data_unwarped.flash_index),'-.r');
legend({'before', 'after unwarping', 'reference trigger', 'data corrected', 'data original'} )
timestamp = data_warped.timestamp-data_warped.timestamp(1);
legend([s1, s2, s3],  {'reference trigger', 'data original', 'data corrected'}, 'Location', 'north' )
xlim([timestamp(end)-time_range timestamp(end)+3]); ylim([0 .7]); xlabel('time (s)'); title(['last ' num2str(time_range) ' seconds'])
xlabel('time (s)')
