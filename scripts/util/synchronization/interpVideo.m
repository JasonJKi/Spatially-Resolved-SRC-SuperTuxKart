function timeseries_src_corrected = interpVideo(timestamp_src_corrected, timeseries_src, timestamp_ref)
[~, height, width] = size(timeseries_src);
timeseries_src_corrected = zeros(length(timestamp_ref), height,width);
for i = 1:height
    for ii = 1:width
%         disp(ii)
        timeseries = squeeze(timeseries_src(:,i,ii));
        timeseries_src_corrected(:,i,ii) = interp1(timestamp_src_corrected, timeseries, timestamp_ref, 'linear', 'extrap')';
    end
end
