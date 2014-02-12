function f = circle( x, y, r, c )
%Plots a circle at center x, y with radius r and color c
    hold on
    th = 0:pi/50:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    h = plot(xunit, yunit, c);
    hold off
end

