function [stimulus, response, metadata_stk, session_str] = selectSessionForAnalysis(data, session)
[metadata_stk, session_str, session_index, warped_index] = loadSTKSessionMetadata(session);
session_index(warped_index) = 0;
metadata_stk((metadata_stk.warped==1),:) = [];

% file_index = 1:height(metadata_stk);
file_index   = find(session_index)';
file_index = file_index(:)';

% n_1 = cellfun(@length,data.stimulus);
% n_2 = cellfun(@length,data.response);
% find(n_1~=n_2)
% file_index = find(~(metadata_stk.warped==1))';
iter=1;
for i = file_index
    stimulus{iter} = data.stimulus{i};
    response{iter} = data.response{i};
    iter = iter +1;
end
