function [index] = manualElectrodeIndexing(eeg, eog_index)

% preprocessing = PreprocessEeg(eeg.timeseries, eeg.fs);
% preprocessing.driftLineFilter(6);
% eeg = preprocessing.outputData();
timeseries = eeg - repmat(mean(eeg), size(eeg,1),1);

figure(1)
timeseries(:,eog_index) = -1000;
imagesc(timeseries)
caxis([-100 100])
[x, y] = ginput();
index = round(x);
figure(1); clf
timeseries(:,index) = 0;
imagesc(timeseries)
caxis([-100 100])

