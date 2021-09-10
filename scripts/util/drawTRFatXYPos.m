function drawTRFatXYPos(A, x_pos, y_pos, line_color)
% cross section vertical.

for i = 1:length(x_pos)
    j = y_pos(i);
    k = x_pos(i);
    y = squeeze(A(j,k,1:30));
    hold on
    plot(1:30,y,'Color',line_color(i,:),'LineWidth',2.5)
    legend_str{i} = ['(x=' num2str(k) ', y=' num2str(j) ')'];
    y_max(i) = max(y);
    y_min(i) = min(y);    
end

y_max = max(y_max(:));
y_min = min(y_min(:));
abs_max = max(abs([y_max y_min]));
y_lim = [-abs_max abs_max];
y_tick = [-abs_max 0 abs_max];
ylim(y_lim*1.2)
% ylabel('a.u.','FontSize',14);
set(gca,'YTick', y_tick,'YTickLabel',{'min', 'a.u. 0', 'max'},'fontsize',16)

set(gca,'XTick', 0:5:30,'XTickLabel',round((0:5:30)/30*1000),'fontsize',16)
xlim([1 30])
xlabel('time (ms)','FontSize',16);
grid on
% legend(legend_str,'FontSize',16);
% legend boxoff