%clear all; 
dependencies install
my_data = MyData('E:/Active-Passive-SRC-2D/data');
metadata_stk = my_data.metadata;

% file_index = find(metadata_stk.status == 1)';
file_index = 1:height(metadata_stk);
num_files = length(file_index);

stim_type = 'optical_flow';
is_debug_mode = true;
is_warp_correct = true;
alignment_type = '';
if is_warp_correct; alignment_type = 'warp_corrected';end
channel_label = {'leftEyeX' 'leftEyeY' 'rightEyeX' 'rightEyeY' 'leftPupilArea' 'rightPupilArea' 'pixelsPerDegreeX' 'pixelsPerDegreeY' 'eyelink_timestamp' 'LSL_timestamp'};
channel_label_final = {'X'    'Y'  'PupilArea'  'pixelsPerDegreeX'    'pixelsPerDegreeY'};

iter=1; 
for i_file = file_index(1:end)
    
    filename = metadata_stk.filename{i_file};
    disp(['processing: ' filename])
    
    
     eyelink_mat_filenpath = [my_data.raw_data_dir.eyelink '/' filename '_eyelink.mat'];
     metadata_stk.eye_data_status(i_file) = 0;

    if exist(eyelink_mat_filenpath, 'file') ==2
        disp(['loading:' eyelink_mat_filenpath])
        
        eye = load(eyelink_mat_filenpath);

        if (length(eye.timeseries(:,1)) < 1000) || (length(unique(eye.timeseries(:,1))) < 1000)
            continue
        end

        channel_to_keep_indx = [1 2 5 7 8];
        [eye_processed, is_reject, mask] = removeBlinkArtefact(eye, channel_to_keep_indx);

        if 0
            fig = figure(1);clf
            x_pos = eye.timeseries(:,1);
            subplot(3,1,1); plot(x_pos); title('unprocessed')
            subplot(3,1,2); x_pos(mask,1) = nan; plot(x_pos(:,1)); title('artefact removed')
            subplot(3,1,3); plot(eye_processed(:,1)); title('interpolated nan')
            hold on; plot(find(mask),eye_processed(mask,1),'.g')
%             if is_reject; plot(find(mask),eye_processed(mask,1),'.r'); end
            saveas(fig, ['output/eyelink_preprocess/' filename], 'png');pause(.1)
            
            title_str = filename; title_str(strfind(title_str, '_')) = ' '; suptitle(title_str)
        end

        if ~is_reject
            eye_subject(i_file) = metadata_stk.subject_id(i_file);

            eye_data_all{i_file} = eye_processed;
            iter = iter+1;

            eye.timeseries = eye_processed;
            eye.timestamp = eye.timestamp;
            eye.fs = eye.fs;
            eye.label = channel_label(channel_to_keep_indx);

            eyelink_filename = [filename '_eyelink_processed.mat'];
            out_dir = [my_data.aligned_data_dir.eyelink '/processed_not_aligned'];
            eyelink_aligned_filepath = [out_dir '/' eyelink_filename];
            
            
            success_count(i_file) = 1;

%             save(eyelink_aligned_filepath, '-struct', 'eye')
        end

        clear data_processed eye_processed
    else
    end
end

sesion_index = (metadata_stk.session == 1) | (metadata_stk.session == 2); 
success_count(sesion_index)
subjects_index = length(unique(eye_subject(sesion_index)))-1
% 
% %show heatmap after gaussian filtering
% figure(1);clf
% % imshow(img)
% % hold on
% imshow(imresize(heatmap, [scrn_width scrn_width]));
% title('Heatmap','Color','k','FontSize',14)
% alpha(0.6)

