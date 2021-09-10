function vid_file = drawYPosTRFVideoOverXPos(A_2d, fs, output_path)

vid_file = VideoWriter(output_path,'MPEG-4');
vidFile.FrameRate = fs;
open(vid_file);
i_comp = 1;
[height, width,~,~] = size(A_2d);
for i = 1:width
    x_pos = i;
    vertical_src = squeeze(A_2d(:,x_pos,1:fs,i_comp));
    imagesc(vertical_src)
    
    if i == 1
        xTick = (0:5:fs);
        xTickLabel = round((0:5:fs)/fs*1000);
        yTick = (0:5:height);
        yTickLabel = round((height:-5:0));
        
    end
    set(gca,'xTick', xTick, 'xTickLabel', xTickLabel, 'yTick',yTick, 'yTickLabel',yTickLabel )
    xlabel('time')
    ylabel('vertical pos')
    title(['trf c1 at x position = ' num2str(i)]);
    drawnow


    drawnow
    frame = getframe(gcf);
    writeVideo(vid_file,frame);    
end
close(vid_file)