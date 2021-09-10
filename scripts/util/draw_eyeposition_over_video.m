clear all
dependencies install
my_data = MyData('E:/Active-Passive-SRC-2D/data');
metadata_stk = my_data.metadata;

% session_index = find(metadata_stk.session == 2);
% eye = cat(1, eyelink{session_index});
% x = cat(1, eyelink{2});

eyelink_session_1 = find((metadata_stk.eye_data_status == 1) & (metadata_stk.condition == 1));
eyelink_session_2 = find((metadata_stk.eye_data_status == 1) & (metadata_stk.condition == 3) & (metadata_stk.session ==2));


% [stimulus, response, eyelink] = loadSuperTuxKartData(my_data, metadata_stk, is_warp_correct);
stim_type = 'optical_flow';
is_debug_mode = true;
is_warp_correct = true;
alignment_type = '';

n_file = length(eyelink_session_2);
for i_file = 1:n_file
    ind = eyelink_session_2(i_file);
    filename = metadata_stk.filename{ind};
    eyelink_filename = [filename '_eyelink_aligned.mat'];
    eyelink_aligned_filepath = [my_data.aligned_data_dir.eyelink '/' eyelink_filename];
    a = load(eyelink_aligned_filepath);
    race_time(i_file) = length(a.timeseries);
end

[n, fastest_race_ind] = min(race_time);
index_1 = eyelink_session_2(fastest_race_ind);

eyelink_session_3 = find((metadata_stk.eye_data_status == 1) & (metadata_stk.condition == 2) & (metadata_stk.session ==2) & (metadata_stk.bci_deception_success ==1));
index_2 = eyelink_session_3(1);
for i_file = index_1
    
    filename = metadata_stk.filename{i_file};
    
    eyelink_filename = [filename '_eyelink_processed.mat'];
    out_dir = [my_data.aligned_data_dir.eyelink '/processed_not_aligned'];
    eyelink_processed_filepath = [out_dir '/' eyelink_filename];
    
    metadata_stk.eye_data_status(i_file) = 0;

    if exist(eyelink_processed_filepath, 'file')
        disp(['aligning: ' filename])
        eyelink = load(eyelink_processed_filepath);
        video_trigger_path = [my_data.epoched_data_dir.video_trigger '/' filename '_video_trigger.mat'];
        video_trigger = load(video_trigger_path); % epoched video trigger
        
        % load photodiode trigger mat (epoched).
        photodiode_trigger_path = [my_data.epoched_data_dir.photodiode_trigger '/' filename  '_photodiode_trigger.mat'];
        photodiode = load(photodiode_trigger_path); % epoched photodiode trigger
        photodiode.flash_dropped=false;
        
        vid_filename = metadata_stk.old_filename{i_file};
        video_dir = ['E:/Active-Passive-SRC/data/supertuxkart-session-' num2str(metadata_stk.session(i_file)) '/raw/video/'];
        video_path = [video_dir vid_filename '.mp4'];
        video = initFromVideoReader(Video(), VideoReader(video_path));
       
        % epoch video and eyelink based on triggers.
        [video_epoched] = epochSTKVideo(video, video_trigger);
        [eyelink_epoched] = epochSTKLabstream(eyelink, photodiode);

        [video_parsed, eyelink_parsed] =  parseFromStartToEndFlash(video_epoched, eyelink_epoched, video_trigger, photodiode);
        
        stimulus_feature_path = [my_data.epoched_data_dir.optical_flow '/' filename '_' stim_type];
        stim =  load(stimulus_feature_path, 'data', 'timestamp', 'fs', 'duration');        
        
        
        eyelink_filename = [filename '_eyelink_aligned.mat'];
        eyelink_aligned_filepath = [my_data.aligned_data_dir.eyelink '/' eyelink_filename];

        eyelink = load(eyelink_aligned_filepath);
        
        eyelink_filename = [metadata_stk.filename{index_1} '_eyelink_aligned.mat'];
        eyelink_aligned_filepath = [my_data.aligned_data_dir.eyelink '/' eyelink_filename];
        eyelink_1 = load(eyelink_aligned_filepath);
        
        eyelink_filename = [metadata_stk.filename{index_2} '_eyelink_aligned.mat'];
        eyelink_aligned_filepath = [my_data.aligned_data_dir.eyelink '/' eyelink_filename];
        eyelink_2 = load(eyelink_aligned_filepath);
        
    end

