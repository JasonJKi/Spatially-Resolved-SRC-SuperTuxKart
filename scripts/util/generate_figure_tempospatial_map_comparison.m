function [fig, stats] = generate_figure_tempospatial_map_comparison(inputs, comp_cond_index, figure_num, is_deceived)
% parse CCA and SRC variables
significance_threshold = .05;

stats=[];
fig_config = FigureConfig();

metadata_stk = inputs.metadata;
response = inputs.response;
stimulus = inputs.stimulus;
if nargin < 30
    is_deceived = [];
end

deception_index = [];
if ~isempty(is_deceived)
    if is_deceived == 1
        deception_index = (metadata_stk.bci_deception_success  == is_deceived );
        if length(unique(metadata_stk.bci_deception_success)) > 2
            deception_index = (metadata_stk.bci_deception_success  ~= 0);
        end
    elseif is_deceived == 0
        deception_index = (metadata_stk.bci_deception_success == is_deceived);
    end
end

if sum(deception_index)
    deceived_index   = find(deception_index)';
    metadata_stk = metadata_stk(deceived_index,:);
    response = {};
    iter = 1;
    for i = deceived_index
        response{iter,1} = inputs.response{i};
        iter = iter +1;
    end
end

num_conditons = length(unique(metadata_stk.condition));
max_subject_id = max(metadata_stk.subject_id);
for i = 1:num_conditons
    index = find(metadata_stk.condition == i );
    unique_subj_index =  metadata_stk.subject_id(index);
    
    subject_id{i} =  unique_subj_index;
    subject_bool = zeros(max_subject_id, 1);
    subject_bool(unique_subj_index) = 1;
    all_grouped_subj_id(:,i) = subject_bool;
end
paired_subject_id = (sum(all_grouped_subj_id,2) == num_conditons);
paired_subject_index = find(paired_subject_id);

stats.num_subjects = length(unique(paired_subject_index));
subject_id_all = zeros(height(metadata_stk),1);
for i = paired_subject_index'
    subject_id = (metadata_stk.subject_id == i);
    subject_id_all = subject_id_all | subject_id;
end
condition_index = metadata_stk.condition; 
condition_index(~subject_id_all) = -1;
fs = 30;

num_components = size(inputs.A, 2);
num_shuffles = 1000;

