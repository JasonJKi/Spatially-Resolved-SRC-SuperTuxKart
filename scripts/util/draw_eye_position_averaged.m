clear all; dependencies install
my_data = MyData('E:/Active-Passive-SRC-2D/data');
metadata_stk = my_data.metadata;

% [stimulus, response, eyelink] = loadSuperTuxKartData(my_data, metadata_stk, is_warp_correct);
stim_type = 'optical_flow';
is_debug_mode = true;
is_warp_correct = true;
alignment_type = '';

eyelink_index_1 = find((metadata_stk.eye_data_status == 1) & (metadata_stk.condition == 2) & (metadata_stk.session ==2) & (metadata_stk.video_id ==1));
eyelink_index_2 = find((metadata_stk.eye_data_status == 1) & (metadata_stk.condition == 3) & (metadata_stk.session ==2) & (metadata_stk.video_id ==1));

ind_1 = eyelink_index_1(1);
ind_2 = eyelink_index_1(2);

i_file = ind_1;
filename = metadata_stk.filename{i_file};

eyelink_filename = [filename '_eyelink_processed.mat'];
out_dir = [my_data.aligned_data_dir.eyelink '/processed_not_aligned'];
eyelink_processed_filepath = [out_dir '/' eyelink_filename];

disp(['aligning: ' filename])
eyelink = load(eyelink_processed_filepath);
video_trigger_path = [my_data.epoched_data_dir.video_trigger '/' filename '_video_trigger.mat'];
video_trigger = load(video_trigger_path); % epoched video trigger

% load photodiode trigger mat (epoched).
photodiode_trigger_path = [my_data.epoched_data_dir.photodiode_trigger '/' filename  '_photodiode_trigger.mat'];
photodiode = load(photodiode_trigger_path); % epoched photodiode trigger
photodiode.flash_dropped=false;

vid_filename = metadata_stk.old_filename{i_file};
video_dir = ['E:/Active-Passive-SRC/data/supertuxkart-session-' num2str(metadata_stk.session(i_file)) '/raw/video/resized/'];
video_path = [video_dir vid_filename '.avi'];
video = initFromVideoReader(Video(), VideoReader(video_path));

% epoch video and eyelink based on triggers.
[video_epoched] = epochSTKVideo(video, video_trigger);
[eyelink_epoched] = epochSTKLabstream(eyelink, photodiode);
[video_parsed, eyelink_parsed] =  parseFromStartToEndFlash(video_epoched, eyelink_epoched, video_trigger, photodiode);
video_scale = 1;
vid = video_parsed.timeseries;
width = video.width;
height = video.height;

% stimulus_feature_path = [my_data.epoched_data_dir.optical_flow '/' filename '_' stim_type];
% stim =  load(stimulus_feature_path, 'data', 'timestamp', 'fs', 'duration');

eyelink_filename = [metadata_stk.filename{ind_1} '_eyelink_aligned.mat'];
eyelink_aligned_filepath = [my_data.aligned_data_dir.eyelink '/' eyelink_filename];
eyelink = load(eyelink_aligned_filepath);
eye = eyelink.timeseries;

x_ref = eyelink.ref_width;
y_ref = eyelink.ref_height;

x_scale = video.width/x_ref;
y_scale = video.height/y_ref;

x_pos_1 = eye(:,1)*x_scale*video_scale;
y_pos_1 = eye(:,2)*y_scale*video_scale;

eyelink_filename = [metadata_stk.filename{ind_2} '_eyelink_aligned.mat'];
eyelink_aligned_filepath = [my_data.aligned_data_dir.eyelink '/' eyelink_filename];
eyelink = load(eyelink_aligned_filepath);
eye = eyelink.timeseries;

x_ref = eyelink.ref_width;
y_ref = eyelink.ref_height;

x_scale = video.width/x_ref;
y_scale = video.height/y_ref;

x_pos_2 = eye(:,1)*x_scale*video_scale;
y_pos_2 = eye(:,2)*y_scale*video_scale;

fig = figure(1); clf
vidObj = VideoWriter(['video_1_session_2_active_vs_passive.mp4']);
open(vidObj)

frame_size = [height width]*video_scale;
img_width = frame_size(2);
img_height = frame_size(1);
[x,y] = meshgrid(1:img_width,1:img_height);
 opticFlow = opticalFlowHS;

for i = 1:length(vid)
    frame = uint8(imresize(squeeze(vid(i,:,:,:)), frame_size));
    %frame = uint8(squeeze(vid(i,:,:,:)));
    frameGray = rgb2gray(frame);
    
    imshow(uint8(frame)); hold on

    flow = estimateFlow(opticFlow,frameGray);
    
    a = plot(flow,'DecimationFactor',[5 5],'ScaleFactor',60);
    q = findobj(a,'type','Quiver');
    q.Color = 'r';
    
%     plot(x_pos(i),y_pos(i),'og','MarkerSize', 10, 'LineWidth', 3);
    plot(x_pos_1(i),y_pos_1(i),'og','MarkerSize', 10, 'LineWidth', 3);
    plot(x_pos_2(i),y_pos_2(i),'oc','MarkerSize', 10, 'LineWidth', 3);
    currFrame = getframe(gcf);
    drawnow;hold off
        writeVideo(vidObj,currFrame);
    %     pause
end
close(vidObj);

