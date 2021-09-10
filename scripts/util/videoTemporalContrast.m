function     temporal_contrast = videoTemporalContrast(video_gray)
[num_frames, height, width, num_channels] = size(video_gray);
zero_padding_first_frame = zeros(1, height, width);
temporal_contrast = diff(video_gray);
temporal_contrast = cat(1,zero_padding_first_frame,temporal_contrast);
temporal_contrast =  abs(temporal_contrast).^2;