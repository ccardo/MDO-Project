function [MAC] = meanAeroChord(geom)
    
    cR = geom(1, 4);
    cK = geom(2, 4);
    cT = geom(3, 4);
    
    yR = geom(1, 2);
    yK = geom(2, 2);
    yT = geom(3, 2);

    y1 = linspace(yR, yK);
    y2 = linspace(yK, yT);

    c1 = interp1([yR yK], [cR cK], y1);
    c2 = interp1([yK yT], [cK cT], y2);
    
    y = [y1(:); y2(:)];
    c = [c1(:); c2(:)];
    A = wingArea(geom);

    MAC = 2/A * trapz(y, c.^2);

end