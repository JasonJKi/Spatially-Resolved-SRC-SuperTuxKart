function [data] = loadAllData(preprocessing_opts)

[metadata_stk, session_str, session_index, warped_index] = loadSTKSessionMetadata();
[stimulus, response] = loadPreprocessedStimEeg(metadata_stk, preprocessing_opts); 

data.stimulus = stimulus;
data.response = response;