function [start_time, end_time] = manualTimeIndexingFromPlot()
pause; 
[x, ~] = ginput(2);

start_time = x(1);
end_time = x(2);

