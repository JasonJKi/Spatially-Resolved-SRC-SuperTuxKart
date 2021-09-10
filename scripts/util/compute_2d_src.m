close all; dependencies install
my_data = MyData('E:/Active-Passive-SRC-2D/data');

session = [1 2];
metadata_stk = chooseSession(my_data.metadata, session);
is_warp_correct = true;

figure_dir = 'output/figures';
computed_value_dir = 'output/computed_src_values';

str_cond = {'Active Play', 'Sham Active', 'Passive Viewing', 'Count'};
num_conditions = numel(unique(metadata_stk.condition));
HEIGHT= 23; WIDTH = 40;

%% LOAD Data
file_index = find(metadata_stk.status == 1 & (metadata_stk.condition ==1 | metadata_stk.condition ==3));
[STIMULUS, EEG, EYE] = loadSuperTuxKartData(my_data, metadata_stk, is_warp_correct);

figure_dir = 'output/figures';
computed_value_dir = 'output/computed_src_values';

% cond_index = find(metadata_stk.condition == i_cond);
str_cond = {'Active Play', 'Sham Active', 'Passive Viewing', 'Count'};
num_conditions = numel(unique(metadata_stk.condition));
[~, HEIGHT, width] = size(STIMULUS{1});

% group
for i = 1:height(metadata_stk)
    metadata_stk.race_time(i) = length(STIMULUS{i})/30;
end

%% 1) Compute SRC-EEG over all conditions over individual pixel using CCA. (Active Play and Passive Viewing groups Only)
% file_index = 1:round(length(STIMULUS)/2);
file_index = find(metadata_stk.status == 1 & (metadata_stk.condition ==1 | metadata_stk.condition ==3));
rand_ind = randperm(length(file_index));
index = file_index(rand_ind(1:100));

stim = cat(1, STIMULUS{file_index});
resp = cat(1, EEG{file_index});

fs = 30; kx = 30; ky = 11; % cca parameters
computed_value_dir = 'output/computed_src_values';
[src_2d, h_2d, w_2d] = compute2dSRCwithCCA(stim, resp, kx, ky, fs);
draw2dSRCFigure(src_2d, 3);

filename = 'src_2d_canonocical_components_for_individual_pixel_region';
save([computed_value_dir '/' filename '.mat'], 'src_2d', 'h_2d', 'w_2d');

%% 2) Compute Spatially Resolved SRC with precomputed cca spatial weights from Ki et al 2020. EEG
% load precomuted weight
load('./output/computed_src_values/src_eeg_optical_flow_kx30_ky11_cross_validated_preprint.mat','AReg' ,'BReg','ryy'); h = AReg; w = BReg;
file_index = find(metadata_stk.status == 1 & (metadata_stk.condition ==1 | metadata_stk.condition ==3));
file_index = find(metadata_stk.status == 1 & (metadata_stk.condition ==3));
file_index = find(metadata_stk.status == 1 & (metadata_stk.condition ==1));

rand_ind = randperm(length(file_index));
index = file_index(rand_ind(1:end));

stim = cat(1, STIMULUS{file_index});
resp = cat(1, EEG{file_index});

[src_2d, h_2d] = compute_2d_src_with_precomputed_weights(stim, resp*w); 
filename = 'src_2d_precomputed_cca_eeg_filtered_active.mat';
save([computed_value_dir '/' filename], 'src_2d', 'h_2d', 'h', 'w')

filename = 'src_2d_precomputed_cca_spatiotemporally_filtered_passive.mat';
src_2d = compute2DSRC(stim, resp, h, w, false);
save([computed_value_dir '/' filename], 'src_2d','h','w')

%% 3) Compute Spatially-Resolved SRC for individual electrodes using linear regression. EEG
file_index = find(metadata_stk.status == 1 & (metadata_stk.condition ==1 | metadata_stk.condition ==3));
file_index = find(metadata_stk.status == 1 & (metadata_stk.condition ==3));
file_index = find(metadata_stk.status == 1 & (metadata_stk.condition ==2));

stim = cat(1, STIMULUS{file_index});
resp = cat(1, EEG{file_index});
filename =  'src_2d_indvidual_electrodes_sham';
[src_2d, h_2d] = compute_2d_src_by_trf(stim, resp); w = [];
save([computed_value_dir '/' filename '.mat'], 'h_2d', 'src_2d', 'w')

%% 4) Compute Spatially SRC on Phase Randomized EEG to test chance significance. EEG
% use precomputed weights.
computed_val_type = {'src_2d_precomputed_cca_eeg_filtered_only', ...
                    'src_2d_precomputed_cca_spatiotemporally_filtered',...
                    'src_2d_indvidual_electrodes',...
                    'src_2d_canonocical_components_for_individual_pixel_region'};

