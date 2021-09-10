function metadata = chooseSession(metadata, session)

num_files = height(metadata);
index_all = zeros(num_files,1);
for i = session(:)'
   index = find(metadata.session == i);
   index_all(index) = 1;
end
index_all = find(index_all); 
metadata = metadata(index_all,:);
file_index = find(metadata.status == 1)';

metadata = metadata(file_index,:);
