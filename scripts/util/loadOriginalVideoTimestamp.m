function     video = loadOriginalVideoTimestamp(video, video_timestamp_mat_filepath, is_load_original_timestamp)

if  exist(video_timestamp_mat_filepath, 'file') == 2 && is_load_original_timestamp
    data = load(video_timestamp_mat_filepath);
    timestamp = double(data.video_timestamp')/1000;
    disp(['timestamp vs video frame lengt difference: ' num2str(diff([length(video.timestamp) length(timestamp)]))])
    video.timestamp = timestamp;
    ind = min([length(video.timestamp) length(timestamp)]);
    video.timestamp = video.timestamp(1:ind);
    video.data = video.data(1:ind,:,:,:);
end