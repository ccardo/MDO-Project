function [L_max, M_max, y_max, CDi] = Loads(Aircraft, W_wing, v, FixedValues)
    
    % global FixedValues

    h_des = v(2);
    a = airSoundSpeed(h_des);

    % determine which is the limiting factor either the V_MO or the Ma_MO
    % above the reference altitude the Ma_MO is limiting, while below it the
    % V_MO is limiting

    Ma_MO = FixedValues.Performance.Ma_MO;
    V_MO = Ma_MO * a;
    
    nMax = 2.5;
    MTOW = W_wing + FixedValues.Weight.A_W + FixedValues.Weight.W_f;
    load = nMax * MTOW * 9.81;

    rho = airDensity(h_des);
    T = airTemperature(h_des);
    mu = sutherland(T);

    q = 1/2 * rho * V_MO^2;
    S = wingArea(Aircraft.Wing.Geom);
    MAC = meanAeroChord(Aircraft.Wing.Geom);
    
    CL = load / (q * S);
    
    % At this point, the wing geometry should be already said and done.
    % So the only thing that we shall change is the Aero part.
    % Moreover, the Aircraft struct can be not retrieved as an output, so
    % the actual struct is not modified in the optimization process.
    Aircraft.Aero.CL = CL;
    Aircraft.Aero.Re = rho * V_MO * MAC / mu;
    Aircraft.Aero.V = V_MO;
    Aircraft.Aero.alt = h_des;
    Aircraft.Aero.M = Ma_MO;
    Aircraft.Aero.MaxIterIndex = 300;

    Aircraft.Visc = 0;

    % check current directory and change to Q3D
    result = changeDirSafe("Q3D");

    % SOLVE and return back to parent directory
    if result
        Res = Q3D_solver(Aircraft);
        cd ..\
    else
        error("ERROR: could not change directory to Q3D from Loads")
    end
    
    Yst = Res.Wing.Yst;
    Cl = Res.Wing.cl;
    Cm = Res.Wing.cm_c4;
    c = Res.Wing.chord;
    CDi = Res.CDiwing;
    
    % reconstruct the loads and y-station in for EMWET
    % tip value missing => fill with zeros + geometric chord
    % root value missing => fill with first element + geometric chord
    if Yst(end) ~= 1
        Yst(end+1) = Aircraft.Wing.Geom(end, 2);
        c(end+1) = Aircraft.Wing.Geom(end, 4);
        Cl(end+1) = 0;
        Cm(end+1) = 0;
    end
    if Yst(1) ~= 0
        Yst = [0; Yst(:)];
        c = [Aircraft.Wing.Geom(1, 4); c(:)];
        Cl = [Cl(1); Cl(:)];
        Cm = [Cm(1); Cm(:)];
    end
    
    y_max = Yst;
    L_max = q * Cl .* c;
    M_max = q * Cm .* c * MAC;

end