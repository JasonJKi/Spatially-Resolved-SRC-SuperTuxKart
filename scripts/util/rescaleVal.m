function vrescaled = rescaleVal(val, lower, upper)
vrescaled = ((val - min(val(:))) * (upper - lower) ./ (max(val(:)) - min(val(:)))) + lower;
