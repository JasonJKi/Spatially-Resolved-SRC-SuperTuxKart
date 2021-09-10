function [src_2d] = predict2dSRC(A_2d, B_2d, stim_test, response_test, kx, ky, fs)

[~, height, width] = size(stim_test);
[~, n_channels] = size(response_test);

src_2d = zeros(height,width,ky);


for i = 1:height
    disp(['computing row #' num2str(i)]);
    
    for ii = 1:width
        
        x_test = videoToeplitz(stim_test(:,i,ii), fs);
        y_test = response_test;
        
        cca_estimator = CCA(Params(kx,  ky));
        cca_estimator.A = squeeze(A_2d(i,ii,:,:));
        cca_estimator.B = squeeze(B_2d(i,ii,:,:));
        
        src = cca_estimator.predict(x_test, y_test);
        
        src_2d(i,ii,:) = reshape(src,1,1,11);
        
    end
end
