function x_t_resolved = timeResolvedWindow(x, t_window, t_slide, fs, callback)

    [n_samples, n_features] = size(x);
    t = n_samples/fs;
    n_window = floor(t-t_window)/t_slide;
    n_window_sample =  t_window*fs;
    
    if exist('callback','var')
        x_t_resolved = zeros(n_window, n_features);        
    else
        x_t_resolved = zeros(n_window, n_window_sample, n_features);
    end
    
    window = (1:n_window_sample);
    
    for i = 1:n_window
        slide_shift = (t_slide*fs) * i;
        index = window + slide_shift;
        if exist('callback','var')
            x_t_resolved(i,:,:) = callback(x(index,:));
        else
            x_t_resolved(i,:,:) = x(index,:);
        end
        
    end
end
