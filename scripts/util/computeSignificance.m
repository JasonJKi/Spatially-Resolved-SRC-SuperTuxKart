function [p_val_2d, h_2d, img_2d_surrogate] = computeSignificance(src, src_shuffled)

% num_components = 3;
% num_shuffles = size(src_shuffled,4);
[height, width, num_components, num_shuffles] = size(src_shuffled);
for iii = 1:num_components
    for i = 1:height
        for ii = 1:width
            
            x = mean(squeeze(src(i,ii,iii)));
            img_2d_all_avg(i,ii,iii) = x;
            data = squeeze(src_shuffled(i,ii,iii,:));
            img_2d_surrogate(i, ii,iii) = mean(src_shuffled(i,ii,iii,:));
            
            p_ = (sum(x > data)/length(data));% + 1/num_shuffles;
            p_2d_(i, ii,iii) = 1-p_;
            
            mu = mean(data);
            sigma = std(data);
            p = 1 - normcdf(x, mu, sigma);
            p_2d(i, ii,iii) = p;
            h_2d(i, ii ,iii) = p < .05 ;
        end
    end
    p_ = p_2d(:, :,iii);
    [corrected_h, ~,~, corrected_p] = fdr_bh(p_(:), .05);
    p_2d_corrected(:,:,iii) = reshape(corrected_p, [height, width]);
    h_2d_corrected(:,:,iii) = reshape(corrected_h, [height, width]);
end

p_val_2d = p_2d_corrected;
h_2d = h_2d_corrected;