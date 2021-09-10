function [timeseries_struct_resampled_1, timeseries_struct_resampled_2] = alignTimeseriesLength(timeseries_struct_1, timeseries_struct_2,  fs_target)
% Align the data so that, they have same sampling rate and matching length.
fs_target = round(fs_target);

timeseries1 = double(timeseries_struct_1.timeseries);
timeseries_1_out = timeseries1;
if fs_target ~= timeseries_struct_1.fs
    [~, h, w] = size(timeseries1);
    for i = 1:h
        for ii = 1:w
            timeseries = resample(timeseries1(:,i,ii), fs_target,  timeseries_struct_1.fs);
            if (i == 1) && (ii == 1)
                timeseries_1_out = zeros(length(timeseries), h, w);
            end
            timeseries_1_out(:,i,ii) = timeseries;
        end
    end
end

timeseries2 = double(timeseries_struct_2.timeseries);
if fs_target ~= timeseries_struct_2.fs
    timeseries_2_out = resample(double(timeseries2),  fs_target,  timeseries_struct_2.fs);
end

[timeseries1, timeseries2] = cutSamplesToEvenLength(timeseries_1_out, timeseries_2_out);

timeseries_struct_resampled_1.timeseries = timeseries1;
timeseries_struct_resampled_1.fs = fs_target;

timeseries_struct_resampled_2.timeseries = timeseries2;
timeseries_struct_resampled_2.fs = fs_target;

end