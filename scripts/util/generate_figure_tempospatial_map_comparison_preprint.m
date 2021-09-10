function [fig, stats] = generate_figure_tempospatial_map_comparison_preprint(inputs, comparison_index, figure_num, is_deceived)
% parse CCA and SRC variables
significance_threshold = .05;
fig_config = FigureConfig();

metadata_stk = inputs.metadata_stk;
num_conditons = length(unique(metadata_stk.condition));
fs = 30;
% significance_threshold = .01
if nargin < 4
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

num_components = size(inputs.A, 2);

%% Compute regressed weights against cca projections.
condition_index = inputs.conditionIndex;
for i = 1:num_conditons
    index = find(condition_index == i);

    x = cat(1, inputs.Stimulus{index});
    y = cat(1, inputs.Response{index});
    y(isnan(y)) = 0;
        
   a = inputs.A; % cca weight left
   b = inputs.B; % cca weight right
   
   u = x * a; % stimulus projected
   v = y * b; % response projected

   % temporal forward weights
   r = v;
   s = x; %stimulus toeplitz
   s_reg = inv(s'*s+mean(eig(s'*s))*eye(size(s,2)))*s';
   H{i}= (s_reg*r);
   
   % spatial  forward weights
   r = y; % 96d eeg
   s = u; % 11d cca component of stimulus
   s_reg = inv(s'*s+mean(eig(s'*s))*eye(size(s,2)))*s';
   A{i}= (s_reg*r)';
       
end

h_difference = H{comparison_index(1)} - H{comparison_index(2)};
% w_difference = W{comparison_index(1)} - W{comparison_index(2)};
a_difference = A{comparison_index(1)} - A{comparison_index(2)};

randomized_coeff_filename = 'data/figure_4_randomized_coeff_v4.mat';
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

        % temporal forward weights
        r = v_1;
        s = x_1; %stimulus toeplitz
        s_reg = inv(s'*s+mean(eig(s'*s))*eye(size(s,2)))*s';
        h_1(:,:,i) = (s_reg*r);
        
        % spatial  forward weights
        r = y_1; % 96d eeg
        s = u_1; % 11d cca component of stimulus
        s_reg = inv(s'*s+mean(eig(s'*s))*eye(size(s,2)))*s';
        a_1(:,:,i) = (s_reg*r)';
           
        r = v_2;
        s = x_2; %stimulus toeplitz
        s_reg = inv(s'*s+mean(eig(s'*s))*eye(size(s,2)))*s';
        h_2(:,:,i) = (s_reg*r);
        
        % spatial  forward weights
        r = y_2; % 96d eeg
        s = u_2; % 11d cca component of stimulus
        s_reg = inv(s'*s+mean(eig(s'*s))*eye(size(s,2)))*s';
        a_2(:,:,i) = (s_reg*r)';
        
    end
    
    save(randomized_coeff_filename,'h_1', 'a_1', 'h_2', 'a_2')
    randomized_coeff = load(randomized_coeff_filename);

end

paper_width = 8.5; paper_height = 11;
fig = createMatlabFigure(figure_num, paper_width, paper_height, 'inches');clf;

[plot_handle_1, pos1] = tight_subplot(1, 3, [.025 .075], [.8 .05], [0.10 0.05]);
[plot_handle_2, pos2] = tight_subplot(1, 3, [.025 .075], [.65 .20], [0.10 0.05]);
[plot_handle_3, pos3] = tight_subplot(1, 3, [.025 .075], [.425 .425], [0.10 0.05]);
[plot_handle_4, pos4] = tight_subplot(1, 3, [.025 .075], [.1 .65], [0.10 0.05]);

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
        val = A{cond_index}(:,ii);       
        min_vals(i,ii) = min(val);
        max_vals(i,ii) = max(val);
    end
end

for i = 1:3
    comp_min(i) = min(min_vals(:, i ));
    comp_max(i) = max(max_vals(:, i ));
end

for i = 1:2
    cond_index = comparison_index(i); 
    for ii = 1:num_components_plot
        
        % Create topomap object to draw contour over electrodes.
        val = A{cond_index}(:,ii);
        plot_handle = plot_handles{i}(ii);

        % set color axes for the topoplot
        min_val = comp_min(ii);
        max_val = comp_max(ii);
        abs_mag_val = max(abs([min_val, max_val]));
        
%         min_val = - axis_range(ii);
%         max_val =  axis_range(ii);
        
        color_axis_range = round([min_val, max_val],2);
        
        scalp_plot = ScalpPlot(readLocationFile(LocationInfo(),'Acticap96.loc'));
        scalp_plot.setPlotHandle(plot_handle);
        scalp_plot.setColorAxis([min_val max_val])
        scalp_plot.draw(val)
        
        color_map_scale = jet;
        scalp_plot.setColorAxis(color_axis_range, color_map_scale);
    
        if i == 2
            c_axis = [color_axis_range(1), mean(color_axis_range), color_axis_range(2)];
            c_axis_tick_label = {'min', '0', 'max'};
            scalp_plot.drawColorBar(c_axis, c_axis_tick_label, 'southoutside', 'a.u.', 1)
        end        
        
