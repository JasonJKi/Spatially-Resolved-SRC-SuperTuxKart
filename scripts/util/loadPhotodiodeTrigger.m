function    photodiode = loadPhotodiodeTrigger(photodiode_trigger_mat_filepath, filename, raw_data_dir)
disp(['epoching: ' photodiode_trigger_mat_filepath])

if  exist(photodiode_trigger_mat_filepath, 'file') ~= 2
    %  Load in photodiode from  labstream xdf file
    xdf_filepath = [raw_data_dir '/labstreams/' filename '.xdf'];
    disp(['Loading labstream: ' filename])
    lsl = loadMyLabstreams(xdf_filepath);
    photodiode =  lsl.photodiode;
    save(photodiode_trigger_mat_filepath,   '-struct', 'photodiode')
else
    photodiode = load(photodiode_trigger_mat_filepath);
end