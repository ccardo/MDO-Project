function [] = printAirfoil(T, B)
    
    x = (1 - cos(linspace(0, pi)))/2;
    [~, yT] = CSTcurve(x, T);
    [~, yB] = CSTcurve(x, B);

    x = x(:);
    yT = yT(:);
    yB = yB(:);

    coords = [x(end:-1:2) yT(end:-1:2)
              x           yB];

    % print airfoil coords and return to parent directory
    fid = fopen("current_airfoil.dat", "w");
    fprintf(fid, "%.4f %.4f\n", coords');
    fclose(fid);

end
