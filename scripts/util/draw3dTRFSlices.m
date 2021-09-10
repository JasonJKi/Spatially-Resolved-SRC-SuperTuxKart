function draw3dTRFSlices(A_2d, zslice, cross_section)
[h,w,T,n] = size(A_2d);
fs = T-1;
t = 1:fs;
[X,Y,Z] = meshgrid(1:w,1:h,t);
V = A_2d(:,:,t,1);
V2 = ones(h,w,fs)*1;
V3 = ones(h,w,fs)*.2;
% slice offsets.
d = .1;
a = mean(cross_section{1}); % xslice
b = h - mean(cross_section{2}); % yslice

h1=slice(X,Y,Z,V,[],[],zslice);hold on; set(h1,'edgecolor','none')
h2=slice(X-d,Y-d,Z-d,V2,a,[],[]); set(h2,'edgecolor','none','FaceAlpha',.3)
h3=slice(X-d,Y-d,Z-d,V3,[],b,[]); set(h3,'edgecolor','none','FaceAlpha',.3)
for i = 1:length(zslice)
    z = zslice(i);
    Y = [1;h;h;1;1;];
    X = [1;1;w;w;1;];
    Z = [z;z;z;z;z];
    plot3(X,Y,Z,'LineWidth',2.5,'Color','k');
end

% cross section horizontal.
Y = [b;b;b;b;b];
X = [1;1;w;w;1];
Z = [1;30;30;1;1];
p1 = plot3(X,Y,Z,'LineWidth',3, 'Color', [0.75, 0, 0.75]);

% cross section vertical.
Y = [1;1;h;h;1];
X = [a;a;a;a;a];
Z = [1;30;30;1;1];
p2 = plot3(X,Y,Z,'LineWidth',3, 'Color', [0, .5, .5]);

%plot_thru_lines()

grid off
%xlabel('x','FontSize',14);ylabel('y','FontSize',14);
xlabel('x','FontSize',14);ylabel('y','FontSize',14);zlabel('time (ms)','FontSize',14)
xticks([]);yticks([]);xticklabels([]); yticklabels([]); 
set(gca,'ZTick', 0:5:30,'ZTickLabel',round((0:5:30)/30*1000),'fontsize',14)
zlim([0 max(zslice)+1]);
colormap jet
c_max = max(V(:));
c_min = min(V(:));
caxis([c_min c_max])
set(gca, 'CameraPosition',[106.183,-168.62,-40.0724])
end

function plot_thru_lines(A, w,h)
% cross section vertical.
y = [3 3;10 10;22 22];
x = [5 5;21 21;35 35];
z = [1 30;1 30;1 30];
color_map = [.5 .5 0 0.5; 0 .5 0 0.5; 1 .5 0 0.5]; 

[X,Y] = meshgrid(1:w,1:h);
c = colormap(jet);
C = repmat(A,[1 1 3]);
Z = ones(h,w);
img = image('CData',C)
i = I.CData;

colormap('jet');
delete(I)
C(x(1,1),y(1,1),:) = color_map(1,1:3);
C(x(2,1),y(2,1),:) = color_map(2,1:3);
C(x(2,1),y(3,1),:) = color_map(3,1:3);
%h1=slice(X,Y,Z,V,[],[]);hold on;
h1= surface(X,Y,Z,C);hold on;
% set(h1,'edgecolor','none','FaceAlpha',.2)
for i = 1:3
    a = x(i,:)+.5;
    b = y(i,:)+.5;
    c = z(i,:);
    p3 = plot3(a,b,c,'LineWidth',5, 'Color', color_map(i,1:3));
%         p3 = scatter3(x(1),y(1),z(1),300, 's','Filled', 'MarkerFaceColor', [0 0 0]);
%     set(h3,'edgecolor','none','FaceAlpha',.3)
    %     set(p3,'LineAlpha',.5)
end

end