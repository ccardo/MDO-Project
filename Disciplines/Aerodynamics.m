function [L_des, D_des, Aircraft] = Aerodynamics(Aircraft, v)

    h_des = v(2);
    Ma_des = v(1);

    % get design weight
    W_f = Aircraft.Weight.Fuel;
    MTOW = Aircraft.Weight.MTOW;
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

    Aircraft.Visc = 1;

    cd ..\Q3D\
    Res = Q3D_solver(Aircraft);
    cd ..\Disciplines\

    L_des = q * A * Res.CLwing;
    D_des = q * A * Res.CDwing;

end