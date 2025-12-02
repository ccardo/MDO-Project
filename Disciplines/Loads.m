function [L_max, M_max, y_max] = Loads(Aircraft, MTOW, v)

    h_des = v(2);
    Ma_MO = v(1) + 0.04;

    nMax = 2.5;
    load = nMax * MTOW * 9.81;
    
    a = airSoundSpeed(h_des);
    rho = airDensity(h_des);
    T = airTemperature(h_des);
    mu = sutherland(T);

    V_MO = a * Ma_MO;
    q = 1/2 * rho * V_MO^2;
    A = wingArea(Aircraft.Wing.Geom);
    MAC = meanAeroChord(Aircraft.Wing.Geom);
    
    CL = load / (q * A);
    
    % At this point, the wing geometry should be already said and done.
    % So the only thing that we shall change is the Aero part.
    % Moreover, the Aircraft struct can be not retrieved as an output, so
    % the actual struct is not modified in the optimization process.
    Aircraft.Aero.CL = CL;
    Aircraft.Aero.Re = rho * V_MO * MAC / mu;
    Aircraft.Aero.V = V_MO;
    Aircraft.Aero.alt = h_des;
    Aircraft.Aero.M = Ma_MO;
    Aircraft.Aero.MaxIterIndex = 200;

    Aircraft.Visc = 0;

    cd ..\Q3D\
    Res = Q3D_solver(Aircraft);
    cd ..\Disciplines\
    
    Yst = Res.Wing.Yst;
    Cl = Res.Wing.cl;
    Cm = Res.Wing.cm_c4;
    c = Res.Wing.chord;
    
    % reconstruct the loads and y-station in for EMWET
    % tip value missing => fill with zeros + geometric chord
    % root value missing => fill with first element + geometric chord
    if Yst(end) ~= 1
        Yst(end+1) = AC.Wing.Geom(end, 2);
        c(end+1) = AC.Wing.Geom(end, 4);
        Cl(end+1) = 0;
        Cm(end+1) = 0;
    end
    if Yst(1) ~= 0
        Yst = [0; Yst(:)];
        c = [AC.Wing.Geom(1, 4); c(:)];
        Cl = [Cl(1); Cl(:)];
        Cm = [Cm(1); Cm(:)];
    end
    
    y_max = Yst;
    L_max = q * Cl .* c;
    M_max = q * Cm .* c.^2;

    
end