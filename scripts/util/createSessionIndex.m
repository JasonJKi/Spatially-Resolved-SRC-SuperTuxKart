function session_index = createSessionIndex(metadata_stk, session_numbers)

session_index = zeros(height(metadata_stk),1);
for i = 1:length(session_numbers)
    session = session_numbers(i);
    session_index = (metadata_stk.session==session) | session_index;
end