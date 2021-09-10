function figureDrawSRCByCondition(file_dir)
condition_str = {'active', 'sham', 'passive', 'count'};
caxis_comp = [0 0 0; .045 .025 .02]';
num_components = 3;
condition_ind = [1 3];
num_conditions = length(condition_ind);
for i_cond = 1:num_conditions
    ind = condition_ind(i_cond);
    output_path = [file_dir 'src_2d_' condition_str{ind} '.mat'];
    load(output_path, 'src_2d', 'A_2d', 'B_2d')
    for i_comp = 1:num_components
        
        i_subplot = (i_comp-1)*num_conditions + i_cond;
        subplot(num_components,num_conditions,i_subplot);
        src_img = src_2d(:,:,i_comp);
        imagesc(src_img);
        set(gca,'xTickLabel',[],'YTickLabel', [])
        caxis(caxis_comp(i_comp,:))
        
        if i_comp ==1
            title(condition_str{ind})
        end
        
        if i_cond == 1
            ylabel(['c' num2str(i_comp)])
        end
    end
    
    output_path = ['output/demo_video/trf_2d_' condition_str{ind} '.mp4'];
    video = draw2DVideo(src_2d, A_2d, output_path, fs);
    clf
    output_path = ['output/figures/2nd_exam/trf_ypos_vs_time_'  condition_str{ind}];
    fig3 = drawYPosTRFAtCenter(A_2d, fs, 3);
    saveas(fig3, output_path, 'jpeg');

end
