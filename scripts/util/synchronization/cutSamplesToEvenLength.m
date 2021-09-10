function [data_1, data_2] = cutSamplesToEvenLength( data_1, data_2)
data1_num_samples = length(data_1);
data2_num_samples = length(data_2);

%% logic bit to make the stim_data and eeg same length
if data2_num_samples > data1_num_samples
    nSamplesToRemove=data2_num_samples-data1_num_samples;
    data_2 = data_2(1:end-nSamplesToRemove,:,:);
    disp('sample length mismatching')

elseif data2_num_samples < data1_num_samples
    nSamplesToRemove=data1_num_samples-data2_num_samples;
    data_1 = data_1(1:end-nSamplesToRemove,:,:);
    disp('sample length mismatching')

else
    % lengths match
end
end

