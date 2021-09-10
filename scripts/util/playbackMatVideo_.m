function playbackMatVideo_(video, fs)
[nFrames, width, height] = size(video);
figure
for i = 1:nFrames
    frame = squeeze(video(:,:,i));
    imagesc(frame)
    pause(1/fs)
end