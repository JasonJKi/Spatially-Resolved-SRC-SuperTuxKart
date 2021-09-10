index = find((metadata_stk.eye_data_status == 1) & ((metadata_stk.condition == 1) | (metadata_stk.condition == 3)));
index = index(1:5);
resp = cat(1, EEG{index});
stim = cat(1, STIMULUS{index});

eye = cat(1, EYE{index});
eye = cat(1, eye(:).data);
    
x_pos = eye(:,7);
y_pos = eye(:,8);
vel_x = zscore([0; diff(x_pos)]);
vel_y = zscore([0; diff(y_pos)]);
vel = [vel_x vel_y];
vel_mag = zscore(sqrt(vel_x.^2+vel_y.^2));
stim_mean = zscore(videoMean2(stim));
[r,p] = corrcoef(vel_mag,stim_mean);
scatter(vel_mag,stim_mean)

x1 = 13000;
x = (0:10000);
T = 10;t = x+x1; fs = 30;dt =5;

fig = figure(1);clf
subplot(2,1,1)
plot(vel_x(t),'r', 'LineWidth', 1.7)
xlim([0 T*fs+1]); ylim([-5 5]);
set(gca,'xTick',(0:dt:T-1)*fs,'xTickLabel', [])
set(gca,'yTick',[-5 0 5], 'yTickLabel', {'left', '0', 'right'}, 'FontSize',14)
ylabel('$\Delta$x','Interpreter','latex', 'FontSize',14)
box off
subplot(2,1,2)
plot(vel_y(t),'b', 'LineWidth',  1.7)
xlim([0 T*fs+1]); ylim([-5 5]);
ylabel('$\Delta$y','Interpreter','latex', 'FontSize',14)
set(gca,'yTick',[-5 0 5], 'yTickLabel', {'bottom', '0', 'top'}, 'FontSize',14)
set(gca,'xTick',(0:dt:T)*fs,'xTickLabel', (0:dt:T), 'FontSize',14)
xlabel('time (s)', 'FontSize', 14)
box off
saveas(gcf,[figure_dir '/eye vel x and y'],'png')

fig = figure(2);clf
plot(vel_mag(t),'k', 'LineWidth', 1.7)
xlim([0 T*fs+2]); ylim([-2 10]);
set(gca,'xTick',(dt:dt:T-1)*fs,'xTickLabel', (dt:dt:T-1), 'FontSize',14)
set(gca,'yTick',[0 5 10], 'yTickLabel', [0 5 10])
ylabel('$\Delta$d','Interpreter','latex', 'FontSize',14)
xlabel('time (s)', 'FontSize', 14)
box off
saveas(gcf,[figure_dir '/eye vel'],'png')

fig = figure(3);clf
mean_opt_flow = zscore(videoMean2(stim));
plot(mean_opt_flow(t),'Color', [1 0.5 0], 'LineWidth', 1.7)
xlim([0 T*fs+1]); ylim([-2 2]);
set(gca,'xTick',(0:dt:T-1)*fs,'xTickLabel', (0:dt:T-1), 'FontSize',14)
set(gca,'yTick',[-3 0 3], 'yTickLabel', [-3 0 3])
ylabel('optical flow (z-score)','Interpreter','latex', 'FontSize',14)
xlabel('time (s)', 'FontSize', 14)
box off
saveas(gcf,[figure_dir '/optical flow mean'],'png')

% draw illustration of eeg
select_electrode_labels = {'Fz', 'Cz','Pz', 'Oz'};
[rows] = length(select_electrode_labels); 
elec_loc_info = readLocationFile(LocationInfo(),'Acticap96.loc');
labels = elec_loc_info.channelLabelsCell;
elec_ind = [];
for i = 1:rows
    [~, elec_ind(i)] = ismember(select_electrode_labels(i),labels);
end
       
fig = figure(4);clf
s=stackedplot(x,resp(t,elec_ind),'k', 'DisplayLabels',select_electrode_labels,'FontSize',12);
xlim([0 T*fs+1])
s.XLabel = 'time (s)';
saveas(gcf,[figure_dir '/eeg graphic'],'png');

% draw illustration of 2d optical flow
pixel_pos_x = [10 20 30];
pixel_pos_y = [5 12 20];
data=[];
for i = 1:3
    data(:,i) = zscore(squeeze(stim(t,pixel_pos_y(i), pixel_pos_x(i))));
end

fig = figure(5);clf
colors = {'r','g','k'};
for i = 1:3
    subplot(3,1,i)
    plot(x,data(:,i), 'LineWidth',1.7, 'Color',colors{i});
    xlim([0 T*fs+1]); ylim([-3 3]);
    if i == 2
    ylabel('optical flow (z-score)','Interpreter','latex', 'FontSize',14)
    end
    set(gca,'xTick',(0:dt:T-1)*fs,'xTickLabel', [], 'FontSize',14)
    if i == 3
        set(gca,'xTick',(0:dt:T-1)*fs,'xTickLabel', (0:dt:T-1), 'FontSize',14)
        xlabel('time (s)', 'FontSize', 14)
    end
    box off    
end
% s.AxesProperties(i).YLimits
 saveas(gcf,[figure_dir '/optic flow graphics 2d'],'png')