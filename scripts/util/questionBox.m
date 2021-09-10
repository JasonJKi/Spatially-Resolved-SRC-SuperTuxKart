function status = questionBox(question_str)

if nargin < 1
    question_str = 'Correction required?'
end

answer = questdlg(question_str, 'Yes', 'No');
% Handle response
status = 0;
switch answer
    case 'Yes'
        status = 2;
    case 'No'
        status = 1;
end
