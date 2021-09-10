close all; dependencies install
data_dir = ['../data/trials'];
my_data = MyData(data_dir);
session = [1 2];
metadata_stk = chooseSession(my_data.metadata, session);
is_warp_correct = true;

figure_dir = '../output/figures';
computed_value_dir = '../output/computed_src_values';

str_cond = {'Active Play', 'Sham Active', 'Passive Viewing', 'Count'};
num_conditions = numel(unique(metadata_stk.condition));
SCRN_HEIGHT= 23; SCRN_WIDTH = 40;

%% LOAD Data
[STIMULUS, EEG, EYE] = loadSuperTuxKartExperimentData(data_dir, metadata_stk);

% metadata_stk.condition = 1-Active Play, 2-Sham Play, 3-Passive Viewing, 4-Counting 
file_index = find(metadata_stk.status == 1 & (metadata_stk.condition ==1 | metadata_stk.condition ==3)); 
stim = cat(1, STIMULUS{file_index});
resp = cat(1, EEG{file_index});

%% figure 1 & 2 graphics: 
close all
draw_display_data.m

%% figure 3: Spatially-Resolved SRC with CCA spatio-temporal filters.
% Compute Spatially Resolved SRC with precomputed cca spatial weights from Ki et al 2020. EEG
% load precomuted weight
load([computed_value_dir '/src_eeg_optical_flow_kx30_ky11_cross_validated_preprint.mat'],'AReg' ,'BReg','ryy'); h = AReg; w = BReg;
[src_2d, h_2d] = compute_2d_src_with_precomputed_weights(stim, resp*w); 

% Save computed SRC.
filename = 'src_2d_precomputed_cca_eeg_filtered_only';
save([computed_value_dir '/' filename], 'src_2d', 'h_2d', 'h', 'w')

