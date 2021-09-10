function rescaled_data = rescaleData(data, min_val, max_val) 
if nargin < 2
    min_val = 0;
    max_val = 1;
end
rescaled_data = (max_val-min_val)/(max(data)-min(data))*(data-max(data))+max_val;