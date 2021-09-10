function [group_1, group_2, group_1_, group_2_, h_right] = compareSRCByGroupRegionOfInterest(src_by_group, comparison_grp_index, is_corrected)

if nargin < 3
    is_corrected = true;
end

[height, width, ~, ~] = size(src_by_group{1});
% num_components = 3
% tail = 'right';
ind_1 = comparison_grp_index(1);
ind_2 = comparison_grp_index(2);
for i = 1:height
    for ii = 1:width
%         for i_comp = 1:num_components
%             ind_1 = comparison_grp_index(1);
%             ind_2 = comparison_grp_index(2);
%             group_1 = squeeze(src_by_group{ind_1}(i,ii,i_comp,:));
%             group_2 = squeeze(src_by_group{ind_2}(i,ii,i_comp,:));
%             [p_val_src_condition_comp(i, ii, i_comp), h_stats_src_comp(i,ii,i_comp)] = ranksum(group_1,  group_2, 'tail', tail, 'method','approximate');
%         end
              
        group_1 = squeeze(sum(src_by_group{ind_1}(i,ii,:,:),3));
        group_2 = squeeze(sum(src_by_group{ind_2}(i,ii,:,:),3));
        
       [p_right(i, ii), h_right(i,ii)] = ranksum(group_1,  group_2, 'tail', 'right', 'method','approximate');
       [p_left(i, ii), h_left(i,ii)] = ranksum(group_1,  group_2, 'tail', 'left', 'method','approximate');

    end
end

if is_corrected
    [corrected_h_right, ~,~, corrected_p_right] = fdr_bh(p_right(:), .05);
    p_right = reshape(corrected_p_right, [height, width]);
    h_right = reshape(corrected_h_right, [height, width]);

    [corrected_h_left, ~,~, corrected_p_left] = fdr_bh(p_left(:), 0.05);
    p_left = reshape(corrected_p_left, [height, width]);
    h_left = reshape(corrected_h_left, [height, width]);
end

iter = 1;
iter_ = 1;
src_sum_sig_pixel_grp_1 = [];
src_sum_sig_pixel_grp_2 = [];
for i = 1:height
    for ii = 1:width
        if h_right(i,ii)
            src_sum_sig_pixel_grp_1(iter,:) = squeeze(sum(src_by_group{ind_1}(i,ii,:,:),3));
            src_sum_sig_pixel_grp_2(iter,:) = squeeze(sum(src_by_group{ind_2}(i,ii,:,:),3));  
            iter=iter+1;
        else
            src_sum_not_sig_pixel_grp_1(iter,:) = squeeze(sum(src_by_group{ind_1}(i,ii,:,:),3));
            src_sum_not_sig_pixel_grp_2(iter,:) = squeeze(sum(src_by_group{ind_2}(i,ii,:,:),3));
            iter_ = iter_ +1;
        end
    end
end

if isempty(src_sum_sig_pixel_grp_1)
    group_1=[];group_2=[];group_1_=[]; group_2_=[];
    return
end
group_1 = mean(src_sum_sig_pixel_grp_1, 1);
group_2 = mean(src_sum_sig_pixel_grp_2, 1);

group_1_ = mean(src_sum_not_sig_pixel_grp_1, 1);
group_2_ = mean(src_sum_not_sig_pixel_grp_2, 1);
