function [p_left, h_left, p_right, h_right] = compareSRCByGroup2D(src_by_group, comparison_grp_index, is_corrected)

if nargin < 3
    is_corrected = true;
end

[height, width, ~, ~] = size(src_by_group{1});
% tail = 'right';
ind_1 = comparison_grp_index(1);
ind_2 = comparison_grp_index(2);
for i = 1:height
    for ii = 1:width
              
        group_1 = squeeze(sum(src_by_group{ind_1}(i,ii,:,:),3));
        group_2 = squeeze(sum(src_by_group{ind_2}(i,ii,:,:),3));
        
       [p_right(i, ii), h_right(i,ii)] = ranksum(group_1,  group_2, 'tail', 'right', 'method','approximate');
       [p_left(i, ii), h_left(i,ii)] = ranksum(group_1,  group_2, 'tail', 'left', 'method','approximate');

    end
end

if is_corrected
    [corrected_h_right, ~,~, corrected_p_right] = fdr_bh(p_right(:));
%     [corrected_p_right_, corrected_h_right_] = bonf_holm(p_right(:));
    p_right = reshape(corrected_p_right, [height, width]);
    h_right = reshape(corrected_h_right, [height, width]);

    [corrected_h_left, ~,~, corrected_p_left] = fdr_bh(p_left(:));
    p_left = reshape(corrected_p_left, [height, width]);
    h_left = reshape(corrected_h_left, [height, width]);
end