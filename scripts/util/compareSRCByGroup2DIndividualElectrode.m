function [p_left, h_left, p_right, h_right] = compareSRCByGroup2DIndividualElectrode(src_by_group, comparison_grp_index, is_corrected)

if nargin < 3
    is_corrected = true;
end

[height, width, n_channels, ~] = size(src_by_group{1});
% num_components = 3
% tail = 'right';
ind_1 = comparison_grp_index(1);
ind_2 = comparison_grp_index(2);
for i_channel = 1:n_channels
    for i = 1:height
        for ii = 1:width

    %         for i_comp = 1:num_components
    %             ind_1 = comparison_grp_index(1);
    %             ind_2 = comparison_grp_index(2);
    %             group_1 = squeeze(src_by_group{ind_1}(i,ii,i_comp,:));
    %             group_2 = squeeze(src_by_group{ind_2}(i,ii,i_comp,:));
    %             [p_val_src_condition_comp(i, ii, i_comp), h_stats_src_comp(i,ii,i_comp)] = ranksum(group_1,  group_2, 'tail', tail, 'method','approximate');
    %         end

            group_1 = squeeze(src_by_group{ind_1}(i,ii,i_channel,:));
            group_2 = squeeze(src_by_group{ind_2}(i,ii,i_channel,:));

           [p_right_(i, ii), h_right(i,ii)] = ranksum(group_1,  group_2, 'tail', 'right', 'method','approximate');
           [p_left_(i, ii), h_left(i,ii)] = ranksum(group_1,  group_2, 'tail', 'left', 'method','approximate');

        end
    end

    if is_corrected
        [corrected_h_right, ~,~, corrected_p_right] = fdr_bh(p_right_(:));
    %     [corrected_p_right_, corrected_h_right_] = bonf_holm(p_right(:));
        p_right(:, :, i_channel) = reshape(corrected_p_right, [height, width]);
        h_right(:, :, i_channel)  = reshape(corrected_h_right, [height, width]);

        [corrected_h_left, ~,~, corrected_p_left] = fdr_bh(p_left_(:));
        p_left(:, :, i_channel)  = reshape(corrected_p_left, [height, width]);
        h_left(:, :, i_channel)  = reshape(corrected_h_left, [height, width]);
    end
end