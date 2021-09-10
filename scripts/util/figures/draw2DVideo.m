function vid_file = draw2DVideo(src_2d, A_2d, output_path, fs, n_comp)


for i_comp = 1:n_comp
    val = A_2d(:,:,:,i_comp);
    c_max(i_comp) = max(val(:));
    c_min(i_comp) = min(val(:));
end

if size(src_2d) > 3
    src_2d = mean(src_2d,4);
end

vid_file = VideoWriter(output_path,'MPEG-4');
vidFile.FrameRate = fs;
open(vid_file);
for i_t = 1:fs
    
    if i_t == 1
        for i_comp = 1:n_comp
            
            ha = subplot(2,3,i_comp);
            imagesc(src_2d(:,:,i_comp));
%             axis off
            title(['c' num2str(i_comp)])
            if i_comp ==1
                ylabel('stimulus-response correlation')
            end
            set(gca,'xTickLabel',[],'YTickLabel', [])           
            axis image
           colormap jet

        end
    end

    t = (i_t/fs)*1000;
    for i_comp = 1:n_comp
        subplot(2,3,i_comp+3)   
        img = A_2d(:,:,i_t,i_comp);
        imagesc(img)
        axis image

        if i_comp == 2
            xlabel(['t=' num2str(round(t)) 'ms'])
        end
        if i_comp ==1
            ylabel('temporal response')
%             colorbar('eastoutside')
        end
        set(gca,'xTickLabel',[],'YTickLabel', [])
        caxis([c_min(i_comp) c_max(i_comp)])
%         colorbar('eastoutside')
        colormap jet
    end
    
    drawnow
    frame = getframe(gcf);
    writeVideo(vid_file,frame);    
end
close(vid_file)