end

video_scale = 1;
vid = video_parsed.timeseries;

eye = eyelink_1.timeseries;
width = video.width;
height = video.height;

x_ref = eyelink_1.ref_width;
y_ref = eyelink_1.ref_height;

x_scale = video.width/x_ref;
y_scale = video.height/y_ref;

x_pos_1 = eye(:,1)*x_scale*video_scale;
y_pos_1 = eye(:,2)*y_scale*video_scale;

eye = eyelink_2.timeseries;
width = video.width;
height = video.height;

x_ref = eyelink_2.ref_width;
y_ref = eyelink_2.ref_height;

x_scale = video.width/x_ref;
y_scale = video.height/y_ref;

x_pos_2 = eye(:,1)*x_scale*video_scale;
y_pos_2 = eye(:,2)*y_scale*video_scale;

fig = figure(1); clf
vidObj = VideoWriter(['supert_tuxkart']);
open(vidObj)

frame_size = [height width]*video_scale;
img_width = frame_size(2);
img_height = frame_size(1);
[x,y] = meshgrid(1:img_width,1:img_height);
opticFlow = opticalFlowHS;

for i = 1:4859
    frame = uint8(imresize(squeeze(vid(i,:,:,:)), frame_size));
    %frame = uint8(squeeze(vid(i,:,:,:)));
    frameGray = rgb2gray(frame);
    
    clf
    imshow(uint8(frame)); hold on

    flow = estimateFlow(opticFlow,frameGray);
    
    a = plot(flow,'DecimationFactor',[5 5],'ScaleFactor',60);
    q = findobj(a,'type','Quiver');
    q.Color = 'r';
    
%     plot(x_pos(i),y_pos(i),'og','MarkerSize', 10, 'LineWidth', 3);
%     plot(x_pos_1(i),y_pos_1(i),'og','MarkerSize', 10, 'LineWidth', 3);
%     plot(x_pos_2(i),y_pos_2(i),'oc','MarkerSize', 10, 'LineWidth', 3);
    currFrame = getframe(gcf);
    drawnow;hold off
        writeVideo(vidObj,currFrame);
    %     pause
end
close(vidObj);



%% draw mean optical flow and spatially resolved optical flow for video game
% i_file = 1;
% vid_filename = metadata_stk.old_filename{i_file};
% video_dir = ['E:/Active-Passive-SRC/data/supertuxkart-session-' num2str(metadata_stk.session(i_file)) '/raw/video/resized/'];
% video_path = [video_dir vid_filename '.avi'];
% video = initFromVideoReader(Video(), VideoReader(video_path));
opticFlow = opticalFlowHS;

for i = 1:length(video_parsed.timeseries)
    
    frame = uint8(imresize(squeeze(video_parsed.timeseries(i,:,:,:)), [23 40]));
    %frame = uint8(squeeze(vid(i,:,:,:)));
    frameGray = rgb2gray(frame);
    flow(i) = estimateFlow(opticFlow,frameGray);
    mean_mag(i) = mean2(flow(i).Magnitude);

end

mean_mag(1) = 0;
minVal = min(mean_mag);
maxVal = max(mean_mag);
mean_mag_norm = (mean_mag - minVal) / ( maxVal - minVal )*255;

