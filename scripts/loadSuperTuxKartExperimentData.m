function [stimulus, response, eyelink] = loadSuperTuxKartExperimentData(data_dir, metadata_stk)
num_files = height(metadata_stk);

for i_file = 1:num_files
    
    filename = metadata_stk.filename{i_file};
    disp(['loading trial: ' filename]) 
    public_data_outpath = [data_dir '/' filename];
    load(public_data_outpath, 'stim','res','eye','eye_ref_width','eye_ref_height')

    stimulus{i_file} = stim;
    response{i_file} = res;
    eyelink{i_file}.data = eye;
    eyelink{i_file}.ref_width = eye_ref_width;
    eyelink{i_file}.ref_height = eye_ref_height;
   
end