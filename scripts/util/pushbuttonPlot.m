function [c] =  pushbuttonPlot(fig)
ax = axes(fig);
ax.Units = 'pixels';
ax.Position = [50 50 100 100];
c = uicontrol;
c.String = 'Plot Data';
c.Callback = @plotButtonPushed;

    function button_pressed = plotButtonPushed(src,event)
        button_pressed = true;
    end
end