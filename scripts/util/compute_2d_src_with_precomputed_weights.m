function [src_2d, h_2d] = compute_2d_src_with_precomputed_weights(stim, resp)

[n, height, width, ~] = size(stim);

fs = 30;
h_2d = []; 
src_2d = [];
y = resp;

for i = 1:height
    for ii = 1:width
        
        x = stim(:,i,ii);
        
        x = videoToeplitz(x,fs); %stimulus toeplitz
        h = inv(x'*x+mean(eig(x'*x))*eye(size(x,2)))*(x'*y);
        
        y_hat = x*h;
        
        h_2d(:, :, i, ii) = h;
        src_2d(i,ii,:) = diag(corr(y_hat, y))';
%         disp([i, ii])        
    end
end