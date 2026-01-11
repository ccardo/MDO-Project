
% before doing anything load the design vector.
run init_FixedValues.m
run Initial_run.m
x0 = [
    0.820000000000000
    11800
    7.514
    0.3077
    0.14863
    0.069323
    0.22575
    0.040425
    0.27305
    0.17076
    0.27171
    -0.15853
    -0.082473
    -0.16792
    -0.038631
    -0.26127
    0.075531
    0.077234
    31
    20.81
];
reference_AC = Aircraft;


% final aircraft
final_V;
final_AC = createGeom(final_V);

AC = {reference_AC, final_AC};
designVectors = [x0, final_V(:)];

W_wing = {ITERATIONS.wingWeight(1), ITERATIONS.wingWeight(end)};

%% plotting
lineColors = {"r", "b"};
areaColors = {[1 0.7 0.7], [0.7 0.7 1]};
for i = 1:length(AC)

    Aircraft = AC{i};
    v = designVectors(:,i);

    Aircraft.Wing.Geom(:, 3) = Aircraft.Wing.Geom(:, 3) - Aircraft.Wing.Geom(1, 3);

    % ---------------- DESIGN CONDITIONS ----------------- %
    
    h_des = v(2);
    Ma_des = v(1);
    D_A_W_q = FixedValues.Performance.D_A_W_q;
    
    % get design weight
    MTOW = W_wing{i} + FixedValues.Weight.A_W + FixedValues.Weight.W_f;
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
    
    % travel to Q3D directory and solve.
    tic;
    changeDirSafe("Q3D");
    Res = Q3D_solver(Aircraft);
    cd ..\
    toc
    
    % LIFT DISTRIBUTION
    figure(1)
    set(gcf, "Name", "Design Spanwise Lift Distribution")
    hold on
    Cl = Res.Section.Cl;
    Cd = Res.Section.Cd;
    Yst = Res.Wing.Yst;
    Y = Res.Section.Y;
    chord = Res.Wing.chord;
    
    % interpolate over Yst (so that it can be multiplied by chord length)
    CLint = interp1(Y, Cl, Yst);
    Cdint = interp1(Y, Cd, Yst);
    
    % add values for the extrema
    CLint = [CLint(1); CLint; 0];
    chord = [Aircraft.Wing.Geom(1, 4); chord; Aircraft.Wing.Geom(3, 4)];
    Yst = [0; Yst; Aircraft.Wing.Geom(3, 2)];
    Yst = Yst / max(Yst);
    line(Yst, CLint.*chord, "Color", lineColors{i}, "LineWidth", 2)
    area(Yst, CLint.*chord, ...
        "FaceColor", areaColors{i}, ...
        "EdgeColor", "none", ...
        "FaceAlpha", 0.5)
    title("Design Spanwise Lift Distribution c * Cl", ...
        "FontSize", 20, ...
        "FontName", "Times New Roman")

    % VISCOUS DRAG DISTRIBUTION
    figure(2)
    set(gcf, "Name", "Spanwise Drag Distribution")
    hold on
    Cdint = [Cdint(1); Cdint; 0];
    line(Yst, Cdint.*chord, "Color", lineColors{i}, "LineWidth", 2)
    area(Yst, Cdint.*chord, ...
        "FaceColor", areaColors{i}, ...
        "EdgeColor", "none", ...
        "FaceAlpha", 0.5)
    title("Spanwise Drag Distribution c * Cd", ...
        "FontSize", 20, ...
        "FontName", "Times New Roman")
    
    % INDUCED DRAG DISTRIBUTION
    figure(3)
    set(gcf, "Name", "Spanwise Induced Drag Distribution")
    hold on
    Cdi = Res.Wing.cdi;
    Cdi = [Cdi(1); Cdi; 0];
    line(Yst, Cdi.*chord, "Color", lineColors{i}, "LineWidth", 2)
    area(Yst, Cdi.*chord, ...
        "FaceColor", areaColors{i}, ...
        "EdgeColor", "none", ...
        "FaceAlpha", 0.5)
    title("Spanwise Induced Drag Distribution c * Cdi", ...
        "FontSize", 20, ...
        "FontName", "Times New Roman")

    % VISCOUS (PROFILE + WAVE) DRAG DISTRIBUTION
    figure(4)
    set(gcf, "Name", "Spanwise Viscous Drag Distribution")
    hold on
    Cdv = Cdint - Cdi;
    line(Yst, Cdv.*chord, "Color", lineColors{i}, "LineWidth", 2)
    area(Yst, Cdv.*chord, ...
        "FaceColor", areaColors{i}, ...
        "EdgeColor", "none", ...
        "FaceAlpha", 0.5)
    title("Spanwise Viscous Drag Distribution c * Cdv", ...
        "FontSize", 20, ...
        "FontName", "Times New Roman")


    % ---------------- CRITICAL CONDITIONS ----------------- %

    Ma_MO = FixedValues.Performance.Ma_MO;
    V_MO = Ma_MO * a;
    
    nMax = 2.5;
    MTOW = W_wing{i} + FixedValues.Weight.A_W + FixedValues.Weight.W_f;
    load = nMax * MTOW * 9.81;

    rho = airDensity(h_des);
    T = airTemperature(h_des);
    mu = sutherland(T);

    q = 1/2 * rho * V_MO^2;
    S = wingArea(Aircraft.Wing.Geom);
    MAC = meanAeroChord(Aircraft.Wing.Geom);
    
    CL = load / (q * S);
    
    Aircraft.Aero.CL = CL;
    Aircraft.Aero.Re = rho * V_MO * MAC / mu;
    Aircraft.Aero.V = V_MO;
    Aircraft.Aero.alt = h_des;
    Aircraft.Aero.M = Ma_MO;
    Aircraft.Aero.MaxIterIndex = 300;
    Aircraft.Visc = 0;

    % travel to Q3D directory and solve.
    tic;
    changeDirSafe("Q3D");
    ResCrit = Q3D_solver(Aircraft);
    cd ..\
    toc

    Clcrit = ResCrit.Wing.ccl; 
    Clcrit = [Clcrit(1); Clcrit; 0];
    chordcrit = ResCrit.Wing.chord; 
    chordcrit = [Aircraft.Wing.Geom(1, 4); chordcrit; Aircraft.Wing.Geom(3, 4)];
    ystcrit = ResCrit.Wing.Yst;
    ystcrit = [0; ystcrit; Aircraft.Wing.Geom(3, 2)];
    ystcrit = ystcrit / max(ystcrit);

    figure(5)
    set(gcf, "Name", "Critical Spanwise Lift Distribution")
    hold on
    line(ystcrit, Clcrit.*chordcrit, "Color", lineColors{i}, "LineWidth", 2)
    area(ystcrit, Clcrit.*chordcrit, ...
        "FaceColor", areaColors{i}, ...
        "EdgeColor", "none", ...
        "FaceAlpha", 0.5)
    title("Critical Spanwise Lift Distribution c * Cl", ...
        "FontSize", 20, ...
        "FontName", "Times New Roman")
    

end

for f = 1:5
    
    figure(f)
    grid on
    L = legend("Initial Wing", "", "Final Wing");
    L.FontSize = 14;
    L.Location = "best";
    xlabel("Spanwise position", "FontSize", 14)
    ylabel("Value", "FontSize", 14)
    pbaspect([3 1 1])

end