%         Draw color bar to indicate color axis scale.
        if i == 1
            text(-.5,   .85, ['Component ' num2str(ii)], 'FontSize',14)
            text(-.9, .8, fig_config.panelLabel(ii), 'FontSize', fig_config.textSizeXLabel, 'FontWeight','Normal')
            panel_index = panel_index + 1;         
        end
                
        if ii ==1
            h = text(-.8, -.3, fig_config.conditionStr(cond_index), 'FontWeight','Normal', 'FontSize', fig_config.textSizeXLabel);
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
    
    color_map_scale = jet;
    color_axis_range = round([min_val, max_val],2);
    scalp_plot.setColorAxis(color_axis_range, color_map_scale);
    
    % Draw color bar to indicate color axis scale.
    c_axis = [color_axis_range(1), mean(color_axis_range), color_axis_range(2)];
    c_axis_tick_label = {'min', '0', 'max'};
    scalp_plot.drawColorBar(c_axis, c_axis_tick_label, 'southoutside','a.u.',1);
    
    for ii = 1:num_shuffles
        a_1 = randomized_coeff.a_1(:,i,ii);
        a_2 = randomized_coeff.a_2(:,i,ii);
        a_difference_rand(:,ii) = a_1 - a_2;
    end
    
    for ii = 1:96
        x = val(ii);
        rand_data = squeeze(a_difference_rand(:,ii));
        mu = mean(rand_data);
        sigma = std(rand_data);
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
        h = text(-.8, -.4, [cond_1_str ' - ' cond_2_str], 'FontWeight','Normal', 'FontSize', 10);
        set(h,'Rotation',90);
    end
%                 text(-.9, .8, fig_config.panelLabel(ii), 'FontSize', fig_config.textSizeXLabel, 'FontWeight','Normal')

    text(-.92, .8, fig_config.panelLabel(panel_index), 'FontSize', fig_config.textSizePanelTitle, 'FontWeight','Normal')
    panel_index = panel_index + 1;

end

% plot corresponding temporal filter for each of the conditions 
y_lims = [.0008 .0004 .0004];
for i = 1:num_components_plot

    for ii = 1:2
         cond_index = comparison_index(ii);
         h = H{cond_index}((1:fs),i);
                  y = h;
         x = 0:fs-1;

        axes(plot_handle_4(i));hold on
        p = plot(x,y,'Color',fig_config.barColor{cond_index}, 'LineWidth', 2); %  stdshade(h,.25, fig_config.barColor{ii}, x)
        set(gca,'XTick',0:fs/5:fs,'XTickLabel',0:1000/5:1000, 'FontSize', fig_config.textSizeXAxis)
        
        y_max = y_lims(i);
        y_min = -y_lims(i);
        ylim([y_min y_max] )
        set(gca,'color','none')        
        xlabel('Time (ms)')
        
        if (i == 1) 
            y_axis_tick = [y_min 0 y_max]';
            y_min_label = num2str(y_min, '%0.4f');
            y_max_label = num2str(y_max, '%0.4f');
            y_axis_tick_label = {y_min_label(2:end), '0', y_max_label(2:end)};
            set(gca, 'YTick', y_axis_tick, 'YTickLabel', {'-1','0','1'}, 'FontSize', fig_config.textSizeXAxis);
            ylabel('a.u.')
        else
            set(gca, 'YTick',[])
        end
        
        plot_handle(ii) = p;
        box off
    end

    %% Perform pairwise test to test difference of the temporal filters between sham play and passive.    
    for ii = 1:num_shuffles
        h_difference_rand(:,ii) = randomized_coeff.h_1(:,i,ii) - randomized_coeff.h_2(:,i,ii);
    end
    
    h_difference = H{comparison_index(1)}((1:fs),i) - H{comparison_index(2)}((1:fs),i);

%     continue
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
    
    %  continue
    y = repmat(y_max*.85,length(indexWatchBci),1);
    x = indexWatchBci-1;
    plot_handle_2 = plot(x, y, '.', 'LineWidth', 1.75,  'MarkerSize',15,  'Color', [0.30 0.20 0.1250]);
    
    if i == 2
        cond_1_str = fig_config.conditionStr{comparison_index(1)};
        cond_2_str = fig_config.conditionStr{comparison_index(2)};        conditionStr = {cond_1_str,cond_2_str, ['p < ' num2str(significance_threshold)], ''};
        legend([plot_handle(1) plot_handle(2) plot_handle_2],conditionStr, ...
            'Location', 'North', 'FontSize', fig_config.textSizeLegend)
        legend boxoff
    end
    
	axes(plot_handle_4(i));

    txt = text(0,0, fig_config.panelLabel(panel_index), 'FontSize', fig_config.textSizePanelTitle, 'FontWeight','Normal');
    panel_index = panel_index + 1;
    
end

stats=[];
fig.PaperPositionMode = 'auto';
