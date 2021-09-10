function  eeg_processed = eegRemovalBadChannel(eeg, bad_electrode)
preprocessing = PreprocessEeg(eeg.timeseries, eeg.fs, 'ActiCap96.loc');
preprocessing.removeBadChannels(bad_electrode);
preprocessing.interpolateBadChannels();
eeg_processed = preprocessing.outputData();
