function [ videoOut ] = videoToGray(video)



if ndims(video) > 3
    [nFrames, height, width, nChannels] = size(video);
else
    videoOut = video;
    return
end

videoOut = zeros(nFrames, height, width);

for i=1:nFrames
    frame = squeeze(video(i,:,:,:));
    frameGray = rgb2gray(frame);
    videoOut(i,:,:) = frameGray;
end
