function [metadata, file_index, num_files] = loadSTKMetadata(session_number)
stk_data_version = '';
if nargin > 0
    stk_data_version = ['supertuxkart-session-' num2str(session_number)];
end
if nargin < 2
    rootDir = '../';
end

metadata_path = [rootDir 'data/' stk_data_version '/metadata'];
load(metadata_path,'metadata')
metadata = metadata(find(metadata.status==1),:);
metadata.file_id = (1:height(metadata))';
file_index = find(metadata.status==1)';
num_files = height(metadata);

