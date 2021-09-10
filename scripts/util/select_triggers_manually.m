rootDir = '../../../';

% Get metadata table for all SuperTuxkart races to easily load in video
% and eeg data for processing.
dataDir = 'SuperTuxKart Experiment/data';
metadataPath = [rootDir dataDir '/' 'metadata.xlsx'];
metadataTable = readtable(metadataPath);
index = find(contains(metadataTable.prefix,'stk'));
metadata.filenames = metadataTable.filename(index);
metadata.subject = metadataTable.id(index);
metadata.condition = metadataTable.condition(index);
metadata.order = metadataTable.order(index);
metadata.trial = metadataTable.trial(index);
metadata.video = metadataTable.video(index);
nRaces = length(index);

%% Processing streamline for EEG and Video all races.
for iRace = 1:nRaces
    
    % Get race information and assign num and string variables.
    fileIDNum = iRace; 
    trialNum = metadata.trial(iRace);
    subjectNumStr = metadata.subject{iRace};
    subjectNum = str2double(subjectNumStr);
    trialNumStr = num2str(trialNum);
    fileIDNumStr = num2str(fileIDNum);

    condition = metadata.condition(iRace)
    conditionStr = num2str(condition); 
    trialStr = num2str(trialNum);

    order = metadata.condition(iRace); 
    orderStr = num2str(order);

    figureName = ['output/figures/trigger/run_' fileIDNumStr '_' subjectNumStr '_' conditionStr '_' trialNumStr];
    openfig(figureName)
    [x,y, button] = ginput(2);
    switch button
        case 32 %space
    end
    close all
end