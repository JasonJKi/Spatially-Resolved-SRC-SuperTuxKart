function drawSRCEyeByGroupComparison(src_by_group, comparison_grp_index, group_name,ref_width, ref_height)

[p_left, h_left, p_right, h_right] = compareSRCByGroup(src_by_group, comparison_grp_index);

i_plot = 1; num_groups = length(comparison_grp_index);

for i_group = 1:num_groups
   
    ind = comparison_grp_index(i_group);
    src_group = mean(src_by_group{ind},4);
    vals = squeeze(sum(src_group, 3));
    max_val = max(vals(:));
    src_img = squeeze(sum(src_group,3));
    subplot(1, 3, i_plot)

%     imagesc(src_img);
    img = heatmap_to_rgb(src_img, ref_width, ref_height, true);
    h = fspecial('gaussian',5,3);
    imshow(imfilter(img,h,'replicate'));
    
    caxis([0 max_val]);
    i_plot = i_plot + 1;
    
    set(gca,'xTickLabel',[],'YTickLabel', [])
    colormap jet
    title(group_name{i_group},'FontSize', 14)
    axis off
    
    if i_group ==1
        c_max =  round(max(src_img(:)),2)/sum(src_img(:));
        c_min = 0 ;
        c_axis = [c_min (c_min+c_max)/2 c_max];
%         c_axis_tick_label = {c_min, num2str(c_axis(2)), c_max} ;

        cb = colorbar('location','westoutside');
        set(cb,'Position', [0.10,0.37,0.01,0.29])
        set(cb,'YTick',c_axis,'YTickLabel', round(c_axis,3), 'TickLabelInterpreter', 'tex','FontSize',12)
        set(cb,'YLim',[c_min, c_max])
    end
    caxis([c_min c_max])

    axis image
    %axis tight

end

str_1 = group_name{1};
ind = strfind(str_1, ' ');
str_1 = str_1(1:ind-1);
str_2 = group_name{2};
ind = strfind(str_2, ' ');
str_2 = str_2(1:ind-1);
subplot(1,3,3)
imshow(h_right)
title([str_1 ' > ' str_2], 'FontSize', 14)

% subplot(2,2,4)
% imshow(h_left)
% title([str_1 ' < ' str_2])
% group_name = {'active', 'sham', 'passive', 'counting'};
% saveas(fig,  ['output/figures/src_' str_1 '_vs_' str_2] , 'jpeg');
% [group_1, group_2, group_1_, group_2_, h_right] = compareSRCByGroupRegionOfInterest(src_by_group, comparison_grp_index);

return


if isempty(group_1)
    return
end
[p, h] = ranksum(group_1,  group_2, 'tail', 'both', 'method','approximate');

subplot(3,2,5)
hold on
bar([1 3], [mean(group_1), mean(group_2)])
plot(1, group_1, '.')
plot(3, group_2, '.')
sigstar({[1 3]}, p, 0, false);

[p, h] = ranksum(group_1_,  group_2_, 'tail', 'both', 'method','approximate');
subplot(3,2,6)
hold on
bar([1 3], [mean(group_1_), mean(group_2_)])
plot(1, group_1_, '.')
plot(3, group_2_, '.')
sigstar({[1 3]}, p, 0, false);
