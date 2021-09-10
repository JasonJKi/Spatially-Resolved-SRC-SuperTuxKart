function  eeg_processed = eegManaulRemovalPreprocessingPipeline1(eeg, bad_electrode)
preprocessing = PreprocessEeg(eeg.timeseries, eeg.fs, 'ActiCap96.loc');
preprocessing.driftFilter(4);
preprocessing.setEog([], true);
preprocessing.eyeArtefactFilter();
preprocessing.removeBadChannels(bad_electrode);
preprocessing.interpolateBadChannels();
preprocessing.removeArtefactInTime(3, 2);
preprocessing.removeArtefactInSpace(3);
preprocessing.interpolateBadSamples();
eeg_processed = preprocessing.outputData();
