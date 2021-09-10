classdef FigureConfig

    properties 
        conditionStr = {'Active Play', 'Sham Play', 'Passive Viewing', 'Counting'};
        conditionStrXTick = {'  Active\newline   Play', ...
        ' Sham\newline  Play', ...
        'Passive\newlineViewing', 'Counting'};

        conditionColor = {[1 0 0],[0 0 1], [0 .75 0], [.2 .2 .2]};
        barColor =  {[.75 .2 .2],[.2 .2 .75], [.2 .75 .2], [.2 .2 .2]};
        deceptionColor = {[0.7 0.7 0.7], [.9 .9 .9 ]}; 

        textSizeXAxis = 10;
        textSizeYAxis = 12;
        textSizeYLabel = 12;

        subjectColor = [.85 .75 .65];
        errorBarColor = [.65 .75 .86];
        
        erpColor = [.1 .2 .3];
        panelLabel = char(65:90);
        textSizeXLabel = 12;
        textSizePanelTitle = 13;
        textSizeLegend = 12;
        textSizeXPos = 12
        subfigure_textsize = 15;
    end
    
    methods
        function this = FigureConfig()
            
        end
    end
    
    
end