file_index = find(metadata_stk.status == 1 & (metadata_stk.condition ==1 | metadata_stk.condition ==3));
num_shuffle = 50;
for i_shuffle = 1:num_shuffle
        
    rand_ind = randperm(length(file_index));
    index = file_index(rand_ind(1:100));
    
    stim = cat(1, STIMULUS{index});
    resp = cat(1, EEG{index});
    resp = randomizePhase(resp); % phase ranndomly shuffled.    
    
    for i = 3
        
        filename = computed_val_type{i};
        load([computed_value_dir '/' filename '.mat'], 'src_2d', 'h_2d', 'w_2d', 'h', 'w')

        if i == 1
            src_2d(:,:,:,ii) = compute2DSRC(stim, resp, h_2d, w, [1 0]);
        elseif i == 2
            src_2d(:,:,:,ii) = compute2DSRC(stim, resp, h, w, [0 0]);
        elseif i == 3
            src_2d(:,:,:,ii) = compute2DSRC(stim, resp, h, ones(96,1), [1 0]);
        elseif i == 4
            src_2d(:,:,:,ii) = compute2DSRC(stim, resp, h_2d, w_2d, [1 1]);
        end
        
        out_dir = [computed_value_dir '\phase_randomized\' filename];
        mkdir(out_dir);
        dir_list = dir(out_dir);
        n_files = length(dir_list) - 1;
        filepath = [out_dir '\src_2d_random_phase_' num2str(n_files) '.mat'];
        save(filepath, 'src_2d')
    end
    
end

% draw to test to see significance was correctly computed.
filename = computed_val_type{2};
load([computed_value_dir '/' filename '.mat'], 'src_2d', 'h_2d', 'w_2d', 'h', 'w')
[src_2d_phase_shuffled] = load2dPhaseShuffledSRC([computed_value_dir '\phase_randomized\' filename]);
[p_val_2d, h_val_2d, img_2d_surrogate] = computeSignificance(src_2d, src_2d_phase_shuffled);
num_component = 3;
draw2dSRCFigureWithSignificance(src_2d, h_val_2d, num_component)
draw2dSRCFigure(single(p_val_2d),3);

%% 5) Compute Spatially Resolved CCA over individual pixel by conditions. EEG
computed_val_type = {'src_2d_precomputed_cca_eeg_filtered_only', ...
                    'src_2d_precomputed_cca_spatiotemporally_filtered',...
                    'src_2d_indvidual_electrodes',...
                    'src_2d_canonocical_components_for_individual_pixel_region'};
                
fs = 30; kx = fs; ky = 11; % cca parameters
num_conditions = numel(unique(metadata_stk.condition));
computed_value_dir = 'output/computed_src_values';
condition_str =  {'Active Play', 'Sham Active', 'Passive Viewing', 'Count'};

for i_cond = 1:num_conditions
    cond_index = find(metadata_stk.condition == i_cond);
    stim = cat(1, STIMULUS{cond_index});
    resp = cat(1, EEG{cond_index});
    [src_2d, A_2d, B_2d] = compute2dSRCwithCCA(stim, resp, kx, ky, fs);    
    save([computed_value_dir '/src_2d_' condition_str{i_cond} '.mat'], 'src_2d', 'A_2d', 'B_2d')
end

%% 6) Compute Spatially Resolved SRC for individual subject using Precomputed Weights EEG
computed_val_type = {'src_2d_precomputed_cca_eeg_filtered_only', ...
                    'src_2d_precomputed_cca_spatiotemporally_filtered',...
                    'src_2d_indvidual_electrodes',...
                    'src_2d_canonocical_components_for_individual_pixel_region'};
                
group_indices = 1:length(STIMULUS);
fs = 30; kx = 30; ky = 11; % cca parameters
for i = [1 3];
    
    filename = computed_val_type{i};
    load([computed_value_dir '/' filename '.mat'], 'src_2d', 'h_2d', 'w_2d', 'h', 'w')
    src_2d = [];
    for ii = 1:length(group_indices)
        grp_index = group_indices(ii);
        stim = cat(3, STIMULUS{grp_index});
        resp = cat(3, EEG{grp_index});
        
        if i == 1
            src_2d(:,:,:,ii) = compute2DSRC(stim, resp, h_2d, w, [1 0]);
        elseif i == 2
            src_2d(:,:,:,ii) = compute2DSRC(stim, resp, h, w, [0 0]);
        elseif i == 3
            src_2d(:,:,:,ii) = compute2DSRC(stim, resp, h_2d, w, [1 0]);
        elseif i == 4
            src_2d(:,:,:,ii) = compute2DSRC(stim, resp, h_2d, w_2d, [1 1]);
        end
        disp(ii)
    end
    
    filepath = [computed_value_dir '\' filename '_individual_race.mat'];
    save(filepath, 'src_2d')

end

%% EYE GAZE
%% Compute SRC-EYE over all conditions over individual pixel using CCA. (Active Play and Passive Viewing groups Only) 
file_index = find(metadata_stk.eye_data_status == 1 & (metadata_stk.condition ==1 | metadata_stk.condition ==3));
% rand_ind = randperm(length(file_index));
% index = file_index(rand_ind(1:100));

stim = cat(1, STIMULUS{file_index});
eye = cat(1, EYE{file_index});
eye = cat(1, eye(:).data);

[x_vel, y_vel, vel_magnitude] = computeEyeVelocity(eye(:,7), eye(:,8));
resp = vel_magnitude;

kx = 30; ky = size(resp,2); fs = 30;
[src_2d, h_2d, w_2d] = compute2dSRCwithCCA(stim, resp, kx, ky, fs);

filename = 'src-eye_2d_canonocical_components_for_individual_pixel_region_velocity_magnitude';
computed_val_path = [computed_value_dir '/' filename '.mat'];
save(computed_val_path, 'src_2d', 'h_2d', 'w_2d')
draw2dSRCFigure(src_2d, 1);

resp = [x_vel y_vel];
kx = 30; ky = size(resp,2); fs = 30;
[src_2d, h_2d, w_2d] = compute2dSRCwithCCA(stim, resp, kx, ky, fs);

filename = 'src-eye_2d_canonocical_components_for_individual_pixel_region_velocity_vector_xy';
computed_val_path = [computed_value_dir '/' filename '.mat'];
save(computed_val_path, 'src_2d', 'h_src_2d', 'w_src_2d')
draw2dSRCFigure(src_2d, 1);

%% 1) Compute Spatially Resolved SRC-EYE for individual subject using Precomputed Weights
computed_val_type = {
    'src-eye_2d_canonocical_components_for_individual_pixel_region_velocity_magnitude', ...
    'src-eye_2d_canonocical_components_for_individual_pixel_region_velocity_vector_xy', ...
    'eye_gaze_average_2d'};
                
file_index = find(metadata_stk.eye_data_status == 1);

for i = 1:3
    
    filename = computed_val_type{i};
    src_2d = [];
    for ii = 1:length(file_index)  
        ind = file_index(ii);
        stim = STIMULUS{ind};
        eye = EYE{ind}.data;
        eye(isnan(eye)) = 0;
        
        if i == 1
            load([computed_value_dir '/' filename '.mat'], 'h_2d', 'w_2d')
            [x_vel, y_vel, vel_magnitude] = computeEyeVelocity(eye(:,7), eye(:,8));
            resp = vel_magnitude;
            src_2d(:,:,:,ii) = compute2DSRC(stim, resp, h_2d, w_2d, true);
        elseif i == 2
            load([computed_value_dir '/' filename '.mat'], 'h_2d', 'w_2d')
            [x_vel, y_vel, vel_magnitude] = computeEyeVelocity(eye(:,7), eye(:,8));
            resp = [x_vel, y_vel];
            src_2d(:,:,:,ii) = compute2DSRC(stim, resp, h_2d, w_2d, true);
        else
            ref_height = 720;ref_width = 1280;
            x_pos = eye(:,7)*ref_width;
            y_pos = eye(:,8)*ref_height;
            src_2d(:,:,:,ii)  = eyetracking_heatmap(x_pos,y_pos, ref_width, ref_height, 40);
        end
        disp(ii)
    end
    filepath = [computed_value_dir '\' filename '_individual_race.mat'];
    save(filepath, 'src_2d')
end

%% Compare statistical difference between conditions.
% computed_val_name = 'global_optic_flow'; 
% computed_val_name = 'individual_pixel_region';
group_name = {'Active Play', 'Sham Active', 'Passive Viewing', 'Count'};
computed_val_name ='individual_pixel_region_by_condition';
load([computed_value_dir '/src_indvidual_subject_' computed_val_name '.mat'], 'src_2d') 
src_2d_by_group = createSRCByGroup(src_2d(:,:,1:3,:), metadata_stk);

% draw condition comparison figure
fig4 = createMatlabFigure(1, 10, 4, 'inches');clf;
comparison_grp_indices = {[1 3], [2 3], [3 4], [1 4], [1 2], [2 4]};
%n = length(comparison_grp_indices);
index = comparison_grp_indices{1};
str_1 = group_name{index(1)};
str_2 = group_name{index(2)};
drawSRCByGroupComparison(src_2d_by_group, index, group_name(index))

saveas(fig4, [figure_dir '/src_' str_1 '_vs_' str_2] , 'jpeg');

%% Eye gaze
compare_eye_gaze()

%% compute stimulus-eye correlation
label = {'x_vel','y_vel','x_y_vel','vel_magnitude','vel_mag_xy_combined'};
data = {vel_x, vel_y, vel, vel_mag, [vel vel_mag]};
for i = 1:5
    % src eye x and y
    resp = data{i};
    ky = size(resp,2);
    [sec_2d, A_sec_2d, B_sec_2d] = compute2dSRC(stim, resp, 30, ky, 30);
    computed_val_path = [computed_value_dir '/sec_2d_' label{i} '.mat'];
    save(computed_val_path, 'sec_2d', 'A_sec_2d', 'B_sec_2d')
    
    % draw 2d src-eye
    % load(computed_val_path, 'sec_2d', 'A_sec_2d', 'B_sec_2d')
    fig4_a = createMatlabFigure(2, 6, 3, 'inches');clf;
    draw2dSRCFigure(sum(sec_2d,3), stim, 1);
    saveas(fig4_a,  [figure_dir '/stimulus_eye_corr_2d_' label{i}], 'png');
end

%% compare active vs passive SRC EEG & Eye, and Eye position
fs = 30;
kx = fs; ky = 1; % cca parameters
num_conditions = numel(unique(metadata_stk.condition));
computed_value_dir = 'output/computed_src_values';
condition_str = {'Active Play', 'Sham Active', 'Passive Viewing', 'Count'};
% performance_group = {'fast', 'slow'}
group_name = condition_str;
cond_index = [1 3];
label = {'x_vel','y_vel','x_y_vel','vel_mag_xy_combined','vel_magnitude','eeg','eye_gaze'};
% comparison_grp_indices = {[1 3], [2 3], [3 4], [1 4], [1 2], [2 4]};

for j = [6]
    resp_type = label{j};
    if strcmp(resp_type,'eeg')
        load('./output/computed_src_values/src_eeg_optical_flow_kx30_ky11_cross_validated_preprint.mat','BReg','B','ryy','AReg')
        load([computed_value_dir '/src_2d_all.mat'], 'A_2d', 'B_2d')  
        h = A_2d; w = B_2d;
    elseif strcmp(resp_type,'eye_gaze')
        ref_height = 720;
        ref_width = 1280;
    else
        load([computed_value_dir '/sec_2d_' resp_type '.mat'], 'A_sec_2d', 'B_sec_2d')
        h = A_sec_2d; w = B_sec_2d;
    end
    
    src_by_group = [];
    % compare eye
    for i = 1:length(cond_index)
        if strcmp(resp_type,'eeg')
            index = find((metadata_stk.condition ==  cond_index(i)));
        else
            index = find((metadata_stk.eye_data_status == 1) & metadata_stk.condition ==  cond_index(i));
        end
            src_2d =[];
        for ii = 1:length(index)
            id = index(ii);
            stim = STIMULUS{id};
            eye = EYE{id}.data;

            if strcmp(resp_type,'eeg')
                resp = EEG{id};
                src_2d(:,:,:,ii) = compute2DSRC(stim, resp, h, w, coeff_is_2d);
            elseif strcmp(resp_type,'eye_gaze')
                x_pos = eye(:,7)*ref_width;
                y_pos = eye(:,8)*ref_height;
                src_2d(:,:,:,ii)  = eyetracking_heatmap(x_pos,y_pos, ref_width, ref_height, 50);
            else
                [x_vel, y_vel, vel_magnitude] = computeEyeVelocity( eye(:,7), eye(:,8));
                x_y_vel = [x_vel y_vel];
                vel_mag_xy_combined = [x_vel y_vel vel_magnitude];
                eval(['resp = ' resp_type ';']);
                src_2d(:,:,:,ii) = compute2DSRC(stim, resp, h, w);
            end            
            disp(ii);
        end
        src_by_group{i} = src_2d;
    end
    str_1 = group_name{cond_index(1)};
    str_2 = group_name{cond_index(2)};
    val_name = ['/src-' resp_type '-' str_1 '_vs_' str_2];
    save([computed_value_dir val_name], 'src_by_group')
end

%% draw active vs passive src-EEG & eye and eye gaze position
cond_index = [1 3];
label = {'x_vel','y_vel','x_y_vel','vel_mag_xy_combined','vel_magnitude','eeg','eye_gaze'};
for  j = [5]
    
    resp_type = label{j};
    str_1 = group_name{cond_index(1)};
    str_2 = group_name{cond_index(2)};
    val_name = ['/src-' resp_type '-' str_1 '_vs_' str_2];

    load([computed_value_dir val_name], 'src_by_group')
   
    % draw figure
    fig = createMatlabFigure(j, 10, 4, 'inches');clf;
    if strcmp(resp_type, 'eye_gaze')
       drawSRCEyeByGroupComparison(src_by_group, [1 2], {str_1, str_2},ref_width, ref_height)
    else
        drawSRCByGroupComparison(src_by_group, [1 2], {str_1, str_2})
%         drawSRCByGroupComparisonNormalized(src_by_group, [1 2], {str_1, str_2})
    end
   
    val_name = ['/src-' resp_type '-' str_1 '_vs_' str_2];
    saveas(fig, [figure_dir val_name] , 'jpeg');
end

%%
index = find((metadata_stk.eye_data_status == 1) & ((metadata_stk.condition == 1) | (metadata_stk.condition == 3)));
n_runs = length(index);
for i = 1:n_runs
    ind = index(i);
    eeg = EEG{ind};
    stim = STIMULUS{ind};
    eye = EYE{ind}.data;    
        
    x_pos = eye(:,7);
    y_pos = eye(:,8);
    vel_x = [0; diff(x_pos)];
    vel_y = [0; diff(y_pos)];
    eye_vel = [vel_x, vel_y];
    eye_vel_mag = sqrt(vel_x.^2 +vel_y.^2);
    disp(i)
    [n,HEIGHT, width] = size(stim);
    for i_h = 1:HEIGHT
        for i_w = 1:width              
            
            x = videoToeplitz(stim(:,i_h,i_w),30);
%             y = eeg;
%             
%             % compute 2d src
%             h = squeeze(A_src_2d(i_h,i_w,:,:)); w = squeeze(B_src_2d(i_h,i_w,:,:));
%             a = x*h; b = y*w;            
%             num_comp = size(h,2);
%             for ii = 1:num_comp
%                 rho_src_2d_all(i_h,i_w,ii,i) = corr(a(:,ii),b(:,ii));
%             end
            
            % compute 2d erc
            y = eye_vel_mag;
            h = squeeze(A_sec_2d(i_h,i_w,:,:)); w = squeeze(B_sec_2d(i_h,i_w,:,:));
            a = x*h; b = y*w;            
            num_comp = size(h,2);
            for ii = 1:num_comp
                rho_sec_2d_all(i_h,i_w,ii,i) = corr(a(:,ii),b(:,ii));
            end
        end
    end      
end
save([computed_value_dir '/individual_subject_src_sec.mat'], 'rho_sec_2d_all', 'rho_src_2d_all')

load([computed_value_dir '/individual_subject_src_sec.mat'], 'rho_sec_2d_all', 'rho_src_2d_all')
for i = 1:n_runs
    img1 = squeeze(sum(rho_sec_2d_all(i,:,:,:),4));
    imagesc(img1)
    pause()
end

img1 = squeeze(mean(sum(rho_sec_2d_all,4),3));
subplot(1,2,1); imagesc(img1)
img2 = squeeze(mean(sum(rho_src_2d_all,4),3));
subplot(1,2,2); imagesc(img2)

src_2d_by_group = {squeeze(rho_sec_2d_all(:,:,1,:)), squeeze(rho_src_2d_all(:,:,1,:))};
drawSRCByGroupComparison(src_2d_by_group, [1 2], {'sec','src'})

%% compute eye-response correlation
x = tplitz(zscore(vel')',30);
cca_estimator = CCA(Params(30,  10));
cca_estimator.fit(x, resp);
h_erc = cca_estimator.A;
w_erc = cca_estimator.B;

fig1 = figure(1);clf
draw_src_components(h_erc, w_erc, cca_estimator.covMatrix.ryy)
saveas(gcf,  [figure_dir '/eye_response_corr'], 'jpeg');

x = videoToeplitz(stim,30);
cca_estimator = CCA(Params(30,  10));
cca_estimator.fit(x, resp);
h_src = cca_estimator.A;
w_src = cca_estimator.B;

fig1 = figure(2);clf
draw_src_components(h_src, w_src, cca_estimator.covMatrix.ryy)
saveas(gcf,  [figure_dir '/stimulus_response_corr'], 'jpeg');

index = find((metadata_stk.eye_data_status == 1) & ((metadata_stk.condition == 1) | (metadata_stk.condition == 3)));
n_runs = length(index);
for i = 1:n_runs
    ind = index(i);
    eeg = EEG{ind};
    stim = STIMULUS{ind};
    eye = EYE{ind}.data;
    
    y = eeg;
    x = videoToeplitz(stim,30);    
    a=x*h_src; b=y*w_src;
    
    num_comp = size(h_src,2);    
    for ii = 1:num_comp
        rho_src(i,ii) = corr(a(:,ii),b(:,ii)); 
    end
    
    x_pos = eye(:,7);
    y_pos = eye(:,8);
    vel_x = [0; diff(x_pos)];
    vel_y = [0; diff(y_pos)];
    vel = sqrt(vel_x.^2 + vel_y.^2);
    vel_norm = zscore(vel')'; % normalize
    x = tplitz(vel_norm,30);
    
    a=x*h_erc; b=y*w_erc;    
   for ii = 1:num_comp
        rho_erc(i,ii) = corr(a(:,ii),b(:,ii)); 
    end
end

[p,h] = signrank(sum(rho_erc,2),sum(rho_src,2));
fig3 = figure(3);clf;hold on
bar(1,mean(sum(rho_erc,2)),'r','barwidth',.35)
bar(2,mean(sum(rho_src,2)),'b','barwidth',.35)
set(gca,'xTick', [1 2], 'xTickLabel', {'erc', 'src'},'FontSize',14)
set(gca,'yTick', [0:.1:.25], 'FontSize',14)
ylabel('correlation','FontSize',14)
xlim([0.5 2.5])
sigstar({[1,2]},p,0,1)
saveas(fig3,  [figure_dir '/src_vs_erc'], 'jpeg');

% legend({'erc','src'}

%% compute by eye-response/stimulus-eye by condition
for i_cond = 1:num_conditions
    index = find((metadata_stk.eye_data_status == 1) & (metadata_stk.condition == i_cond));
    eye = cat(1, EYE{index});
    x_pos = eye(:,7);
    y_pos = eye(:,8);
    vel_x = [0; diff(x_pos)];
    vel_y = [0; diff(y_pos)];
    vel = sqrt(vel_x.^2 + vel_y.^2);
    vel(isnan(vel))=0;
    vel = [vel_x vel_y];
    vel_norm = zscore(vel')'; % normalize

    heatmap = eyetracking_heatmap(x_pos*scrn_width,y_pos*scrn_height, scrn_width, scrn_height);
    img = heatmap_to_rgb(heatmap, scrn_width, scrn_height, true);
    imshow(img)
    imshow(heatmap);axis tight

    resp = cat(1, EEG{index});
    stim = cat(1, STIMULUS{index});

    [sec_2d{i_cond}, A_eye_2d{i_cond}, B_eye_2d{i_cond}] = compute2dSRC(stim, vel_norm, 30, 2, 30);

    fig4_a = createMatlabFigure(1, 12, 4, 'inches');clf;
    draw2dSRCFigure(sec_2d{i_cond}, stim, 2);
    colormap jet
    saveas(gcf,  [figure_dir '/stimulus_eye_corr_' str_cond{i_cond}], 'jpeg');
end

%%

save([computed_value_dir '/sec_indvidual_subject.mat'], 'sec_2d', 'A_eye_2d', 'B_eye_2d') 

i_cond = 3;
fig4_a = createMatlabFigure(1, 12, 4, 'inches');clf;
draw2dSRCFigure(sec_2d{i_cond}, stim, 2);
colormap jet
saveas(fig4_a,  [figure_dir '/stimulus_eye_corr'], 'jpeg');

% Draw trf at horizontal cross position  
[HEIGHT, width, ~,~,~,~] = size(sec_2d{i_cond});
fig4_b = createMatlabFigure(11, 6, 4, 'inches');clf;
drawXPosTRFAtCenter(A_eye_2d{i_cond}, fs, [11:12], [HEIGHT width]*2);
saveas(fig4_b,  [figure_dir '/tef_180'], 'jpeg');

% Draw trf at vertical cross section phase randomized eeg
fig4_c = createMatlabFigure(12, 6, 4, 'inches');clf;
drawYPosTRFAtCenter(A_eye_2d{i_cond}, fs, [15:16], [HEIGHT width]*2);
saveas(fig4_c,  [figure_dir '/tef_90_rand'], 'jpeg');

session_index = find(metadata_stk.session == 2);
eye = cat(1, EYE{session_index});
% x = cat(1, EYE{2});
scrn_width = 1980;
scrn_height  = 1080;

iter = 1;vel_x = {}; vel_y={};
for i_cond = [1 4];
    index = find((metadata_stk.eye_data_status == 1) & (metadata_stk.condition == i_cond));
    eye = cat(1, EYE{index});
    eye(isnan(eye)) = nan;
    x_pos = eye(:,7);
    y_pos = eye(:,8);
    vel_x{iter} = [0; diff(x_pos)];
    vel_y{iter} = [0; diff(y_pos)];

    iter = iter + 1;
end

% create x y histogram for eye movement
fig4_a = createMatlabFigure(4, 6, 12, 'inches');clf;
clf; subplot(2,1,1); hold on
h1 = histogram(rmoutliers(round(vel_y{1}*720),'mean')); 
h2 = histogram(rmoutliers(round(vel_y{2}*720),'mean'));
h1.Normalization = 'probability';
h1.BinWidth = 1;
h2.Normalization = 'probability';
h2.BinWidth = 1;
xlim([-40 40]); ylim([0 .2])
title('y pos','FontSize', 14); ylabel('%','FontSize', 14)
 subplot(2,1,2); hold on
h1 = histogram(rmoutliers(round(vel_x{1}*1080),'mean'));
h2 =histogram(rmoutliers(round(vel_x{2}*1080),'mean'));
h1.Normalization = 'probability';
h1.BinWidth = 1;
h2.Normalization = 'probability';
h2.BinWidth = 1;
xlim([-40 40]); ylim([0 .2])

title('x pos','FontSize', 14)
legend({'active', 'passive'},'FontSize', 14); ylabel('%','FontSize', 14)
saveas(fig4_a,  [figure_dir '/hist_x_y_pos'], 'jpeg');

num_conditions = numel(unique(metadata_stk.condition));
kx = 30; ky = 11;
for i_cond = 1:num_conditions
    
    index = find((metadata_stk.eye_data_status == 1) & (metadata_stk.condition == i_cond));
    eye = cat(1, EYE{index});
    eye(isnan(eye)) = 0;
    x_pos = eye(:,7);
    y_pos = eye(:,8);
    vel_x = [0; diff(x_pos)];
    vel_y = [0; diff(y_pos)];
    vel = sqrt(vel_x.^2 + vel_y.^2);
    % vel(isnan(vel))=0;
    
    vel_x_tplitz = tplitz(zscore(vel_x')',30);
    vel_y_tplitz = tplitz(zscore(vel_y')',30);
    vel_mag_tplitz = tplitz(zscore(vel')',30);

    resp = cat(1, EEG{index});
    
    cca_estimator = CCA(Params(kx,  ky));
    cca_estimator.fit(vel_x_tplitz, resp);
    erc_x(i_cond,:) = cca_estimator.predict(vel_x_tplitz, resp);
    A_erc_x(i_cond, :, :) = cca_estimator.A;
    B_erc_x(i_cond, :, :) = cca_estimator.B;
      
    cca_estimator = CCA(Params(kx,  ky));
    cca_estimator.fit(vel_y_tplitz, resp);
    erc_y(i_cond,:) = cca_estimator.predict(vel_y_tplitz, resp);
    A_erc_y(i_cond, :, :) = cca_estimator.A;
    B_erc_y(i_cond, :, :) = cca_estimator.B;
    
    cca_estimator = CCA(Params(kx,  ky));
    cca_estimator.fit(vel_mag_tplitz, resp);
    erc_mag(i_cond,:) =cca_estimator.predict(vel_mag_tplitz, resp);
    A_erc_mag(i_cond, :, :) = cca_estimator.A;
    B_erc_mag(i_cond, :, :) = cca_estimator.B;
    
end

fig1 = figure(1);clf
subplot(2,2,1)
locInfo = readLocationFile(LocationInfo, 'ActiCap96.loc');
scalp_plot = ScalpPlot(loc_info);
scalp_plot.draw(squeeze(B_erc_x(1,:,1)))
xlabel('active')

subplot(2,2,2)
scalp_plot = ScalpPlot(loc_info);
scalp_plot.draw(-squeeze(B_erc_x(3,:,1)))
xlabel('passive')

subplot(2,1,2); hold on
trf = squeeze(A_erc_x(1,:,1));
plot(1:30, trf(1:30))
trf = squeeze(-A_erc_x(3,:,1));
plot(1:30, -trf(1:30), 'r')

if i == 1
    legend({'active', 'passive'})
end
suptitle('eye vel x')
saveas(fig1,  [figure_dir '/erc_vel_x'], 'jpeg');

%
fig1 = figure(2);clf
suptitle('eye vel y')
saveas(fig1,  [figure_dir '/erc_vel_y'], 'jpeg');
subplot(2,2,1)
scalp_plot = ScalpPlot(loc_info);
scalp_plot.draw(squeeze(B_erc_y(1,:,1)))
xlabel('active')

subplot(2,2,2)
scalp_plot = ScalpPlot(loc_info);
scalp_plot.draw(squeeze(-B_erc_y(3,:,1)))
xlabel('passive')

subplot(2,1,2); hold on
trf = squeeze(A_erc_y(1,:,1));
plot(1:30, trf(1:30))
trf = squeeze(A_erc_y(3,:,1));
plot(1:30, -trf(1:30), 'r')

if i == 1
    legend({'active', 'passive'})
end
suptitle('eye vel y')
saveas(fig1,  [figure_dir '/erc_vel_y'], 'jpeg');
fig1 = figure(3);clf
val = [squeeze(B_erc_mag(1,:,1)); squeeze(B_erc_mag(3,:,1))];
min_val = round(min(val(:)),3);
max_val = round(max(val(:)),3);
caxis_val = [-max_val 0 max_val];
caxis_str = {num2str(-max_val) '0' num2str(max_val)};
subplot(2,2,1)
loc_info = readLocationFile(LocationInfo, 'ActiCap96.loc');
scalp_plot = ScalpPlot(loc_info);
scalp_plot.drawColorBar(caxis_val, caxis_str)
scalp_plot.draw(squeeze(B_erc_mag(1,:,1)))
title('active')

subplot(2,2,2)
scalp_plot = ScalpPlot(loc_info);
scalp_plot.draw(squeeze(B_erc_mag(3,:,1)))
scalp_plot.setColorAxis([-max_val max_val] )
title('passive')

subplot(2,1,2); hold on
trf = squeeze(A_erc_mag(1,:,1));
plot(1:30, trf(1:30))
trf = squeeze(A_erc_mag(3,:,1));
plot(1:30, trf(1:30), 'r')
set(gca, 'XTick', 0:15:30, 'XTickLabel', [0 500 1000]) 
xlabel('time (ms)')
ylim([-.4 .4])
    legend({'active', 'passive'})
suptitle('eye vel mag')
saveas(fig1,  [figure_dir '/erc_vel_mag'], 'jpeg');

cdfplot(exp(vel_x{1}))
cdfplot(exp(vel_x{2}))
legend({'active', 'passive'})
eye_pos{EYE};
x_pos = eye(:, 1);
y_pos = eye(:, 2);
heatmap = eyetracking_heatmap(x_pos, y_pos, scrn_width, scrn_height);
heatmap_rgb = heatmap_to_rgb(heatmap, scrn_width, scrn_height, true);
subplot(2,1,1)
imshow(imresize(heatmap_rgb, [scrn_height scrn_width]));
axis image
title('Heatmap','Color','k','FontSize',14)
% alpha(0.6)

subplot(2,1,2)
fs = 20;
y_pos_hm = (0:fs:scrn_height);
x_pos_hm = (0:fs:scrn_width);
heatmap_rgb_hist = hist3([x_pos, y_pos], {x_pos_hm, y_pos_hm})';
imagesc(imresize(heatmap_rgb_hist, [scrn_height scrn_width]));
axis image; colormap jet
title('Heatmap','Color','k','FontSize',14)

% combined
for i_cond = 1:num_conditions
    cond_index = find(metadata_stk.condition == i_cond);
    stim = cat(1, STIMULUS{cond_index});
    resp = cat(1, EEG{cond_index});
    [src_2d, A_2d, B_2d] = compute2dSRC(stim, resp, kx, ky, fs);
    
    save([output_dir '/src_2d_' condition_str{i_cond} '.mat'], 'src_2d', 'A_2d', 'B_2d')
end

n_samples = length(eye_gaze_parsed.timeseries);
n_bad_samples = sum(eye_gaze_parsed.timeseries(:,end));

index = find(metadata_stk.condition == 1);
median_race_time = median(metadata_stk.race_time(index));

for i  = 1:height(metadata_stk)
    race_time = metadata_stk.race_time(i);
    metadata_stk.performance_group(i) = 1;
    
    if race_time > median_race_time
        metadata_stk.performance_group(i) = 2;
    end
end

% Compute video mean vs pixel comparison
x = cat(1, STIMULUS{1});
y = cat(1, EEG{1});

x_mean = videoMean2(x);
[n, HEIGHT, width] = size(x);
for i = 1:HEIGHT
    for ii = 1:width
        x_mean_corr(i,ii) = corr(x_mean,squeeze(x(:,i,ii)));
        [r, lag] = xcorr(x_mean,squeeze(x(:,i,ii)));
        [index, val] =  max(r);
        x_cross_corr(i,ii) = index;
        x_cross_corr_dekay(i,ii) = val;
    end
end