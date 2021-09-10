clear all; dependencies install
my_data = MyData('E:/Active-Passive-SRC-2D/data');

session = [1 2];
metadata_stk = chooseSession(my_data.metadata, session);

is_warp_correct = true;

[stimulus, response] = loadSuperTuxKartData(my_data, metadata_stk, is_warp_correct);

%% Figure 1) Neural Response Exhibits Visual Spatial selectivity  
% figure 1a draw visual dynamics
video = initFromVideoReader(Video(), VideoReader('output/demo_video/stk_24_0_1_2.avi'));
optical_flow = computeVideoFeature(opticalFlowHS, video.data);

paper_width = 20; paper_height = 6;
fig_1a = createMatlabFigure(1, paper_width, paper_height, 'inches');clf;
frame_index = sort(randperm(1000,n_frames));
draw_frames(video.data, optical_flow, frame_index)
saveas(fig_1a, 'output/figures/optical_flow_frames', 'png')

% figure 1b optical flow variance 
output_dir = 'output/computed_src_values';
load([output_dir '/src_2d_all.mat'], 'src_2d', 'A_2d', 'B_2d')
paper_width = 10; paper_height = 10;
fig1 = createMatlabFigure(2, paper_width, paper_height, 'inches');clf;
draw2DVideoVariance(stimulus);
saveas(fig1, 'output/figures/optic_flow_variance', 'png')

% figure 1c 2d src with significance 
paper_width = 15; paper_height = 6;
fig1_c = createMatlabFigure(3, paper_width, paper_height, 'inches');clf;
[src_2d_phase_shuffled, A_2d_phase_shuffled, B_2d_phase_shuffled] = load2dPhaseShuffledSRC([output_dir '/phase_randomized']);
[p_val_2d, h_2d, img_2d_surrogate] = computeSignificance(src_2d, src_2d_phase_shuffled);
num_component = 3;
[width, height, ~] = size(h_2d);
draw2dSRCFigureWithSignificance(src_2d, h_2d, num_component)
saveas(fig1_c, 'output/figures/src_2d_significant', 'png')

%% Figure 2) visual spatial temporal response.
output_dir = 'output/computed_src_values';
load([output_dir '/src_2d_all.mat'], 'src_2d', 'A_2d', 'B_2d')

% Figure 1A
paper_width = 40; paper_height = 2.5;
fig2_a = createMatlabFigure(4, paper_width, paper_height, 'inches');clf;
time_index = [1 5 6 7 8 9 16:19 25 ];
drawTRFOverSelectTimeInterval(A_2d(:,:,:,1), time_index, fs)
saveas(fig2_a, 'output/figures/trf_component_1', 'png')

paper_width = 40; paper_height = 2.5;
fig2_ab = createMatlabFigure(5, paper_width, paper_height, 'inches');clf;
time_index = [1:30]; time_index = [1 5 6 7 8 9  16:19 25];
drawTRFOverSelectTimeInterval(A_2d(:,:,:,2), time_index, fs)
saveas(fig2_ab, 'output/figures/trf_component_2', 'png')

paper_width = 40; paper_height = 1.5;
fig2_ab = createMatlabFigure(6, paper_width, paper_height, 'inches');clf;
time_index = [1:30]; 
drawTRFOverSelectTimeInterval(A_2d(:,:,:,3), time_index, fs)
saveas(fig2_ab, 'output/figures/trf_component_3', 'png')

draw2DVideo(src_2d, A_2d, 'output/demo_video/trf_2d.mp4', fs);

[src_2d_phase_shuffled, A_2d_phase_shuffled, B_2d_phase_shuffled] = load2dPhaseShuffledSRC([output_dir '/phase_randomized']);
src_2d_phase_shuffled_all= squeeze(mean(src_2d_phase_shuffled,5));
A_2d_phase_shuffled_all= squeeze(mean(A_2d_phase_shuffled,5));
draw2DVideo(src_2d_phase_shuffled_all, A_2d_phase_shuffled_all, 'output/demo_video/trf_2d_random.mp4', fs);

% Figure 2B
% Draw trf at vertical cross section 
fig2_b1 = createMatlabFigure(10, 6, 4, 'inches');clf;
[height, width, ~,~,~,~] = size(src_2d);
drawYPosTRFAtCenter(A_2d, fs, [15:16], [height width]*2);
saveas(fig2_b1,  'output/figures/trf_90' , 'jpeg');

% Draw trf at horizontal cross position  
fig2_b2 = createMatlabFigure(11, 6, 4, 'inches');clf;
drawXPosTRFAtCenter(A_2d_phase_shuffled_all, fs, [11:12], [height width]*2);
saveas(fig2_b2,  'output/figures/trf_180' , 'jpeg');

