function inputs = createInputsForFigures(response, stimulus, cca_estimator, metadata_stk)

inputs.cca_estimator = cca_estimator;
inputs.A = cca_estimator.A;
inputs.B = cca_estimator.B;
inputs.rxx = cca_estimator.covMatrix.rxx;
inputs.ryy = cca_estimator.covMatrix.ryy;
inputs.kx = cca_estimator.params.kx;
inputs.ky = cca_estimator.params.ky;
inputs.engagement_rating = metadata_stk.engagement_rating;
inputs.response = response; 
inputs.stimulus = stimulus;
inputs.metadata = metadata_stk;
if size(inputs.ryy,1) == 96
    loc_filename = 'ActiCap96.loc';
else
    loc_filename = 'ActiCap92.loc';
end

inputs.locFile = readLocationFile(LocationInfo(), loc_filename);