% Test for chance significance of computed SRC against surrogate EEG data (i.e. phase shuffled). These values are precomputed. 
[src_2d_phase_shuffled] = load2dPhaseShuffledSRC([computed_value_dir '\phase_randomized\' filename]);
[p_val_2d, h_val_2d, img_2d_surrogate] = computeSignificance(src_2d, src_2d_phase_shuffled);

% Draw Figure.
fig1 = createMatlabFigure(1, 15, 4, 'inches');clf;num_comp = 3;
drawSpatiallyResolvedSRCwithSpatioTemporalFilters(src_2d, num_comp, forwardModel(w, ryy), [], h_val_2d);
saveas(fig1,  [figure_dir '/' filename], 'png');

filename = 'src_2d_precomputed_cca_spatiotemporally_filtered';
val1 = load([computed_value_dir '/' filename '.mat'], 'src_2d','h','w');
src_2d = val1.src_2d; h = val1.h; w = val1.w;

% val2 = load([computed_value_dir '/phase_shuffle_precomputed_component_src'],'src_2d','h_2d');
% src_2d_phase_shuffled = val2.src_2d;
[src_2d_phase_shuffled] = load2dPhaseShuffledSRC([computed_value_dir '\phase_randomized\' filename]);
[p_val_2d, h_val_2d, img_2d_surrogate] = computeSignificance(src_2d, src_2d_phase_shuffled);
fig2 = createMatlabFigure(2, 15, 4, 'inches');clf;
drawSpatiallyResolvedSRCwithSpatioTemporalFilters(src_2d, num_comp, forwardModel(w, ryy), h, h_val_2d);
saveas(fig2,  [figure_dir '/' filename], 'png');

%% Figure 4: Spatially-Resolved SRC for individual electrodes.
close all
figure_dir = 'output/figures/2d_src_by_individual_electrode';
mkdir(figure_dir)
filename =  'src_2d_indvidual_electrodes';
load([computed_value_dir '/' filename '.mat'], 'src_2d')
% select_electrode_labels = {'Fp1', 'Fp2', 'Cz', 'O1', 'O2', 'T7', 'T8'}
% select_electrode_labels = {'F3', 'Fz', 'F4'; ...
%     'C3',  'Cz', 'C4'; ...
%     'P3', 'Pz', 'P4'; ...
%     'O1','Oz', 'O2'};

select_electrode_labels = {'F7','F3', 'Fz', 'F4', 'F8' ; ...
    'C3', 'C1',  'Cz', 'C2', 'C4'; ...
    'P7', 'P3', 'Pz', 'P4', 'P8'; ...
    'POO9h', 'O1','Oz', 'O2', 'POO10h'};
% Test for chance significance. 
[src_2d_phase_shuffled] = load2dPhaseShuffledSRC([computed_value_dir '\phase_randomized\src_2d_indvidual_electrodes']);
[p_val_2d, h_val_2d, img_2d_surrogate] = computeSignificance(src_2d, src_2d_phase_shuffled);

% fig1_a = figure(1);clf
paper_SCRN_WIDTH = 10; paper_SCRN_HEIGHT = 7.5;
fig1_a = createMatlabFigure(1, paper_SCRN_WIDTH, paper_SCRN_HEIGHT, 'inches');clf;
% draw figures individually
src_range = [0.0025 0.0325];
draw_src_by_electrode_position_separate_figures(src_2d, select_electrode_labels, h_val_2d, figure_dir, src_range);

% compute all %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = 'src_2d_indvidual_electrodes';
load([computed_value_dir '/' filename '.mat'], 'src_2d')
paper_SCRN_WIDTH = 10; paper_SCRN_HEIGHT = 7.5;
fig1_a = createMatlabFigure(1, paper_SCRN_WIDTH, paper_SCRN_HEIGHT, 'inches');clf;
src_range = [0.0025 0.0325];
electrode_indx = draw_src_by_electrode_position(src_2d, select_electrode_labels,  h_val_2d, src_range);
saveas(fig1_a,  [figure_dir '/' filename], 'png')

% compute only active %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = 'src_2d_indvidual_electrodes_active';
load([computed_value_dir '/' filename '.mat'], 'src_2d')
paper_SCRN_WIDTH = 10; paper_SCRN_HEIGHT = 7.5;
fig1_a = createMatlabFigure(1, paper_SCRN_WIDTH, paper_SCRN_HEIGHT, 'inches');clf;
electrode_indx = draw_src_by_electrode_position(src_2d, select_electrode_labels,  h_val_2d, src_range);
saveas(fig1_a,  [figure_dir '/' filename ], 'png')

% compute only passive %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = 'src_2d_indvidual_electrodes_passive';
load([computed_value_dir '/' filename '.mat'], 'src_2d')
paper_SCRN_WIDTH = 10; paper_SCRN_HEIGHT = 7.5;
fig1_a = createMatlabFigure(1, paper_SCRN_WIDTH, paper_SCRN_HEIGHT, 'inches');clf;
src_range = [0.0025 0.0325];
electrode_indx = draw_src_by_electrode_position(src_2d, select_electrode_labels,  h_val_2d, src_range);
saveas(fig1_a,  [figure_dir '/' filename], 'png')

% compute only sham %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = 'src_2d_indvidual_electrodes_sham';
load([computed_value_dir '/' filename '.mat'], 'src_2d')
paper_SCRN_WIDTH = 10; paper_SCRN_HEIGHT = 7.5;
fig1_a = createMatlabFigure(1, paper_SCRN_WIDTH, paper_SCRN_HEIGHT, 'inches');clf;
src_range = [0.0025 0.0325];
electrode_indx = draw_src_by_electrode_position(src_2d, select_electrode_labels,  h_val_2d, src_range);
saveas(fig1_a,  [figure_dir '/' filename], 'png')

% compute active vs passive significance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = 'src_2d_indvidual_electrodes';
filepath = [computed_value_dir '\' filename '_individual_race.mat'];
load(filepath, 'src_2d') 
src_2d_by_group = createSRCByGroup(src_2d, metadata_stk);

group_name = {'Active Play', 'Sham Active', 'Passive Viewing', 'Count'};
comparison_grp_indices = {[1 3], [2 3], [3 4], [1 4], [1 2], [2 4]};
index = comparison_grp_indices{2}; str_1 = group_name{index(1)}; str_2 = group_name{index(2)};

paper_SCRN_WIDTH = 10; paper_SCRN_HEIGHT = 7.5;
fig4 = createMatlabFigure(1, paper_SCRN_WIDTH, paper_SCRN_HEIGHT, 'inches');clf;
drawSRCByGroupComparisonIndividualElectrode(src_2d_by_group, index, select_electrode_labels, [str_1, str_2])
saveas(fig4, [figure_dir '/src_' str_1 '_vs_' str_2 '_' filename] , 'jpeg');

% draw scalp diagram %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loc_file = readLocationFile(LocationInfo(),'Acticap96.loc');
fig1_b = figure(2);clf
scalp_plot = ScalpPlot(loc_file);
scalp_plot.draw(zeros(96,1)); 
scalp_plot.drawTextOnElectrode([], loc_file.channelLabelsCell)
% saveas(fig1_b, [figure_dir '/2d_src_by_scalp_position_b'], 'png');

%% Figure 5: Spatially-Resolved Temporal Response Function
close all
% condition_str = '_active';
condition_str = '';

filename = ['src_2d_precomputed_cca_eeg_filtered_only' condition_str];
filename = ['src_2d_indvidual_electrodes' condition_str];
load([computed_value_dir '/' filename '.mat'], 'src_2d','h_2d');

electrode_str = 'Pz';
elec_loc_info = readLocationFile(LocationInfo(),'Acticap96.loc');
labels = elec_loc_info.channelLabelsCell;
[~, elec_ind] = ismember(electrode_str,labels);

figure_dir = 'output/figures/spatial temporal response/';
figure_name = [filename '_' electrode_str condition_str];
comp = elec_ind; fs = 30;
% comp = 1;
cross_section_index = 1;
trf = shiftdim(squeeze(h_2d(:,comp,:,:)),1);
cross_section = {[20 21] 6; [20 21] 18; [20 21] 17};

time_index = [1 3 4 5  8 9 10 11 13 15 17 19 22 25 30];
paper_SCRN_WIDTH = 40; paper_SCRN_HEIGHT = 2.5;
fig = createMatlabFigure(1, paper_SCRN_WIDTH, paper_SCRN_HEIGHT, 'inches');clf;
drawTRFOverSelectTimeInterval(trf, time_index, fs)
saveas(fig, [figure_dir '/trf_2d_component_' figure_name], 'png')

fig = createMatlabFigure(2, 6, 10, 'inches');clf;
zslice = [1 7 15 23 30];
draw3dTRFSlices(trf, zslice, cross_section(cross_section_index, :))
saveas(fig, [figure_dir '/trf_3d_component_' figure_name], 'png')
% set transparency to correlate to the data values.

line_color = [.5 .75 0 .5; 0 .5 1 .5; 1 0 .5 .5]; 
fig = createMatlabFigure(3, 6, 4, 'inches');clf;
x_pos = {[2;6;9], [23, 20 17],  [39;35;31]};
drawHorizontalTRFSlice(trf, fs, cross_section{cross_section_index, 2}, [SCRN_HEIGHT SCRN_WIDTH]*2, x_pos{cross_section_index}, line_color);
saveas(fig,  [figure_dir '/trf_horizonotal_slice_component_' figure_name], 'jpeg');

fig = createMatlabFigure(4, 6, 4, 'inches');clf;
y_pos = {[1;6;9], [1 8 15],[1;6;9]};
drawVerticalTRFSlice(trf, fs, cross_section{cross_section_index, 1}, [SCRN_HEIGHT SCRN_WIDTH]*2, y_pos{cross_section_index}, line_color);
saveas(fig,  [figure_dir '/trf_vertical_slice_component_' figure_name], 'jpeg');

line_color = line_color(:,1:3); 
fig = createMatlabFigure(5, 6, 4, 'inches');clf;
drawTRFatXYPos(trf, x_pos{cross_section_index}, repmat(cross_section{1,2},1,3), line_color)
saveas(fig,  [figure_dir '/trf_set_points_horizontal_cross_section_indexonent_' figure_name], 'jpeg');
 
fig = createMatlabFigure(6, 6, 4, 'inches');clf;
drawTRFatXYPos(trf, repmat(20,1,3), abs(SCRN_HEIGHT-y_pos{cross_section_index}), line_color)
saveas(fig,  [figure_dir '/trf_set_points_vertical_component_' figure_name], 'jpeg');

%% Figure 6: Spatially Resolved SRC EEG vs EYE.
draw2dSRCFigure(src_2d, 3);

%% Figure 7: Spatially Resolved SRC EEG - Active vs Passive
close all
computed_val_type = {'src_2d_precomputed_cca_eeg_filtered_only', ...
                    'src_2d_precomputed_cca_spatiotemporally_filtered',...
                    'src_2d_indvidual_electrodes',...
                    'src_2d_canonocical_components_for_individual_pixel_region'};

filename = computed_val_type{1};
filepath = [computed_value_dir '\' filename '_individual_race.mat'];
load(filepath, 'src_2d') 
src_2d_by_group = createSRCByGroup(src_2d(:,:,1:3,:), metadata_stk);

%src_2d_by_group = averageRacesByIndivdiualSubjects(src_2d(:,:,1:3,:), metadata_stk);

group_name = {'Active Play', 'Sham Active', 'Passive Viewing', 'Count'};
comparison_grp_indices = {[1 3], [2 3], [3 4], [1 4], [1 2], [2 4]};

index = comparison_grp_indices{5}; str_1 = group_name{index(1)}; str_2 = group_name{index(2)};
fig4 = createMatlabFigure(1, 10, 4, 'inches');clf;
drawSRCByGroupComparison(src_2d_by_group, index, group_name(index))
figure_name = [figure_dir '/src_' str_1 '_vs_' str_2 '_' filename] ;
saveas(fig4, figure_name, 'jpeg');

index = find(metadata_stk.status == 1 & (metadata_stk.condition == 1 | metadata_stk.condition ==3));
n = length(unique(metadata_stk.subject_id(index,:)));

%% Figure 7: Spatially Resolved SRC Eye and Gaze - Active vs Passive
close all
computed_val_type = {
    'src-eye_2d_canonocical_components_for_individual_pixel_region_velocity_magnitude', ...
    'src-eye_2d_canonocical_components_for_individual_pixel_region_velocity_vector_xy', ...
    'eye_gaze_average_2d'};

filename = computed_val_type{1};
filepath = [computed_value_dir '\' filename '_individual_race.mat'];

index = find((metadata_stk.eye_data_status == 1));
metadata_eye = metadata_stk(index,:);
load(filepath, 'src_2d') 

src_2d_by_group = averageRacesByIndivdiualSubjects(src_2d, metadata_eye);
% src_2d_by_group = createSRCByGroup(src_2d(:,:,1:3,:), metadata_eye);
group_name = {'Active Play', 'Sham Active', 'Passive Viewing', 'Count'};
grp_index = [1 3]; str_1 = group_name{1}; str_2 = group_name{2};

fig4 = createMatlabFigure(1, 10, 4, 'inches');clf;
if strcmp(filename,computed_val_type{3})
    ref_SCRN_HEIGHT = 720;ref_SCRN_WIDTH = 1280;
    drawSRCEyeByGroupComparison(src_2d_by_group, grp_index, group_name(grp_index),ref_SCRN_WIDTH, ref_SCRN_HEIGHT)
else
    drawSRCByGroupComparison(src_2d_by_group, grp_index, group_name(grp_index))
end
saveas(fig4, [figure_dir '/src_' str_1 '_vs_' str_2 '_' filename] , 'jpeg');



%% Figure 7 c: EYE Movement Velocity Active vs Passive Histogram 
iter = 1;x_vel = {}; y_vel = {}; vel_magnitude = {}; eye=[];

subj_index = find(metadata_stk.eye_data_status == 1 & (metadata_stk.condition ==1 | metadata_stk.condition ==3));
n = length(unique(metadata_stk.subject_id(subj_index,:)));

subject_id = find(subj_index);
for i_cond = [1 3]
    file_index = find((metadata_stk.eye_data_status == 1) & (metadata_stk.condition == i_cond));
    n_files(i_cond) = length(file_index);
    
    for i = 1:length(file_index)
        if sum(metadata_stk.subject_id(i) == subject_id)
            x = EYE{file_index(i)};
            eye = cat(1, eye, x.data);
        end
    end
    eye(isnan(eye)) = nan;
    x_pos = eye(:,7);
    y_pos = eye(:,8);
    [x_vel{iter}, y_vel{iter}, vel_magnitude{iter}] = computeEyeVelocity(eye(:,7), eye(:,8));
    iter = iter + 1;
end

str = {'x vel','y vel','vel magnitude'};
data = {x_vel,y_vel,vel_magnitude};
for i = 1:3
    % create x y histogram for eye movement
    fig4_a = createMatlabFigure(i, 7, 4, 'inches');clf;
    clf; hold on
    x1 = data{i}{1};
    x2 = data{i}{2};
%     n = min(length(x1),length(x2));
%     d = pdist2(x1(1:n)', x2(1:n)');
%     x = [x1(1:n), x2(1:n)];
%    [p, h] = kruskalwallis(x);
%     med_1 = median(x1);
%     med_2 = median(x2);
    h2 = histogram(x2);
    h1 = histogram(x1,'FaceAlpha',.45);
    h1.Normalization = 'probability';
    h1.BinSCRN_WIDTH = .025;
    h2.Normalization = 'probability';
    h2.BinSCRN_WIDTH = .025;

    % [p, h] = ranksum(rmoutliers(x1,'mean'),rmoutliers(x2,'mean'),'tail','right')
    
    % line(5.12*[1 1],ylim)
    title(str{i},'FontSize', 14)
    legend([h1, h2], {'active', 'passive'},'FontSize', 14); ylabel('Normalized Frequency','FontSize', 14)
    y_lim = ylim; y_min = y_lim(1); y_max = y_lim(2);
    set(gca,'YTick', [y_min, mean(ylim), y_max]);
    xlim([-1.5 1.5]);
    saveas(fig4_a,  [figure_dir '/hist_eye_' str{i} '_active_vs_passive'], 'jpeg');
end

%% Figure 7C: EYE Movement Velocity Active vs Passive Histogram Individual comparison
iter = 1;vel_x = {}; vel_y={};eye=[];
vel_mag_median =[];
vel_magnitude_all = {};
for i_cond = [1 3]
    file_index = (metadata_stk.eye_data_status == 1) & (metadata_stk.condition == i_cond);
    subject_id = unique(metadata_stk.subject_id(find(file_index)));
    for i = 1:length(subject_id)
        subj_ind = subject_id(i);
        ind = find(file_index & (metadata_stk.subject_id == subj_ind));
        eye=[];
        for ii = 1:length(ind)
            x = EYE{ind(ii)};
            eye = cat(1, eye, x.data);
        end
        eye(isnan(eye)) = nan;
        x_pos = eye(:,7);
        y_pos = eye(:,8);
        [x_vel, y_vel, vel_magnitude] = computeEyeVelocity(eye(:,7), eye(:,8));
        vel_mag_all{subj_ind,iter} = vel_magnitude;
        vel_mag_median{subj_ind,iter} = median(vel_magnitude);        
    end
%     vel_magnitude_all{iter} = vel_mag_median;
    iter = iter + 1;    
end

% assign group if both conditions exists
iter = 1;vel_med_all = [];    
vel_magnitude_1 = [];
vel_magnitude_2 = [];
for i = 1:size(vel_mag_median,1)
    vel_median = cell2mat(vel_mag_median(i,:));
    if length(vel_median) == 2
        vel_med_all(iter,:) = vel_median;
        vel_magnitude_1 = [vel_magnitude_1; cell2mat(vel_mag_all(i,1))];
        vel_magnitude_2 = [vel_magnitude_2; cell2mat(vel_mag_all(i,2))];
        paired_index(i) = 1;
        iter = iter + 1;
    else
        paired_index(i) = 0;
    end
end
group_1 = vel_med_all(:,1);
group_2 = vel_med_all(:,2);
[p, h, STATS] = signrank(group_1, group_2);

str = {'x vel','y vel','vel magnitude'}
data = {x_vel,y_vel,vel_magnitude};
% create x y histogram for eye movement
fig4_a = createMatlabFigure(i, 7, 3, 'inches');clf
subplot(1,2,1); hold on

x1 = vel_magnitude_1;
x2 = vel_magnitude_2;

h2 = histogram(x2);
h1 = histogram(x1,'FaceAlpha',.45);
h1.Normalization = 'probability';
h2.Normalization = 'probability';
h1.BinSCRN_WIDTH = .025;
h2.BinSCRN_WIDTH = .025;

% line(5.12*[1 1],ylim)
% title(str{3},'FontSize', 14)
grp_str =  {'active', 'passive'};
legend([h1, h2], grp_str,'FontSize', 14); ylabel('Normalized Frequency','FontSize', 14)
y_lim = ylim; y_min = y_lim(1); y_max = y_lim(2);
set(gca,'YTick', [y_min, mean(ylim), y_max], 'FontSize', 12);
% ylim([0 .13]);
xlim([0 1.5]);
xlabel('Gaze Velocity','FontSize', 14)
% saveas(fig4_a,  [figure_dir '/hist_eye_' str{3} '_active_vs_passive'], 'jpeg');

% fig = createMatlabFigure(figure_num, paper_SCRN_WIDTH, paper_SCRN_HEIGHT, 'inches');clf;
% bottom = .8; top = 0; left = .095; right = .3;

subplot(1,2,2);hold on;
n_subjects = length(vel_med_all);
offset =  randn(n_subjects,1)*.065;
fig_config = FigureConfig();
x_pos = [1,3];
y_pos = 0:.2:.7;
for i = 1:2
    x = x_pos(i)  + offset;
    bar(x_pos(i), median(vel_med_all(:,i)), .6, 'FaceColor', [1 1 1], 'EdgeColor', fig_config.barColor{i}, 'LineSCRN_WIDTH', 2);
    x_all(:,i) = x;
end

for i = 1:2
    x = x_pos(i)  + offset;
    x_all(:,i) = x;
        plot(x, vel_med_all(:, i)', '.', 'LineSCRN_WIDTH',2, ...
        'MarkerFaceColor',  fig_config.barColor{i}, ...
        'MarkerEdgeColor',fig_config.barColor{i}, 'MarkerSize', 12);
%         errorbar(x_pos(i), sum(rhoMeanAll(i,:)), semAll(i), ...
%             '-',  'Color', 'k' , 'MarkerSize', 5,'LineSCRN_WIDTH',2)
%     plot(x_all(i), vel_med_all(i,:), .6, 'FaceColor', [1 1 1], 'EdgeColor', fig_config.barColor{i}, 'LineSCRN_WIDTH', 2);
end

set(gca, 'XTick', x_pos, 'XTickLabel', fig_config.conditionStrXTick(x_pos), 'FontName', 'Arial', 'FontSize', 12, 'TickLabelInterpreter', 'tex')
set(gca, 'YTick', y_pos, 'YTickLabel', y_pos, 'FontName', 'Arial', 'FontSize', 12)
ylabel('Median Gaze Velocity', 'FontSize', 14)
% saveas(fig4_a,  [figure_dir '/hist_eye_' str{3} '_active_vs_passive'], 'jpeg');
% groups = {[x_pos(1) x_pos(2)], [x_pos(1) x_pos(3)], [x_pos(2) x_pos(3)]};
% sigstar(groups, pvalAll, 0, false);
saveas(fig4_a,  [figure_dir '/gaze_velocity_active_vs_passive'], 'jpeg');

%% Figure 8 - Active vs Passive Timecourse Comparison
close all
select_electrode_labels = {'Fz', 'Cz', 'Pz', 'Oz'};
n = length(select_electrode_labels); 
elec_loc_info = readLocationFile(LocationInfo(),'Acticap96.loc');
labels = elec_loc_info.channelLabelsCell;
for i = 1:n
    [~, elec_ind(i)] = ismember(select_electrode_labels(i),labels);
end
condition_str = 'active';
filename = ['src_2d_indvidual_electrodes_' condition_str];
load([computed_value_dir '/' filename '.mat'], 'src_2d','h_2d','w');
figure_dir_ = [figure_dir '/' condition_str];
mkdir(figure_dir_)
ind = 2;
comp = 2;
electrode_label = select_electrode_labels{ind};
fs = 30;
trf = shiftdim(squeeze(h_2d(:,elec_ind(ind),:,:)),1);
cross_section = {[20 21] 6; [20 21] 18; [20 21] 17};

time_index = [1 3 4 5  8 9 10 11 13 15 17 19 22 25 30];
paper_SCRN_WIDTH = 40; paper_SCRN_HEIGHT = 2.5;
fig = createMatlabFigure(1, paper_SCRN_WIDTH, paper_SCRN_HEIGHT, 'inches');clf;
drawTRFOverSelectTimeInterval(trf, time_index, fs)
saveas(fig, [figure_dir_ '/trf_2d_component_' num2str(comp) '_' condition_str '_' electrode_label], 'png')

fig = createMatlabFigure(2, 6, 10, 'inches');clf;
zslice = [1 7  15 23 30];
draw3dTRFSlices(trf, zslice, cross_section(comp, :))
saveas(fig, [figure_dir_ '/trf_3d_component_' num2str(comp) '_' condition_str '_' electrode_label], 'png')
% set transparency to correlate to the data values.

line_color = [.5 .75 0 .5; 0 .5 1 .5; 1 0 .5 .5]; 
fig = createMatlabFigure(3, 6, 4, 'inches');clf;
x_pos = {[39;35;31], [28, 20 12]};
drawHorizontalTRFSlice(trf, fs, cross_section{comp, 2}, [SCRN_HEIGHT SCRN_WIDTH]*2, x_pos{comp}, line_color);
saveas(fig,  [figure_dir_ '/trf_horizonotal_slice_component_' num2str(comp) '_' condition_str '_' electrode_label], 'jpeg');

fig = createMatlabFigure(4, 6, 4, 'inches');clf;
y_pos = {[1;6;9], [1 8 15]};
drawVerticalTRFSlice(trf, fs, cross_section{comp, 1}, [SCRN_HEIGHT SCRN_WIDTH]*2, y_pos{comp}, line_color);
saveas(fig,  [figure_dir_ '/trf_vertical_slice_component_' num2str(comp) '_' condition_str '_' electrode_label], 'jpeg');

line_color = line_color(:,1:3); 
fig = createMatlabFigure(5, 6, 4, 'inches');clf;
drawTRFatXYPos(trf, x_pos{comp}, repmat(cross_section{1,2},1,3), line_color)
saveas(fig,  [figure_dir_ '/trf_set_points_horizontal_component_' num2str(comp) '_' condition_str '_' electrode_label], 'jpeg');
 
fig = createMatlabFigure(6, 6, 4, 'inches');clf;
drawTRFatXYPos(trf, repmat(20,1,3), abs(SCRN_HEIGHT-y_pos{comp}), line_color)
saveas(fig,  [figure_dir_ '/trf_set_points_vertical_component_' num2str(comp)  '_' condition_str '_' electrode_label], 'jpeg');

