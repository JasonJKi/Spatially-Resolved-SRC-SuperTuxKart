function eeg_processed = eegRPCAPreprocessingPipeline1(eeg)
preprocessing = PreprocessEeg(eeg.timeseries, eeg.fs, 'ActiCap96.loc');
preprocessing.driftLineFilter(4);
preprocessing.rpcaFilter();
preprocessing.meanSubtraction();
preprocessing.setEog([], true);
preprocessing.eyeArtefactFilter();
preprocessing.removeArtefactInTime(3, 2);
preprocessing.removeArtefactInSpace(3);
preprocessing.interpolateBadSamples();

% rpca preprocess pipeline

%         preprocessing.interpolateBadSamples();
%         preprocessing.removeArtefactInTime(3, 2);
%         preprocessing.removeArtefactInSpace(3);
eeg_processed = preprocessing.outputData();
% figure(3); clf; preprocessing.visualizeTopoplot('ActiCap96.loc');