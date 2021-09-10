function [metadata_stk,warped_files] = re_index_warped_files(metadata_stk)
warped_files = zeros(height(metadata_stk),1);
warped_file_index = [6,7,13,17,25,26,28,36,43,49,52,56,61,64,75,79,80,83,85,90,100,109,116,119,121,125,128,130,132,133,134,136,142,143,147,148,150,152,154,155,156,157,163,165,171,173,178,182,184,187,189,190,191];
warped_files(warped_file_index) = 1;
metadata_stk(warped_file_index, :) = [];
% usable_file_index(warped_file_index) = 0;
% src_file_index = find(usable_file_index);