% %%
% for i = 1:num_conditons
%     group_1_index = find(condition_index == i);
% %         group_1_index_ = find(metadata_stk.condition == i);
% 
%     x_1 = cat(1, stimulus{group_1_index});
%     y_1 = cat(1, response{group_1_index});
%     y_1(isnan(y_1)) = 0;
% 
%    RyyCond{i} = nancov(y_1);
%         
%     u_1 = x_1*inputs.A;
%     v_1 = y_1*inputs.B;
%     for ii = 1:num_components
%         % Compute stimulus response function from eeg canoncorr
%         % component.
%         r = v_1(:,ii);
%         s = x_1;
%         H{i}(:,ii) = (r\s)';
% 
%         r = y_1;
%         s = u_1(:,ii);
%         W{i}(:,ii) = (s\r)';
%     end
% end
% 
% h_difference = H{comp_cond_index(1)} - H{comp_cond_index(2)};
% w_difference = W{comp_cond_index(1)} - W{comp_cond_index(2)};
% 
% 
% if exist('data/figure_4_shuffled_group_weights_followup.mat', 'file')
%     load('data/figure_4_shuffled_group_weights_followup.mat')
% else
%    file_index = find(condition == comp_cond_index(1) | condition == comp_cond_index(2));
%    num_files = length(file_index);
%     shape_1 = [size(inputs.A), num_shuffles];
%     h_1 = zeros(shape_1); h_2 = zeros(shape_1);
%     shape_2 = [size(inputs.B), num_shuffles];
%     w_1 = zeros(shape_2); w_2 = zeros(shape_2);
%     parfor i = 1:num_shuffles
%         
%         random_index = randsample(num_files, num_files);
%         
%         group_1_index = file_index(random_index(1:floor(num_files/2)));
%         group_2_index = file_index(random_index((floor(num_files/2)+1):end));
%         
%         x_1 = cat(1, stimulus{group_1_index});
%         y_1 = cat(1, response{group_1_index});
%         y_1(isnan(y_1)) = 0;
%         
%         x_2 = cat(1, stimulus{group_2_index});
%         y_2 = cat(1, response{group_2_index});
%         y_2(isnan(y_2)) = 0;
%         
%         u_1 = x_1*inputs.A;
%         v_1 = y_1*inputs.B;
%         
%         u_2 = x_2*inputs.A;
%         v_2 = y_2*inputs.B;
%         
%         for ii = 1:num_components
%             % Compute stimulus response function from eeg canoncorr
%             r = v_1(:,ii); s = x_1;
%             h_1(:,ii,i) = (r\s)';
%             
%             r = y_1; s = u_1(:,ii);
%             w_1(:,ii,i) = (s\r)';
%             
%             r = v_2(:,ii); s = x_2;
%             h_2(:,ii,i) = (r\s)';
%             
%             r = y_2; s = u_2(:,ii);
%             w_2(:,ii,i) = (s\r)';
%         end
%         
%     end
%     save('figure_4_shuffled_group_weights_followup.mat','h_1', 'w_1', 'h_2', 'w_2')
% end
% 
% paper_width = 8.5; paper_height = 11;
% fig = createMatlabFigure(figure_num, paper_width, paper_height, 'inches');clf;
% [plotHandleGroup1, pos1] = tight_subplot(1, 3,[.1 .125], [.85 .05], [0.125 0.05]);
% [plotHandleGroup2, pos2] = tight_subplot(1, 3,[.1 .125], [.7 .2], [0.125 0.05]);
% [plotHandleGroup3, pos3] = tight_subplot(1, 3,[.1 .125], [.37 .32], [0.15 0.05]);
% [plotHandleGroup4, pos4] = tight_subplot(1, 3,[.1 .05], [.1 .65], [.075 .05]);
% 
% topoplotIndexSham = (1:2:6);
% topoplotIndexPassive = (2:2:6);
% topoPlotIndex = {topoplotIndexSham, topoplotIndexPassive};
% num_components_plot = 3;
% %% Create topoplot for the each of the run conditions.
% condIndex = 2; A1 = [];
% plotHandles = {plotHandleGroup1 plotHandleGroup2};
% panel_index = 1;
% 
% for i = 1:2
%     cond_index = comp_cond_index(i); 
%     for ii = 1:num_components_plot
%         
%         w = W{cond_index}(:,ii);
%         a_mean{i}(:,ii) = w;
% %         a_mean{i}(:,ii) = forwardModel(w, inputs.ryy); % RyyCond{condIndex}
% %         
%         % Create topomap object to draw contour over electrodes.
%         val = a_mean{i}(:,ii) ;
%         plotHandle = plotHandles{i}(ii);
%         
%         scalp_plot = ScalpPlot(readLocationFile(LocationInfo(),'Acticap96.loc'));
%         scalp_plot.setPlotHandle(plotHandle);
%         scalp_plot.draw(val)
%         
%         % set color axes for the topoplot
%         min_val = min(val);
%         max_val = max(val);
%         
%         abs_mag_val = max(abs([min_val, max_val]));
%         
%         min_val = - abs_mag_val;
%         max_val =  abs_mag_val;
%         
%         color_map_scale = jet;
%         color_axis_range = round([min_val, max_val],2);
%         scalp_plot.setColorAxis(color_axis_range, color_map_scale);
%         
%     % Draw color bar to indicate color axis scale.
%     c_axis = [color_axis_range(1), mean(color_axis_range), color_axis_range(2)];
%     c_axis_tick_label = {c_axis(1), '\muV 0', c_axis(3)};
%     scalp_plot.drawColorBar(c_axis, c_axis_tick_label);
%         
%         if i == 1
%             text(-.9,.9, ['Component ' num2str(ii)], 'FontSize',14)
%             text(-1.5, .8, fig_config.panelLabel(ii), 'FontSize', fig_config.textSizeXLabel, 'FontWeight','Normal')
%             panel_index = panel_index + 1;
%         end
%         
%         if ii == 1
%             h = text(-1.5, -.3, fig_config.conditionStr(cond_index), 'FontWeight','Normal', 'FontSize', fig_config.textSizeXLabel);
%             set(h,'Rotation',90);
%         end
%         
%     end
% end
% 
% for i = 1:num_components_plot
%     
%     a_mean_1 = a_mean{1}(:,i);
%     a_mean_2 = a_mean{2}(:,i);
% 
%     a_difference = a_mean_1 - a_mean_2;
%     
%     % Create topomap object to draw contour over electrodes.
%     val = a_difference;
%     plotHandle = plotHandleGroup3(i);
%     
%     scalp_plot = ScalpPlot(readLocationFile(LocationInfo(),'Acticap96.loc'));
%     scalp_plot.setPlotHandle(plotHandle);
%     scalp_plot.draw(val) 
%     
%     min_val = min(val);
%     max_val = max(val);
%     
%     abs_mag_val = max(abs([min_val, max_val]));
%     
%     min_val = - abs_mag_val;
%     max_val =  abs_mag_val;
%     
%     color_map_scale = jet;
%     color_axis_range = round([min_val, max_val],2);
%     scalp_plot.setColorAxis(color_axis_range, color_map_scale);
%     
%     % Draw color bar to indicate color axis scale.
%         % Draw color bar to indicate color axis scale.
%     c_axis = [color_axis_range(1), mean(color_axis_range), color_axis_range(2)];
%     c_axis_tick_label = {c_axis(1), '\muV 0', c_axis(3)};
%     scalp_plot.drawColorBar(c_axis, c_axis_tick_label);
%     
%     for ii = 1:num_shuffles
%         a_1 = w_1(:,i,ii);
%         a_2 = w_2(:,i,ii)
% 
% %         a_1 = forwardModel(w_1(:,i,ii), inputs.ryy); % RyyCond{condIndex}
% %         a_2 = forwardModel(w_2(:,i,ii), inputs.ryy);
%         a_difference_rand(:,ii) = a_1 - a_2;    
%     end
%     
%     for ii = 1:96
%         x = val(ii);
%         data = squeeze(a_difference_rand(:,ii));
%         mu = mean(data);
%         sigma = std(data);
%         p(ii) = normcdf(x, mu, sigma);        
%     end
%     
%     
%     is_signifcant_higher = p <significance_threshold;
%     is_signifcant_lower = 1-p < significance_threshold;
%     
%      [cor_p, c_alpha, is_signifcant_higher]=fdr_BH(p,significance_threshold);
%      [cor_p, c_alpha, is_signifcant_lower]=fdr_BH(1-p,significance_threshold);
% %     
%     markerHandle1 = scalp_plot.drawOnElectrode(is_signifcant_higher,'.', [0.30 0.20 0.1250]);
%     markerHandle2 = scalp_plot.drawOnElectrode(is_signifcant_lower, '.', [0.30 0.20 0.1250]);
%     
%     if i == 1
%         conditionStr = {['p < ' num2str(significance_threshold)],''};
%         markerHandles = [markerHandle1 markerHandle2];
%         scalp_plot.drawMarkerLegend(markerHandle1, conditionStr, 'northoutside');
%     end
%     
%     if i == 1
%        cond_1_str = fig_config.conditionStr{comp_cond_index(1)};
%        cond_2_str = fig_config.conditionStr{comp_cond_index(2)};
%         h = text(-1.1, -.4, [cond_1_str ' - ' cond_2_str], 'FontWeight','Normal', 'FontSize', 12);
%         set(h,'Rotation',90);
%     end
%     
%     text(-1.2, .8, fig_config.panelLabel(panel_index), 'FontSize', fig_config.textSizePanelTitle, 'FontWeight','Normal')
%     panel_index = panel_index + 1;
% 
% end
% 
% % plot corresponding temporal filter for each of the conditions 
% fs = 30
% for i = 1:num_components_plot
% 
%     for ii = 1:2
%          cond_index = comp_cond_index(ii);
%         hMean = H{cond_index}((1:fs),i);
%        
%         y = hMean;
%         x = 0:fs-1;
%         
%         axes(plotHandleGroup4(i));hold on
%         p = plot(x,y,'Color',fig_config.barColor{cond_index}, 'LineWidth', 2);
% %         stdshade(h,.25, fig_config.barColor{ii}, x)
%         set(gca,'XTick',0:fs/5:fs,'XTickLabel',0:1000/5:1000, 'FontSize', fig_config.textSizeXAxis)
%         
%         ylim([-.75 .75] )
%         set(gca,'color','none')
%         
%         xlabel('Time (ms)')
%         
%         if i == 1
%             set(gca,'YTick',-1:.5:1,'YTickLabel',num2str((-1:.5:1)','%0.2f'), 'FontSize', fig_config.textSizeXAxis);
%             ylabel('\muV')
%         end
%         
%         templPointsHandle(ii) = p;
%         box off
%     end
%     
%     %% Perform pairwise test to test difference of the temporal filters between sham play and passive.
%     
%     
%     for ii = 1:num_shuffles
%         h_difference_rand(:,ii) = h_1(:,i,ii) - h_2(:,i,ii);
%     end
%     
%     h_difference = H{comp_cond_index(1)}((1:fs),i) - H{comp_cond_index(2)}((1:fs),i);
% 
%     p=[]
%     for ii = 1:30
%         x = h_difference(ii);
%         data = squeeze(h_difference_rand(:,ii));
%         mu = mean(data);
%         sigma = std(data);
%         p(ii) = normcdf(x, mu, sigma);        
%     end
%     
%     is_signifcant_higher = p < significance_threshold;
%     is_signifcant_lower = 1-p < significance_threshold;
%     
%      [cor_p, c_alpha, is_signifcant_higher]=fdr_BH(p,significance_threshold);
%      [cor_p, c_alpha, is_signifcant_lower]=fdr_BH(1-p,significance_threshold);
%     
%     signifcant_points = is_signifcant_higher | is_signifcant_lower;
%     maxPeak = max( [max(H{1}((1:fs),i)), max(H{2}((1:fs),i))]);
%     
%     indexWatchBci = find(signifcant_points);
%     axes(plotHandleGroup4(i));
%     templPointsHandle3=plot(indexWatchBci-1,repmat(maxPeak*1.2,length(indexWatchBci),1), ...
%         '.', 'LineWidth', 1.75,  'MarkerSize',15,  'Color', [0.30 0.20 0.1250]);
% 
% %     [cor_p, c_alpha, is_signifcant_lower]=fdr_BH(1-p,significance_threshold);
% %     signifcant_points = is_signifcant_lower;
% %     minPeak = min( [min(H{1}((1:fs),i)), min(H{2}((1:fs),i))]);
% %     
% %     indexWatchBci = find(signifcant_points);
% %     axes(plotHandleGroup4(i));
% %     templPointsHandle4=plot(indexWatchBci-1,repmat(minPeak*0.9,length(indexWatchBci),1), '*', 'LineWidth', 2);
%     
%     if i == 3
%         cond_1_str = fig_config.conditionStr{comp_cond_index(1)};
%         cond_2_str = fig_config.conditionStr{comp_cond_index(2)};        conditionStr = {cond_1_str,cond_2_str, ['p < ' num2str(significance_threshold)], ''};
%         legend([templPointsHandle(1) templPointsHandle(2) templPointsHandle3],conditionStr, ...
%             'Location', 'North', 'FontSize', fig_config.textSizeLegend)
%         legend boxoff
%     end
%     
%     text(-3, .8,fig_config.panelLabel(panel_index), 'FontSize', fig_config.textSizePanelTitle, 'FontWeight','Normal')    
%     panel_index = panel_index + 1;
%     
% end
% 
% stats=[];
% fig.PaperPositionMode = 'auto';

%% Compute regressed weights against cca projections.
condition_index = inputs.conditionIndex;
for i = 1:num_conditons
    index = find(condition_index == i);
    
    x = cat(1, inputs.Stimulus{index});
    y = cat(1, inputs.Response{index});
    y(isnan(y)) = 0;

    %   ryy_all_cond{i} = nancov(y);
        
   a = inputs.A; % cca weight left
   b = inputs.B; % cca weight right
   
   u = x * a; % stimulus projected
   v = y * b; % response projected

   p = length(a); % stim dimensions
   d = length(b); % response dimension
   
    %     D=96;K=10;P=31;T=1000; W=randn(K,D);r=randn(D,T); s=randn(1,T);            
    for ii = 1:num_components
        
        % compute regressed coefficients from cca weights.
        r = v(:,ii);
        s = x;
        W{i}(:,ii) = (r\s)';
        
        s = x(:,1)'; 
        s = s(1:end-p);
        r = hankel(v(:,ii), [v(end,ii) zeros(1,p-1)])';
        r = r(:,1:end-p);
        
        H{i}(:,ii) = (s/r)';
        
        r = y;
        s = u(:,ii);
        A{i}(:,ii) = (s\r)';
    
    end
end

h_difference = H{comparison_index(1)} - H{comparison_index(2)};
w_difference = W{comparison_index(1)} - W{comparison_index(2)};
a_difference = A{comparison_index(1)} - A{comparison_index(2)};

randomized_coeff_filename = 'data/figure_4_randomized_coeff_v3.mat';
num_shuffles = 1000;
if exist(randomized_coeff_filename, 'file')
    randomized_coeff = load(randomized_coeff_filename);
else
    
    condition_index = metadata_stk.condition;
    file_index = find(condition_index == comparison_index(1) | condition_index== comparison_index(2));
    num_files = length(file_index);
    shape_1 = [size(inputs.A), num_shuffles];    
    h_1 = zeros(shape_1); h_2 = zeros(shape_1);
    w_1 = zeros(shape_1); w_2 = zeros(shape_1);

    shape_2 = [size(inputs.B), num_shuffles];    
    a_1 = zeros(shape_2); a_2 = zeros(shape_2);
    
    parfor i = 1:num_shuffles
        
        random_index = randsample(num_files, num_files);
        
        group_1_index = file_index(random_index(1:num_files/2));
        group_2_index = file_index(random_index((num_files/2)+1:end));
        
        x_1 = cat(1, inputs.Stimulus{group_1_index});
        y_1 = cat(1, inputs.Response{group_1_index});
        y_1(isnan(y_1)) = 0;
        
        x_2 = cat(1, inputs.Stimulus{group_2_index});
        y_2 = cat(1, inputs.Response{group_2_index});
        y_2(isnan(y_2)) = 0;
        
        a = inputs.A;
        b = inputs.B;
        u_1 = x_1 * a;
        v_1 = y_1 * b;
        
        u_2 = x_2 * a;
        v_2 = y_2 * b;
        
        p = length(a); % stim dimensions
        d = length(b); % response dimension

        for ii = 1:num_components
            
            % null group 1
            s = x_1(1:end-p,1)';
            r = hankel(v_1(:,ii), [v_1(end,ii) zeros(1,p-1)])';
            r = r(:,1:end-p);
            h_1(:,ii,i) = (s/r)';
            
            r = v_1(:,ii); s = x_1;
            w_1(:,ii,i) = (r\s)';

            r = y_1; s = u_1(:,ii);
            a_1(:,ii,i) = (s\r)';
            
            % null group 2
            s = x_2(1:end-p,1)';
            r = hankel(v_2(:,ii), [v_2(end,ii) zeros(1,p-1)])';
            r = r(:,1:end-p);
            h_2(:,ii,i) = (s/r)';
            
            r = v_2(:,ii); s = x_2;
            w_2(:,ii,i) = (r\s)';
            
            r = y_2; s = u_2(:,ii);
            a_2(:,ii,i) = (s\r)';
            
        end        
    end
    save(randomized_coeff_filename,'h_1', 'a_1', 'w_1', 'h_2', 'a_2', 'w_2')
    randomized_coeff = load(randomized_coeff_filename);
end

paper_width = 8.5; paper_height = 11;
fig = createMatlabFigure(figure_num, paper_width, paper_height, 'inches');clf;
[plot_handle_1, pos1] = tight_subplot(1, 3,[.1 .125], [.85 .05], [0.125 0.05]);
[plot_handle_2, pos2] = tight_subplot(1, 3,[.1 .125], [.7 .2], [0.125 0.05]);
[plot_handle_3, pos3] = tight_subplot(1, 3,[.1 .125], [.37 .32], [0.15 0.05]);
[plot_handle_4, pos4] = tight_subplot(1, 3,[.1 .05], [.1 .65], [.075 .05]);

topoplotIndexSham = (1:2:6);
topoplotIndexPassive = (2:2:6);
topoPlotIndex = {topoplotIndexSham, topoplotIndexPassive};
num_components_plot = 3;
%% Create topoplot for the each of the run conditions.
plot_handles = {plot_handle_1 plot_handle_2};
panel_index = 1;
axis_range = [.10, .05,.03];
for i = 1:2
    cond_index = comparison_index(i); 
    for ii = 1:num_components_plot
        
        % Create topomap object to draw contour over electrodes.
        val = A{cond_index}(:,ii);
        plot_handle = plot_handles{i}(ii);
        
        scalp_plot = ScalpPlot(readLocationFile(LocationInfo(),'Acticap96.loc'));
        scalp_plot.setPlotHandle(plot_handle);
        scalp_plot.draw(val)
        
        % set color axes for the topoplot
        min_val = min(val);
        max_val = max(val);
        abs_mag_val = max(abs([min_val, max_val]));
        
        min_val = - axis_range(ii);
        max_val =  axis_range(ii);
        
        color_axis_range = round([min_val, max_val],2);
        
        scalp_plot.setColorAxis([min_val max_val])
        
        % Draw color bar to indicate color axis scale.
        c_axis = [color_axis_range(1), mean(color_axis_range), color_axis_range(2)];
        c_axis_tick_label = {c_axis(1), '\muV 0', c_axis(3)};
        scalp_plot.drawColorBar(c_axis, c_axis_tick_label)
        
        if i == 1
            text(-.9,   .9, ['Component ' num2str(ii)], 'FontSize',14)
            text(-1.5, .8, fig_config.panelLabel(ii), 'FontSize', fig_config.textSizeXLabel, 'FontWeight','Normal')
            panel_index = panel_index + 1;
        end
        
        if ii == 1
            h = text(-1.5, -.3, fig_config.conditionStr(cond_index), 'FontWeight','Normal', 'FontSize', fig_config.textSizeXLabel);
            set(h,'Rotation',90);
        end
        
    end
end


for i = 1:num_components_plot
    
    cond_index_1 = comparison_index(1); 
    cond_index_2 = comparison_index(2);
    a_1 = A{cond_index_1}(:,i);
    a_2 = A{cond_index_2}(:,i);

    a_difference = a_1 - a_2;
    
    % Create topomap object to draw contour over electrodes.
    val = a_difference;
    plot_handle = plot_handle_3(i);
    
    scalp_plot = ScalpPlot(readLocationFile(LocationInfo(),'Acticap96.loc'));
    scalp_plot.setPlotHandle(plot_handle);
    scalp_plot.draw(val) 
    
    % set color axes for the topoplot
    min_val = min(val);
    max_val = max(val);
    
    abs_mag_val = max(abs([min_val, max_val]));
    
    min_val = - abs_mag_val;
    max_val =  abs_mag_val;
    
    color_map_scale = jet;
    color_axis_range = round([min_val, max_val],2);
    scalp_plot.setColorAxis(color_axis_range, color_map_scale);
    
    % Draw color bar to indicate color axis scale.
    c_axis = [color_axis_range(1), mean(color_axis_range), color_axis_range(2)];
    c_axis_tick_label = {c_axis(1), '\muV 0', c_axis(3)};
    scalp_plot.drawColorBar(c_axis, c_axis_tick_label);
    
    for ii = 1:num_shuffles
        a_1 = randomized_coeff.a_1(:,i,ii);
        a_2 = randomized_coeff.a_2(:,i,ii);
        a_difference_rand(:,ii) = a_1 - a_2;    
    end
    
    for ii = 1:96
        x = val(ii);
        data = squeeze(a_difference_rand(:,ii));
        mu = mean(data);
        sigma = std(data);
        p(ii) = normcdf(x, mu, sigma);        
    end
    
    
%     is_signifcant_lower = p < significance_threshold;
%     is_signifcant_higher   = 1-p <  significance_threshold;
    
     [cor_p, c_alpha, is_signifcant_lower] = fdr_BH(p,significance_threshold);
     [cor_p, c_alpha, is_signifcant_higher] = fdr_BH(1-p,significance_threshold);

    marker_handle_1 = scalp_plot.drawOnElectrode(is_signifcant_higher,'.', [0.30 0.20 0.1250]);
    marker_handle_2 = scalp_plot.drawOnElectrode(is_signifcant_lower, '.', [0.30 0.20 0.1250]);
    
    if i == 1
        conditionStr = {['p < ' num2str(significance_threshold)],''};
        marker_handles = [marker_handle_1 marker_handle_2];
        scalp_plot.drawMarkerLegend(marker_handle_1, conditionStr, 'northoutside');
    end
    
    if i == 1
       cond_1_str = fig_config.conditionStr{comparison_index(1)};
       cond_2_str = fig_config.conditionStr{comparison_index(2)};
        h = text(-1.1, -.4, [cond_1_str ' - ' cond_2_str], 'FontWeight','Normal', 'FontSize', 12);
        set(h,'Rotation',90);
    end
    
    text(-1.2, .8, fig_config.panelLabel(panel_index), 'FontSize', fig_config.textSizePanelTitle, 'FontWeight','Normal')
    panel_index = panel_index + 1;

end

% plot corresponding temporal filter for each of the conditions 
for i = 1:num_components_plot

    for ii = 1:2
         cond_index = comparison_index(ii);
        w = H{cond_index}((1:fs),i);
       
        y = w;
        x = 0:fs-1;
        
        axes(plot_handle_4(i));hold on
        
        p = plot(x,y,'Color',fig_config.barColor{cond_index}, 'LineWidth', 2); %  stdshade(h,.25, fig_config.barColor{ii}, x)
        set(gca,'XTick',0:fs/5:fs,'XTickLabel',0:1000/5:1000, 'FontSize', fig_config.textSizeXAxis)
        
        y_max = .75 ;
        y_min = -.75;
        ylim([y_min y_max] )
        set(gca,'color','none')        
        xlabel('Time (ms)')
        
        if i == 1
            y_axis_tick = (y_min:.25:y_max)';
            set(gca, 'YTick', y_axis_tick, 'YTickLabel', num2str(y_axis_tick, '%0.2f'), 'FontSize', fig_config.textSizeXAxis);
            ylabel('\muV')
        end
        
        plot_handle(ii) = p;
        box off
    end
    
    %% Perform pairwise test to test difference of the temporal filters between sham play and passive.
    
    
    for ii = 1:num_shuffles
        h_difference_rand(:,ii) = randomized_coeff.h_1(:,i,ii) - randomized_coeff.h_2(:,i,ii);
    end
    
    h_difference = H{comparison_index(1)}((1:fs),i) - H{comparison_index(2)}((1:fs),i);

    p=[];
    for ii = 1:30
        x = h_difference(ii);
        data = squeeze(h_difference_rand(:,ii));
        mu = mean(data);
        sigma = std(data);
        p(ii) = normcdf(x, mu, sigma);        
    end
    
    is_signifcant_higher = p < significance_threshold;
    is_signifcant_lower = 1-p < significance_threshold;
    
     [cor_p, c_alpha, is_signifcant_higher]=fdr_BH(p,significance_threshold);
     [cor_p, c_alpha, is_signifcant_lower]=fdr_BH(1-p,significance_threshold);
    
    signifcant_points = is_signifcant_higher | is_signifcant_lower;
    maxPeak = max( [max(H{1}((1:fs),i)), max(H{2}((1:fs),i))]);
    
    indexWatchBci = find(signifcant_points);
    axes(plot_handle_4(i));
    
%      'LineWidth',3,...
%     'MarkerSize',15,...
%     'MarkerEdgeColor','b',...
%     'MarkerFaceColor',[0.5,0.5,0.5]

%     continue
    y = repmat(maxPeak*1.2,length(indexWatchBci),1);
    x = indexWatchBci-1;
    plot_handle_2 = plot(x, y, '.', 'LineWidth', 1.75,  'MarkerSize',15,  'Color', [0.30 0.20 0.1250]);

    if i == 3
        cond_1_str = fig_config.conditionStr{comparison_index(1)};
        cond_2_str = fig_config.conditionStr{comparison_index(2)};        conditionStr = {cond_1_str,cond_2_str, ['p < ' num2str(significance_threshold)], ''};
        legend([plot_handle(1) plot_handle(2) plot_handle_2],conditionStr, ...
            'Location', 'North', 'FontSize', fig_config.textSizeLegend)
        legend boxoff
    end
    
    text(-3, .8,fig_config.panelLabel(panel_index), 'FontSize', fig_config.textSizePanelTitle, 'FontWeight','Normal')    
    panel_index = panel_index + 1;
    
end

stats=[];
fig.PaperPositionMode = 'auto';

