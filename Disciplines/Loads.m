function [L_max, M_max, y_max, CDi] = Loads(Aircraft, W_wing, v, FixedValues)
    
    h_des = v(2);
    a = airSoundSpeed(h_des);

    % Here the limiting condition (either V_MO or Ma_MO would have to be
    % determined depending on the altitude, however since we slightly
    % restricted the design space to avoid issues this is not required.
    % This is because for all possible values of h_des, the limiting
    % condition is always the Ma_MO

    Ma_MO = FixedValues.Performance.Ma_MO;

    % Since the Ma_MO is limiting, the velocity is then derived from the
    % Ma_MO
    V = Ma_MO * a;
    
    % The sizing loads for the structure of the wing have to be determined
    % at the most critical loading condition, which corresponds to a load
    % factor of 2.5 
    nMax = 2.5;
    MTOW = W_wing + FixedValues.Weight.A_W + FixedValues.Weight.W_f;
    load = nMax * MTOW * 9.81;

    rho = airDensity(h_des);
    T = airTemperature(h_des);
    mu = sutherland(T);

    q = 1/2 * rho * V^2;
    S = wingArea(Aircraft.Wing.Geom);
    MAC = meanAeroChord(Aircraft.Wing.Geom);
    
    % Define the starting point for the solver as the required wing lift
    % coefficient to support the aircraft weight in the sizing condition
    CL = load / (q * S);
    
    % At this point, the wing geometry in the struct Aircraft has already
    % been defined in Optimizer.m, so the only thing that is added is 
    % the Aero part.

    Aircraft.Aero.CL = CL;
    Aircraft.Aero.Re = rho * V * MAC / mu;
    Aircraft.Aero.V = V;
    Aircraft.Aero.alt = h_des;
    Aircraft.Aero.M = Ma_MO;
    Aircraft.Aero.MaxIterIndex = 300;
    
    % To evaluate the sizing loads the viscous drag is not needed, so to
    % reduce computing time an inviscid evaluation is preferred
    Aircraft.Visc = 0;

    % check current directory and change to Q3D
    result = changeDirSafe("Q3D");

    % Run Q3D and return back to parent directory
    if result
        Res = Q3D_solver(Aircraft);
        cd ..\
    else
        error("ERROR: could not change directory to Q3D from Loads")
    end
    
    % Retrive the results from the Res struct
    Yst = Res.Wing.Yst; % spanwise position where the loads are applied
    Cl = Res.Wing.cl; % lift coefficient acting on each section defined in Yst
    Cm = Res.Wing.cm_c4; % moment coefficient defined w.r.t. the quarter chord position acting on each section defined in Yst
    c = Res.Wing.chord; % chord length at each section defined in Yst
    CDi = Res.CDiwing; % induced drag coefficient acting on each section defined in Yst
    
    % The results have to be reconstructed for EMWET since the root and tip
    % section values are missing
    % tip value missing => fill with zeros for the loads + geometric tip chord
    % root value missing => fill with first viable value (next section in the spanwise direction) for the loads + geometric root chord
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
    
    % Compute the actual forces acting on each section defined in Yst and
    % normalize the section spanwise position since this is the format
    % EMWET accepts
    y_max = Yst./(FixedValues.Geometry.A1+v(end));
    L_max = q * Cl .* c;
    M_max = q * Cm .* c * MAC;

end