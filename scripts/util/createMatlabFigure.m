function fig = createMatlabFigure(figure_number, width, height, units)
fig = figure(figure_number);
set(fig, 'Units', units, 'Position', [0, 0, width, height], 'PaperUnits', units, 'PaperSize', [width, height])
%  set(fig, 'Units', units, 'PaperUnits', units, 'PaperSize', [width, height])