function  photodiode = visualizeManuallyEpochPhotodiodeTrigger(photodiode, metadata, photodiode_trigger_figure_dir, i_file, is_draw_figure, is_visually_inspect)
% Visualize that the proper triggers were selected and manually select the first and the last trigger moments.
if is_draw_figure
    plot_title_str = ['file #' num2str(i_file) ' filename: ' metadata.filename_str{i_file}];
    
    % Draw figures
    close;
    fig = figure('units','normalized','outerposition', [0 0 1 1]);clf
    time_to_show = 25;
    draw_trigger_debug_figgure(photodiode, time_to_show)
    suptitle([plot_title_str ' num flash=' num2str(length(photodiode.flash_index))]);
    
    % Visually check to see that the first and the last triggers are aligned.
    if is_visually_inspect
        
        is_fix_required = questionBox();
        
        if is_fix_required == 0; return; end
        
        if is_fix_required == 2
            % zoom here to make sure that you are able to click the right boundaries.
            [start_time, end_time] = manualTimeIndexingFromPlot(); close
            
            [timeseries, timestamp, keep_index] = reindexData(photodiode.timeseries, photodiode.timestamp, start_time, end_time);
            photodiode.timeseries_fixed = timeseries;
            photodiode.timestamp_fixed = timestamp;
            photodiode.keep_index = keep_index;
            
            needs_quick_fix = true;
            [photodiode] = epochSTKPhotodiode(photodiode, 0, needs_quick_fix);
            
            fig = figure('units','normalized','outerposition', [0 0 1 1]);clf
            time_to_show = 15;
            draw_trigger_debug_figgure(photodiode, time_to_show)
            suptitle([plot_title_str ' num flash=' num2str(length(photodiode.flash_index))]);
        end
        
    end
    
    % save out the figures
    figure_output_path = [photodiode_trigger_figure_dir '/' metadata.filename{i_file} '.png'];
    saveas(fig, figure_output_path);
%     figure_output_path = [photodiode_trigger_figure_dir '/' metadata.filename{i_file} '.fig'];
%     savefig(fig,figure_output_path);
    close
    
end