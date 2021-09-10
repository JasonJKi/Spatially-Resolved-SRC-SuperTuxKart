function [src_2d, A_2d, B_2d] = compute2dTRF(stim_train, response_train, kx, ky, fs, stim_test, response_test)

if nargin < 6
    stim_test = stim_train;
    response_test = response_train;
end

[~, height, width] = size(stim_train);
[~, n_channels] = size(response_train);

src_2d = zeros(height,width,ky);
A_2d = zeros(height,width,fs+1,ky);
B_2d = zeros(height,width,n_channels,ky);
num_comp = ky;
for i = 1:height
    for ii = 1:width
        disp(['computing row #' num2str(i) ' column #' num2str(ii)]);

        x_train = videoToeplitz(squeeze(stim_train(:,i,ii)), fs);
        y_train = response_train;
        
        cca_estimator = CCA(Params(kx,  ky));
        cca_estimator.fit(x_train, y_train);
        
        x_test = videoToeplitz(stim_test(:,i,ii), fs);
        y_test = response_test;
        
        src = cca_estimator.predict(x_test, y_test);
        
        src_2d(i,ii,:) = reshape(src,1,1,num_comp);
        A_2d(i,ii,:, :) = cca_estimator.A;
        B_2d(i, ii, :, :) = cca_estimator.B;
    end
end