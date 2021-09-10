function writeVideoFile(video, fs, outputPath)

vwObj = VideoWriter(outputPath);
set(v,'FrameRate', fs); open(v);
for i = 1:nVideoEpochIndex
    frame = squeeze(video(i,:,:,:));
    writeVideo(vwObj, frame);
end
close(vwObj);