% Draw trf at vertical cross section phase randomized eeg
fig2_b3 = createMatlabFigure(12, 6, 4, 'inches');clf;
[height, width, ~,~,~,~] = size(src_2d);
drawYPosTRFAtCenter(A_2d_phase_shuffled_all, fs, [15:16], [height width]*2);
saveas(fig2_b3,  'output/figures/trf_90_rand' , 'jpeg');

% Draw trf at horizontal cross section phase randomized eeg
fig2_b4 = createMatlabFigure(13, 6, 4, 'inches');clf;
drawXPosTRFAtCenter(A_2d_phase_shuffled_all, fs, [11:12], [height width]*2);
saveas(fig2_b4,  'output/figures/trf_180_rand' , 'jpeg');

drawYPosTRFAtCenter(A_2d_phase_shuffled_all, fs, [15:16], [height width]*2);
output_path = 'output/demo_video/trf_c1_x_position';
vid_file = drawYPosTRFVideoOverXPos(A_2d_phase_shuffled_all, fs, output_path);

% video = initFromVideoReader(Video, VideoReader('output/demo_video/stk_24_0_1_2.avi') , 1);
%% Figure 3) compare by condition
computed_value_dir = 'output/computed_src_values';

for i = 1:length(stimulus) 
    race_time = length(stimulus{i});
    metadata_stk.race_time(i) = race_time;
end

% Compare statistical difference between conditions.
[src_2d_by_group, A_2D_by_group, B_2D_by_group, race_time] = createSRCByGroup(computed_value_dir, metadata_stk);

for i = 1:length(stimulus)
    
    race_time = length(stimulus{i});
    metadata_stk.race_time(i) = race_time;
    % ind = find(metadata_stk.condition == i_group);

end

comparison_grp_index = [1 3];
% [p_left, h_left, p_right, h_right] = compareSRCByGroup(src_2d_by_group, comparison_grp_index);
fig3 = createMatlabFigure(10, 10, 4, 'inches');clf;
comparison_grp_indices = {[1 3], [2 3], [3 4], [1 4], [1 2], [2 4]};
n = length(comparison_grp_indices);
for i = 1:n
    index = comparison_grp_indices{i};
    drawSRCByGroupComparison(src_2d_by_group, index, figure(i))
    str_1 = group_name{index(1)};
    str_2 = group_name{index(2)};
    saveas(fig,  ['output/figures/src_' str_1 '_vs_' str_2] , 'jpeg');
%     drawTRFOverSelectTimeInterval(A_2d(:,:,:,1), time_index, fs)
%      saveas(fig,  ['output/figures/src_' str_1 '_vs_' str_2] , 'jpeg');
end

group_name = {'active', 'sham', 'passive', 'counting'};
for i = 1:4
    draw2DVideo(src_2d_by_group{i}, A_2D_by_group{i}, ['output/demo_video/trf_2d_' group_name{i} '.mp4'], fs);
end

for i_group = 1:4
    [height, width,~,~] = size(src_2d_by_group{i_group});

    for i = 1:height
        for ii = 1:width
            src = sum(squeeze(src_2d_by_group{i_group}(i,ii,:,:)));
                time = race_time{i_group}';

            time_vs_src{i_group}(i,ii) = corr(src', time');
            rand_ind = randperm(length(time));

            time_vs_src_rand{i_group}(i,ii) = corr(src', time(rand_ind)');
        end
    end
    val = time_vs_src_rand{i_group};
    min_val(i_group) = min(val(:));
    max_val(i_group) = max(val(:));
end

fig_5 = figure(5)
for i_group = 1:3
    subplot(1,3,i_group)
    imagesc(time_vs_src{i_group})
    title(group_name{i_group})
    caxis([min(min_val) max(max_val)])
    if i_group == 1
        colorbar
    end
    colormap jet
end

saveas(fig_5,  'output/figures/src_race_time' , 'jpeg');

fig_6 = figure(6)
for i_group = 1:3
    subplot(1,3,i_group)
    imagesc(time_vs_src_rand{i_group})
    title(group_name{i_group})
    caxis([min(min_val) max(max_val)])
    if i_group == 1
        colorbar
    end
    colormap jet
end

saveas(fig_6,  'output/figures/src_race_time_rand' , 'jpeg');

%% Figure 4)
computed_value_dir = 'output/computed_src_values';

% Compare statistical difference between conditions
[src_2d_by_group, A_2D_by_group, B_2D_by_group] = createSRCByGroup(computed_value_dir, metadata_stk);




