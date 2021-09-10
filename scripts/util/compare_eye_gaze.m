index = find((metadata_stk.eye_data_status == 1) & ((metadata_stk.condition == 1) | (metadata_stk.condition == 3)));
resp = cat(1, eeg{index});
stim = cat(1, stimulus{index});

eye = cat(1, EYE{index});
eye = cat(1, eye(:).data);
    
x_pos = eye(:,7);
y_pos = eye(:,8);
vel_x = zscore([0; diff(x_pos)]);
vel_y = zscore([0; diff(y_pos)]);
vel = [vel_x vel_y];
vel_mag = zscore(sqrt(vel_x.^2+vel_y.^2));
stim_mean = zscore(videoMean2(stim));

% combined
ref_height = 720;
ref_width = 1280;
eye_2d = [];
for i = 1:length(eye_gaze)
    if (metadata_stk.eye_data_status(i) == 1)
        data = EYE{i}.data;
        scrn_height =  eye_gaze{i}.ref_height;
        scrn_width =  eye_gaze{i}.ref_width;
        x_pos = (data(:,1)/scrn_width)*ref_width;
        y_pos = (data(:,2)/scrn_height)*ref_height;
        heatmap = eyetracking_heatmap(x_pos,y_pos, scrn_width, scrn_height,40);
        eye_2d(:,:,i) = imresize(heatmap,[height, width]);
%         img = heatmap_to_rgb(eye_heatmap{i}, ref_width, ref_height, true);
%         imshow(img);pause
        disp(i)
    end
end

group_names = {'active', 'sham', 'passive', 'count'}; 
num_conditions = numel(unique(metadata_stk.condition));
for i_group = 1:num_conditions
    ind = find(metadata_stk.condition == i_group & metadata_stk.eye_data_status == 1) ;
    eye_2d_by_group{i_group} = eye_2d(:,:,ind);
    eye_2d_by_group_avg(:,:,i_group) = mean(eye_2d(:,:,ind),3);    
end

for i = 1:length(eye_gaze)
    eye{i} = eye_gaze{i}.data;
    if (metadata_stk.eye_data_status(i) == 1)
ref_height = 720;
ref_width = 1280;
        x_pos = eye{i}(:,7)*ref_width;
        y_pos = eye{i}(:,8)*ref_height;
        eye_heatmap_indvidual{i} = eyetracking_heatmap(x_pos,y_pos, ref_width, ref_height, 30);
        disp(i)
%         eye_heatmap_indvidual{i} = heatmap_to_rgb(eye_heatmap, ref_width, ref_height, true);
    end
end

grp_index = [1 2 3 4];
fig_eye = figure(4);
ref_height = 720;
ref_width = 1280;
for i = 1:4
    i_cond = grp_index(i);
    index = find((metadata_stk.eye_data_status == 1) & (metadata_stk.condition == i_cond));
    data = cat(1, eye{index});
    x_pos = data(:,7)*ref_width;
    y_pos = data(:,8)*ref_height;
   
    eye_heatmap = eyetracking_heatmap(x_pos,y_pos, ref_width, ref_height, 40);
    img = heatmap_to_rgb(eye_heatmap, ref_width, ref_height, true);
    % img = imresize(img, [height width]);
    subplot(1,4,i)
        
    h = fspecial('gaussian',5,3);
    imshow(imfilter(img,h,'replicate'));

%     imshow(img)
    eye_2d_by_group{i} = cat(3, eye_heatmap_indvidual{index});
    eye_2d_by_group{i} = cat(3, eye_heatmap_indvidual{index});

end

comparison_index =  [1 3];
[p_left, h_left, p_right, h_right] = compareSRCByGroup(eye_2d_by_group,comparison_index);
fig_eye_gaze = createMatlabFigure(10, 10, 4, 'inches');clf;
str_1 = group_names{comparison_index(1)};
str_2 = group_names{comparison_index(2)};
drawSRCEyeByGroupComparison(eye_2d_by_group, [1 3], {str_1, str_2})
saveas(fig_eye_gaze, [figure_dir '/eye-gaze_' str_1 '_vs_' str_2] , 'jpeg');

% imagesc(eye_heatmap{1})
% img = heatmap_to_rgb(eye_heatmap{2}, ref_width, ref_height, true);
% imshow(img)
% iter = 1;
% for i = index
%     eye_heatmap_cond(:,:,iter) = eye_heatmap{i};
%     iter = iter + 1;
% end
% imshow(heatmap_to_rgb(mean(eye_heatmap_cond,3),ref_width, ref_height, false))