function [src_2d, h_2d] = compute_2d_src_by_trf(stim,resp)
[n, height, width, ~] = size(stim);
[n, n_channels] = size(resp);
fs = 30;
h_2d = zeros(fs+1,n_channels,height,width);
src_2d = zeros(height,width,n_channels);
for i = 1:height
    for ii = 1:width
        y = resp;
        x = stim(:,i,ii);
        x = videoToeplitz(x,fs); %stimulus toeplitz
        h = inv(x'*x+mean(eig(x'*x))*eye(size(x,2)))*(x'*y);
        y_hat = x*h;
        h_2d(:,:,i,ii) = h;
        src_2d(i,ii,:) = diag(corr(y_hat, y))';
%         disp([i, ii])
    end
end