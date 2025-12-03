function [] = printAirfoil(T, B)
    
    x = (1 - cos(linspace(0, pi)))/2;
    [~, yT] = CSTcurve(x, T);
    [~, yB] = CSTcurve(x, B);

    x = x(:);
    yT = yT(:);
    yB = yB(:);

    coords = [x(end:-1:2) yT(end:-1:2)
              x           yB];
    
    % check current directory to EMWET
    directory = dir();
    if contains(directory(1).folder, "Assignment")
        cd .\EMWET\
    elseif contains(directory(1).folder, "EMWET")
        cd .\
    else
        cd ..\EMWET\
    end

    fid = fopen("current_airfoil.dat", "w");
    fprintf(fid, "%.4f %.4f\n", coords');
    fclose(fid);

    cd ..\


end
