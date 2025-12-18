function [L_des, D_des, Aircraft] = Aerodynamics(Aircraft, MTOW, v)

    global FixedValues

    h_des = v(2);
    Ma_des = v(1);
    D_A_W_q = FixedValues.Performance.D_A_W_q;

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
    S = wingArea(Aircraft.Wing.Geom);
    MAC = meanAeroChord(Aircraft.Wing.Geom);
    
    CL = load / (q * S);

    % Wing geometry defined inside Aircraft.Wing
    Aircraft.Aero.CL = CL;
    Aircraft.Aero.Re = rho * V_des * MAC / mu;
    Aircraft.Aero.V = V_des;
    Aircraft.Aero.alt = h_des;
    Aircraft.Aero.M = Ma_des;
    Aircraft.Aero.MaxIterIndex = 200;

    Aircraft.Visc = 1;

    % check current directory and change to Q3D
    result = changeDirSafe("Q3D");

    if result
        % run Q3D and display
        disp("[AER] Running Q3D...")
        tic
        Res = Q3D_solver(Aircraft);
        finish = toc;
        disp("[AER] Time elapsed: " + finish)
        cd ..\
    else
        error("ERROR: could not change directory to Q3D from Aerodynamics")
    end

    L_des = q * S * Res.CLwing;
    D_des = q * (S * Res.CDwing + D_A_W_q);
    if isnan(D_des) % added in case Q3D visc diverges due to transonic conditions
       D_des = Inf;
    end

end