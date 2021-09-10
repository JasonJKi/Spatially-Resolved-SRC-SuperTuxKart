function [video_trigger, fig] = visualizeManuallyCorrectVideoTriggers(video_trigger, metadata, video_trigger_figure_dir, is_draw_figure, is_visually_inspect, i_file, version)

if is_draw_figure
    plot_title_str = ['file #' num2str(i_file) ' filename: '  metadata.filename_str{i_file};];
    close; fig = figure('units','normalized','outerposition', [0 0 1 1]);clf
    time_to_show = 30;
    draw_trigger_debug_figgure(video_trigger,time_to_show);
    suptitle([plot_title_str ' num flash=' num2str(length(video_trigger.flash_index))]);
    
    video_trigger.trigger_fix_required = 0;
    
    % Visually check to see that the first and the last triggers are correctly selected by the algorithm.
    if is_visually_inspect
        
        is_fix_required = questionBox();
        video_trigger.trigger_fix_required = is_fix_required;
        
        if is_fix_required == 0; return; end
        
        if is_fix_required == 2
            % zoom here to make sure that you are able to click the right boundaries.
            [start_time, end_time] = manualTimeIndexingFromPlot(); close
            
            [timeseries, timestamp, keep_index] = reindexData(video_trigger.timeseries, video_trigger.timestamp, start_time, end_time);
            video_trigger.re_index = keep_index;
            [video_trigger] = parseVideoFlashEvents(video_trigger, 0, true, false);
            draw_trigger_debug_figgure(video_trigger,time_to_show);
            suptitle([plot_title_str ' num flash=' num2str(length(video_trigger.flash_index))]);
        end
        
    end
    
    figure_output_path = [video_trigger_figure_dir '/' metadata.filename{i_file} '.png'];
    saveas(gcf, figure_output_path);
    figure_output_path = [video_trigger_figure_dir '/' metadata.filename{i_file} '.fig'];
    savefig(gcf,figure_output_path);
end
