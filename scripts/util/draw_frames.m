function draw_frames(video, optical_flow, frame_index)
n_frames = length(frame_index); 
for i = 1:n_frames
    ind = frame_index(i);
    img = squeeze(video(ind,:,:,:));
    flow = optical_flow(ind);

    hPlot = subplot(1, n_frames, i); hold on
    imshow(img)
    plt = plot(flow,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
    q = findobj(plt,'type','Quiver');
    q.Color = 'r';
    q.LineWidth = 1;

%     cbar = colorbar('southoutside');
%     colormap jet
     set(gca,'yTickLabel', [], 'xTickLabel', [])
     axis image
end