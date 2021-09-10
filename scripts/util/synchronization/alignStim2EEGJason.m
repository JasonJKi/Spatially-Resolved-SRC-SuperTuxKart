function [eeg_resampled,stim_resampled] = alignStim2EEGJason(stim, eeg, targe_fs)
stim_data = double(videoMean2(stim.data));
stim_flash_index = stim.flash_index -  stim.flash_index(1) + 1;
stim_timestamp = stim.timestamp - stim.timestamp(1);
stim_fs = double(stim.fs);
    
eeg_data = double(eeg.data');
eeg_timestamp = eeg.timestamp';
eeg_flash_index = eeg.flash_index - eeg.flash_index(1) + 1';
eeg_fs = double(eeg.fs);

%% eeg/photodiode trigger
eeg_flash_index  = eeg_flash_index(:).'; % row
eeg_flash_timestamp = eeg_timestamp(eeg_flash_index); 
eeg_flash_time_interval = [0 diff(eeg_flash_timestamp)];

%% stimulus
stim_flash_index = stim_flash_index(:).'; % row
stim_flash_timestamp = stim_timestamp(stim_flash_index);

%% assuming that first stim_flash_index matches first trigger event...
if numel(eeg_flash_index)~=numel(stim_flash_timestamp)
    error('Indicator and trigger lengths do not match');
end
num_flashes = numel(eeg_flash_index);

%% alignment  
% basic algorithm
% first flash frame time is given by the time of the first photodiode spike
% subsequent flash frame times are given by the previous time + photodiode
% ISI
flash_timestamp = zeros(num_flashes,1);
flash_timestamp(1) = eeg_flash_timestamp(1);  
for f=2:num_flashes
    flash_timestamp(f)=flash_timestamp(f-1)+eeg_flash_time_interval(f);
end
flash_frame_value = stim_data(stim_flash_index);
flash_frame_index = stim_flash_index;

% to fill in features in between flash frames
% linearly interpolate
allV=[]; allT=[];
for f = 1:num_flashes-1
    nIntervening = flash_frame_index(f + 1) - flash_frame_index(f) - 1;
    
    vals = stim_data(flash_frame_index(f)+1:flash_frame_index(f+1)-1);
    
    dt = (flash_timestamp(f+1) - flash_timestamp(f) ) / ( flash_frame_index(f + 1) - flash_frame_index(f) );
    
    tmes = (1:nIntervening)' * dt + flash_timestamp(f);
    
    allV = cat(1, allV, [flash_frame_value(f); vals]);
    allT = cat(1, allT, [flash_timestamp(f); tmes]);
end
    
tInterp = eeg_timestamp(eeg_flash_index(1)):1/eeg_fs:eeg_timestamp(eeg_flash_index(end));
stim_dataInterp = interp1(allT, allV, tInterp, 'linear', 'extrap');

%%
% stim_dataInterp and eeg are now on the same (eeg) clock
% resample them both to a more reasonable rate
stim_resampled=resample(stim_dataInterp,targe_fs,eeg_fs);
nStimResampFrames=numel(stim_resampled);

eeg_resampled=(resample(eeg_data.',targe_fs,eeg_fs)).';
nEEGresamplesKept=size(eeg_resampled,2);

%% logic bit to make the stim_data and eeg same length
if nEEGresamplesKept>nStimResampFrames
    nSamplesToRemove=nEEGresamplesKept-nStimResampFrames;
    eeg_resampled=eeg_resampled(:,1:end-nSamplesToRemove);
elseif nEEGresamplesKept<nStimResampFrames
    nSamplesToRemove=nStimResampFrames-nEEGresamplesKept;
    stim_resampled=stim_resampled(1:end-nSamplesToRemove);
else
    % lengths match
end
end

