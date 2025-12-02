function A = wingArea(geom)
    
    cR = geom(1, 4);
    cK = geom(2, 4);
    cT = geom(3, 4);
    
    yR = geom(1, 2);
    yK = geom(2, 2);
    yT = geom(3, 2);

    B1 = cR;
    B2 = cK;
    B3 = cT;

    h1 = yK - yR;
    h2 = yT - yK;

    A1 = 1/2 * h1 * (B1 + B2);
    A2 = 1/2 * h2 * (B2 + B3);

    A = 2 * (A1 + A2);

end