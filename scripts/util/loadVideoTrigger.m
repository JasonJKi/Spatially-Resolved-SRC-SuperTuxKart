function  video_trigger = loadVideoTrigger(filename, video_trigger_dir, version)
video_trigger_mat_filepath = [video_trigger_dir '/' filename '_video_trigger.mat'];
if exist(video_trigger_mat_filepath, 'file')  ~=2
    %Load in Video.
    disp(['Extracting Triggers: '])
    disp(['Loading avi video: ' filename])
    video_filepath = ['../data/video/resized' version '/' filename '.avi'];
    video = initFromVideoReader(Video(), VideoReader(video_filepath),  video_resize_scale);
    video_trigger = extractVideoTriggersFromFrame(video);
    save(video_trigger_mat_filepath,  '-struct', 'video_trigger');
else
    video_trigger = load(video_trigger_mat_filepath);
end