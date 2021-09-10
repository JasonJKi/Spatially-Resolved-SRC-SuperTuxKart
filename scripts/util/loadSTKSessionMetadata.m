function [metadata_stk, session_str, session_index, warped_index] = loadSTKSessionMetadata(session)

if nargin < 1
    session = [1 2 3];
end

[metadata_stk, ~, ~] = loadSTKMetadata();
warped_index = (metadata_stk.warped == 1)';
session_index = createSessionIndex(metadata_stk, session);
metadata_stk = metadata_stk(session_index,:);

num_sessions = length(session);
iter = 1;
session = session(:)';
session_str = '';
for i = session
    if iter == 1
        session_str = num2str(i);
        iter = iter + 1;
        continue
    end
    session_str = [session_str '_' num2str(i)];
    iter = iter + 1;
end
