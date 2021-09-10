function src_2d = compute2DSRC(stim, resp, A, B, coeff_is_2d)

[n, height, width, ~] = size(stim);

resp = noNan(resp);
stim = noNan(stim);
h = A;
w = B;
        
fs = 30;
src_2d = [];
for i = 1:height
    for ii = 1:width
        
        % stim 
        if coeff_is_2d(1)
            h = A(:,:,i,ii);
        end
        
        % resp
        if coeff_is_2d(2)
            w = B(:,:,i,ii);
        end
        
        x = videoToeplitz(stim(:,i,ii), fs);        
        y = resp; 
        
        if isempty(h); U = x; else; U = x * h; end
        if isempty(w); V = y; else; V = y * w; end
        
        [rho, ~] = computeCorrelation(U, V);
        src_2d(i,ii,:) = rho;        
%        for iii = 1:size(A,2)                
%             u = x*A(:,iii);
%             v = y*B(:,iii);
%             src_2d(i,ii,iii) = diag(corr(u, v))';
%         end

    end
end
end

function x = noNan(x)
nanInd = isnan(x);
x(nanInd) = 0;
end