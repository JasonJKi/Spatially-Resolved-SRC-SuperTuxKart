clear all; dependencies install
my_data = MyData('E:/Active-Passive-SRC-2D/data');

session = [1 2];
metadata_stk = chooseSession(my_data.metadata, session);
num_files = height(metadata_stk);

stim_type = 'optical_flow';
is_debug_mode = true;
is_warp_correct = true;

channel_label = {'leftEyeX' 'leftEyeY' 'rightEyeX' 'rightEyeY' 'leftPupilArea' 'rightPupilArea' 'pixelsPerDegreeX' 'pixelsPerDegreeY' 'eyelink_timestamp' 'LSL_timestamp'};
channel_label_final = {  'X'    'Y'  'PupilArea'  'pixelsPerDegreeX'    'pixelsPerDegreeY'};

iter = 1;
for i_file = 1:num_files

    % Get file name for each subject and run combination.
    % filename = stk_subjectNumber_runNumber_condition_trial
    filename = metadata_stk.filename{i_file};
    disp(['loading: ' filename])
    
    % load video trigger mat (epoched).
    eyelink = [];
    eyelink_mat_filepath = [my_data.raw_data_dir.eyelink '/' filename '_eyelink.mat'];
    if  exist(eyelink_mat_filepath, 'file') == 2
        eyelink = load(eyelink_mat_filepath);
        disp(length(eyelink.timestamp))
    else
        disp('not found')
        continue
    end
    
    photodiode_trigger_path = [my_data.epoched_data_dir.photodiode_trigger '/' filename  '_photodiode_trigger.mat'];
    photodiode = load(photodiode_trigger_path); % epoched photodiode trigger
    photodiode.flash_dropped=false;
          
    % epoch video and eeg based on triggers.
    [eyelink_epoched] = epochLSL(eyelink,  photodiode);
    eyelink.label = channel_label;

%     if ~isempty(eyelink)
%         for i =1:8
%             subplot(8,1,i)
%             plot(eyelink_epoched.timeseries(:,i)')
%             title(channel_label{i});
%         end
%     end
%     pause

    leftIdle = sum(eyelink.timeseries(:,1)==0);  
    rightIdle = sum(eyelink.timeseries(:,3)==0);
    [val, max_ind] = max([leftIdle, rightIdle]);
    left_ind = [1 1 0 0 1 0 ];
    right_ind = ~left_ind;
    if max_ind == 2
        timeseries = eyelink.timeseries(:, [find(left_ind) 7,8]);
    else
        timeseries = eyelink.timeseries(:, [find(right_ind) 7,8]);
    end
    
        
    if length(unique(timeseries(:,1))) < 2
        continue
    end
    eye.timeseries = timeseries;
    eye.timestamp = eyelink.timestamp;
    eye.label = channel_label_final;
    eye.fs = eyelink.fs;
    eye_all{iter} = eye;    
    
    pupil_movement = [0; diff(eye.timeseries(:,3))];
    eye_blink_event = abs(pupil_movement)   > 100;
    eye_blink_index = find(eye_blink_event);
%     hampel(eye.timeseries(:,1),eye.timeseries(:,2))
     
    pupil = eye.timeseries(:,1);
    mask_1  = pupil == 0;
    pupil(find(mask_1)) = NaN;
    figure(1); clf;
    subplot(4,1,1);hold on
    plot(pupil)
    plot(eye_blink_index, pupil(eye_blink_index),'o')
    subplot(4,1,2);hold on
    pupil_blink_removed = pupil;
    pupil_blink_removed(eye_blink_index) = NaN;
    mask_2 = eye_blink_event;
    plot(pupil_blink_removed)
    subplot(4,1,3);hold on
    se = ones(40,1);

    mask_3 = filtfilt(se,1, double(eye_blink_event));
    mask_3 = mask_3>0;
    plot(pupil)
    
    mask = mask_1 | mask_2 | mask_3;
    
    x = (1:length(pupil))';
    y = pupil;
    xi=x(~mask);yi=y(~mask);
    out =interp1(xi,yi,x,'linear');
    subplot(4,1,4);hold on
    plot(out)
    
    answer = questdlg('keep file?','yes', 'no');
    if strcmp(answer,'no')
        continue
    end
    
    for i = 1:5
        y = eye.timeseries(:,i);
        xi=x(~mask);yi=y(~mask);
        out =interp1(xi,yi,x,'linear');
        timeseries(:,i) = out;
%         subplot(5,1,i)
%         hold on;
%         plot(y)
%         plot(out,'r')
%         title(eye.label{i});
    end
    

    eye_processed.timeseries = timeseries;
    eye_processed.timestamp = eye.timestamp;
    eye_processed.fs = eye.fs;
    eye_processed.label = eye.label;
    
    eye_processed_all{iter} = eye_processed; 
    eyelink_processed_filepath = [my_data.epoched_data_dir.eyelink '/' filename '_processed.mat'];
    disp(['saving: '  filename]);
    save(eyelink_processed_filepath, '-struct', 'eye_processed');

    iter = iter + 1;
end

iter = 1
file_to_skip = [92 164 166];
for i_file = 1:num_files
    % Get file name for each subject and run combination.
    % filename = stk_subjectNumber_runNumber_condition_trial
    filename = metadata_stk.filename{i_file};
    eyelink_processed_filepath = [my_data.epoched_data_dir.eyelink '/' filename '_processed.mat'];
    if  exist(eyelink_processed_filepath, 'file') == 2
        disp(['loading: '  filename]);
        eye_processed = load(eyelink_processed_filepath);
        eye_processed_all{iter} = eye_processed; 
        iter = iter + 1;
    end    
end    

img = 'stimulus_heatmap_demo.bmp';
heatmap_generator('data_heatmap_demo.txt','.bmp',0.25/4,1.25,1.00,5,3);

scrn_width = 1280;
scrn_height  = 720;

pos = eye_processed_all{15}.timeseries;
img=imread( 'stimulus_heatmap_demo.bmp');
img = imresize(img, [scrn_height scrn_width]);
heatmap = eyetracking_heatmap(pos(:,1), pos(:,2), scrn_width, scrn_height);


%show heatmap after gaussian filtering
figure
imshow(img)
hold on
imshow(heatmap);
title('Heatmap','Color','k','FontSize',14)
alpha(0.6)
