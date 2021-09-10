function [fig, stats] = figure_src_vs_power_correlation(inputs,  band_type, is_deceived, figure_num)
%% Load figure configuration for bar colors, etc.
fig_config = FigureConfig();

metadata_stk = inputs.metadata;
response = inputs.response;
stimulus = inputs.stimulus;
fs = 30;

if nargin < 3
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

eeg_location_info = readLocationFile(LocationInfo(), 'ActiCap96.loc');
motor_cortex_electrode_index_1 = (contains(eeg_location_info.channelLabelsCell,'C3') | contains(eeg_location_info.channelLabelsCell,'C4'));
motor_cortex_electrode_index_2 = (contains(eeg_location_info.channelLabelsCell,'P3') | contains(eeg_location_info.channelLabelsCell,'P4'));
motor_cortex_electrode_index = (motor_cortex_electrode_index_1 | motor_cortex_electrode_index_2);

[rhos, metadata_stk] = computeSRCByCondition(inputs.stimulus, inputs.response, inputs.cca_estimator, metadata_stk, deception_index);
[group_index, condition_index, subject_index, deception_index] =  concatenateGroupByCondition_(metadata_stk , 1);
engagement_rating = inputs.engagement_rating;
condition_labels = unique(condition_index)';
num_conditions = length(condition_labels);
file_index = 1:height(metadata_stk);
component_index = 1:11;

subject_id = {}; all_grouped_subj_id= [];
max_subject_id = max(metadata_stk.subject_id);
for i = 1:num_conditions
   index = find(condition_index == condition_labels(i) );
   unique_subj_index =  subject_index(index);
   
   subject_id{i} =  unique_subj_index;
   subject_bool = zeros(max_subject_id, 1);
   subject_bool(unique_subj_index) = 1;
   all_grouped_subj_id(:,i) = subject_bool;
end
paired_subject_id = (sum(all_grouped_subj_id,2) == num_conditions);
paired_subject_id(1:18) = 1;
stats.num_subjects = length(unique(find(paired_subject_id)));

%% Computing statistics for engagement rating of each viewing conditions.
% if max(engagement_rating) > 10
%     engagement_rating = engagement_rating/10;
% end
switch band_type
    case 'theta'
        [thetab1,a1] = butter(4, [4 8]/(fs/2),'bandpass');
        a = a1; b = thetab1;
    case 'alpha'
        [alphab2,a2] = butter(4, [8 13]/(fs/2),'bandpass');
        a = a2; b = alphab2;
    case 'beta'
        [betab3,a3] = butter(4, [13 14.5]/(fs/2),'bandpass');
        a = a3; b = betab3;
end


for  i_group = 1:length(group_index)
    index =  file_index( group_index{i_group});
    eeg = cat(1, response{index});
    eeg(isnan(eeg)) = 0;

    num_channels = size(eeg,2);
     for ii = 1:num_channels
            response_power{i_group}(ii) =  mean(filter(b,a,eeg(:,ii)).^2); %10*log10(mean(filter(b,a,eeg(:,ii)).^2));
            overall_response_power{i_group}(ii) = mean(eeg(:,ii).^2);
     end
end

for  i = 1:height(metadata_stk)
    x_test = stimulus{i};
    y_test = response{i};
    y_test(isnan(y_test)) = 0;
    
    rho = inputs.cca_estimator.predict(x_test, y_test);
    rhos(i,:) = rho;
    
    for ii = 1:num_channels
        response_power{i}(ii) =  mean(filter(b,a, response{i}(:,ii)).^2); %10*log10(mean(filter(b,a,eeg(:,ii)).^2));
        overall_response_power{i}(ii) = mean( response{i}(:,ii).^2);
    end
   
end
fig = figure(figure_num);

for i = 1:num_conditions
    
    cond_index = find(metadata_stk.condition == i);        
    power = cat(1,response_power{cond_index});
    mu_power = power(:,motor_cortex_electrode_index);
    mean_mu_power = mean(mu_power,2);
    rho = rhos(cond_index,:);
    src_sum = sum(rho, 2);
    
    ind = isoutlier(mean_mu_power);
    src_sum = src_sum(~ind);
    mean_mu_power = mean_mu_power(~ind);
    [corr_mu_vs_src(i) h_mu_vs_src(i)] = corr(mean_mu_power,src_sum);
    subplot(2,2,i)
    plot(mean_mu_power,src_sum, '.')
    title([fig_config.conditionStr{i} ', n=' num2str(length(mu_power))] )
    xlabel('alpha power (\muV^{2})')
    ylabel('src')
end

stats.corr_mu_vs_src = corr_mu_vs_src;
stats.h_mu_vs_src = h_mu_vs_src;

return

%% Group values based on trials
anova_rho =[]; anova_condition_index = [];anova_subject_index=[];
component_to_keep = 1:3;
fig = figure(figure_num);
for i = 1:num_conditions
    
    cond_index = find(condition_index == condition_labels(i) );
    
    subj_id_1 = find(paired_subject_id);
    subj_id_2 = subject_index(cond_index);
    
    index_1 = paired_subject_id; 
    index_2 = all_grouped_subj_id(:,i);
    
    [unmatch_ind_1, unmatch_ind_2] = indexDependentPairs(subj_id_1, subj_id_2, index_1, index_2);

    
    subj_id_2(unmatch_ind_2) = [];
    subj_id =  subj_id_2;
    subject_id{i} =  subj_id;

    rho =  rhos(cond_index,component_index);
    rho(unmatch_ind_2,:) = [];
    
    src_grouped{i}.rho = rho;
    src_grouped{i}.rhoMean = mean(rho);
    src_grouped{i}.rhoSum = sum(rho,2);    
    src_grouped{i}.semRho = stdError(src_grouped{i}.rhoSum);

    power = cat(1,response_power{cond_index});
    power_overall = cat(1,overall_response_power{cond_index});
    power(unmatch_ind_2,:) = [];
    power_overall(unmatch_ind_2, :) = [];
    
    response_power_grouped{i} = power;
    eeg_power_mean{i} = mean(mean(power,2))';
    eeg_power_ste{i} = stdError(mean(power,2))';

    overall_response_power_grouped{i} = power_overall;
    eeg_power_overall_mean{i} =mean(mean(power_overall,2))';
    eeg_power_overall_ste{i} = stdError(mean(power_overall,2))';
    
    mu_power = power(:,motor_cortex_electrode_index);
    mean_mu_power = mean(mu_power,2);
    src_sum = src_grouped{i}.rhoSum;
    
    
    [corr_mu_vs_src(i) h_mu_vs_src(i)] = corr(mean_mu_power,src_sum);
    subplot(2,2,i)
    plot(mean_mu_power,src_sum, '.')
    title([fig_config.conditionStr{i} ', n=' num2str(length(mu_power))] )
    xlabel('alpha power (\muV^{2})')
    ylabel('src')
end


stats.corr_mu_vs_src = corr_mu_vs_src;
stats.h_mu_vs_src = h_mu_vs_src;