minVal = min(mean_mag_norm);
maxVal = max(mean_mag_norm);
% your_original_data = minVal + norm_data.*(maxVal - minVal

[height, width, n_channels] = size(frame);
frame_size = [height width]*video_scale;
img_width = frame_size(2);
img_height = frame_size(1);
frame_size = [img_height img_width]*video_scale;

eye = eyelink_1.timeseries;

x_ref = eyelink_1.ref_width;
y_ref = eyelink_1.ref_height;

x_scale = img_width/x_ref;
y_scale = img_height/y_ref;

x_pos_1 = eye(:,1)*x_scale*video_scale;
y_pos_1 = eye(:,2)*y_scale*video_scale;

figure(1);clf
vidObj = VideoWriter(['optic_flow_vs_mean_optic_flow_eye.mp4']);
open(vidObj)
for i = 1:length(video_parsed.timeseries)
    clf
    subplot(3,2,3)
    imshow(uint8(squeeze(video_parsed.timeseries(i,:,:,:))))
    
    subplot(2,2,2);hold on
    flow_mag = flow(i).Magnitude;
%     frame = imresize(flow_mag, [video.height, video.width]);
    imagesc(flow_mag)
%     plot(x_pos_1(i),y_pos_1(i),'og','MarkerSize', 10, 'LineWidth', 3);
    set(gca,'xTickLabel',[],'YTickLabel', [])
    title('optical flow magnitude')
    axis image
    colormap jet
    hold off
%     axis off

    subplot(2,2,4);hold on
    imshow(uint8(imresize(mean_mag_norm(i), size(flow_mag))))
%     plot(x_pos_1(i),y_pos_1(i),'og','MarkerSize', 10, 'LineWidth', 3);
    set(gca,'xTickLabel',[],'YTickLabel', [])

    caxis([minVal 255]); hold on
    axis image    
    colormap jet
    hold off

    drawnow
    title('mean optical flow magnitude')
    currFrame = getframe(gcf);
    writeVideo(vidObj,currFrame);
end
close(vidObj);

%% draw mean optical flow of the BYD
filename = 'highway-driving_wja1cg3gs_1080__D.mp4';
filename = 'E:\Active-Passive-SRC\data\supertuxkart-session-2\raw\video\stk_18_5_3_1.mp4'
% filename = 'E:\Documents\Demo Materials\BYD.avi';
video = initFromVideoReader(Video(), VideoReader(filename));
opticFlow = opticalFlowHS;
height = video.height;
width = video.width;

figure(1);clf
vidObj = VideoWriter(['optic_flow_super_tuxkart']);
open(vidObj)
for i = 1:length(video.data)
    
    frame = uint8(squeeze(video.data(i,:,:,:)));
    frameGray = rgb2gray(frame);
    flow = estimateFlow(opticFlow, frameGray);
    disp(i)
    
    subplot(1,2,1); hold on
    imshow(uint8(frame))
        axis image

%     a = plot(flow,'DecimationFactor',[5 5],'ScaleFactor',60);
%     q = findobj(a,'type','Quiver');
%     q.Color = 'r';
%     
    subplot(1,2,2); hold on
    imagesc(flipud(flow.Magnitude))
    set(gca,'xTickLabel',[],'YTickLabel', [])
%     title('optical flow magnitude')
    axis image
    colormap jet
    
%     flow.Magnitude = imresize(squeeze(flow.Magnitude),[video.height, video.width]);
%     flow.Vx = imresize(squeeze(flow.Vx),[video.height, video.width]);
%     flow.Vy = imresize(squeeze(flow.Vy),[video.height, video.width]);
%     a = plot(flow,'DecimationFactor',[5 5],'ScaleFactor',60);
%     q = findobj(a,'type','Quiver');
%     q.Color = 'r';
    drawnow
    currFrame = getframe(gcf);
    writeVideo(vidObj,currFrame);
    clf
end
close(vidObj);

%%
img_0 = zeros(video.height,video.width,1);
temporal_contrast = zeros(video.num_frames, video.height, video.width,'uint8');
for i = 1:length(video.data)
    disp(i)
%     frame = uint8(imresize(squeeze(video.data(i,:,:,:)), [57 72]));
    img_1 = rgb2gray(squeeze(video.data(i,:,:,:)));
    temporal_contrast(i,:,:) = uint8(img_0) - uint8(img_1);
    mean_mag(i) = mean2(double(temporal_contrast(i,:,:)));
    img_0 = img_1; 
end

mean_mag = [];
for i = 1:length(video.data)
    disp(i)
    mean_mag(i) = mean2(double(temporal_contrast(i,:,:)));
end

mean_mag(1) = 0;
minVal = min(mean_mag);
maxVal = max(mean_mag);
mean_mag_norm = (mean_mag - minVal) / ( maxVal - minVal )*255;

minVal = min(mean_mag_norm);
maxVal = max(mean_mag_norm);
video_scale = 1;
[n_frames, height, width, n_channels] = size(temporal_contrast);
frame_size = [height width]*video_scale;
img_width = frame_size(2);
img_height = frame_size(1);
frame_size = [img_height img_width]*video_scale;

figure(1);clf
vidObj = VideoWriter(['byd_global_contrast_1.mp4'], 'Motion JPEG AVI');
vidObj.Quality = 95;

open(vidObj)
for i = 1:length(video.data)
    disp(i);clf
    subplot(2,1,1);hold on
    imshow(uint8(squeeze(video.data(i,:,:,:))))
    set(gca,'xTickLabel',[],'YTickLabel', [])
    axis image
    colormap jet
    hold off

    subplot(2,1,2);hold on
    imshow(uint8(imresize(mean_mag_norm(i), [57 72])))
    set(gca,'xTickLabel',[],'YTickLabel', [])

    caxis([minVal 255]); hold on
    axis image    
    colormap jet
    title('temporal contrast')
    currFrame = getframe(gcf);
    writeVideo(vidObj,currFrame);
end
close(vidObj);

%%
flow_mag = flow(i).Magnitude;
stim_resized = resizeVideo(stim.data,1/2);
[n, height, width] = size(stim_resized); %stim_reshaped = reshape(stim_resized,[n height*width]); stim_cov = cov(stim_reshaped); imagesc(stim_cov);
for i = 1:n
    m = squeeze(stim_resized(i,:,:));
    [colfrom, rowfrom, values] = improfile(m, [1, width], [1, height]);
    diag_val(i,:) = values;
end
clf; stim_cov = corr(diag_val); imagesc(stim_cov); colorbar
 colormap jet
 
n = size(diag_val,2);
for  i = 1:n
    x = diag_val(:,i)';
    for ii = 1:n
        y = diag_val(:,ii)';
        c = xcorr(x,y);
        [t(i,ii) v(i,ii)] = max(c);
    end
end
imagesc((v-5101)/30); colorbar; colormap jet

fs = 30;
x = sin(([1:1000]/fs)*pi) + sin(([1:1000]/fs)*pi*4);

[autocor, lags] = xcorr(x);
[pksh,lcsh] = findpeaks(autocor);
short = mean(diff(lcsh))/fs;

hold on
plot(lags/fs,autocor)
xlabel('Lag (days)')
ylabel('Autocorrelation')
axis([-21 21 -0.4 1.1])

[pklg,lclg] = findpeaks(autocor, ...
    'MinPeakDistance',ceil(short)*fs,'MinPeakheight',0.3);
long = mean(diff(lclg))/fs;

pks = plot(lags(lcsh)/fs,pksh,'or', ...
    lags(lclg)/fs,pklg+0.05,'vk');
hold off
legend(pks,[repmat('Period: ',[2 1]) num2str([short;long],0)])
axis([-21 21 -0.4 1.1])

%%
imagesc(t); colorbar; colormap jet


figure(1)
subplot(1,3,1)
t = (1:length(stim.data))/30;
plot(t,zscore(squeeze(stim.data(:,20,45))),'r')
ylabel('optic flow magnitude')
box off
set(gca,'YTick',[],'YTickLabel',[])
% ylabel('optic flow magnitude')
xlim([0 150])
subplot(1,3,2)
plot(t,zscore(squeeze(stim.data(:,10,25))),'g')
box off
set(gca,'YTick',[],'YTickLabel',[])
xlim([0 150])
xlabel('time (s)')
subplot(1,3,3)
plot(t,zscore(squeeze(stim.data(:,25,35))),'k')
box off
set(gca,'YTick',[],'YTickLabel',[])
% ylabel('optic flow magnitude')
saveas(gcf,'optic flow magnitude','png')

imagesc(squeeze(stim.data(199,:,:)))