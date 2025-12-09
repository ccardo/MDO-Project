function [L_des, D_des, Aircraft] = Aerodynamics(Aircraft, MTOW, v)

    global FixedValues;

    h_des = v(2);
    Ma_des = v(1);
    CD_A_W = FixedValues.Performance.CD_A_W;

    % get design weight
    W_f = FixedValues.Weight.W_f;
    W_des = sqrt(MTOW * (MTOW-W_f));
    load = W_des * 9.81;

    a = airSoundSpeed(h_des);
    rho = airDensity(h_des);
    T = airTemperature(h_des);
    mu = sutherland(T);

    V_des = a * Ma_des;
    q = 1/2 * rho * V_des^2;
    A = wingArea(Aircraft.Wing.Geom);
    MAC = meanAeroChord(Aircraft.Wing.Geom);
    
    CL = load / (q * A);

    % Wing geometry defined inside Aircraft.Wing
    Aircraft.Aero.CL = CL;
    Aircraft.Aero.Re = rho * V_des^2 * MAC / mu;
    Aircraft.Aero.V = V_des;
    Aircraft.Aero.alt = h_des;
    Aircraft.Aero.M = Ma_des;
    Aircraft.Aero.MaxIterIndex = 200;

    Aircraft.Visc = 1;

    % check current directory and change to Q3D
    result = changeDirSafe("Q3D");

    % SOLVE and return back to parent directory
    if result
        disp('Running Q3D visc')
        tic
        Res = Q3D_solver(Aircraft);
        toc
        %cd ..\
    else
        error("ERROR: could not change directory to Q3D from Aerodynamics")
    end

    L_des = q * A * Res.CLwing;
    D_des = q * A * (Res.CDwing + CD_A_W);

end