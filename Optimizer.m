function [f, vararg] = Optimizer(v)

global FixedValues
global Constraints
global currentDesignVector
fprintf("\n")

% if v is different than the current design vector (i.e. fmincon has
% changed it) then display the changes.
different = false;
if v ~= currentDesignVector
    disp(v)
    different = true;
end
currentDesignVector = v;

v = normalize(v, 'denorm', FixedValues.Key.designVector);

% design variables
A2 = v(20);
LE_sweep = v(19);
c_kink = v(3);
taper_outboard = v(4);

% geometric fixed parameters
twist = FixedValues.Geometry.twist;
fuselage_radius = 1/2 * FixedValues.Geometry.fuselageDiameter;
dihedral = FixedValues.Geometry.dihedral;
A1 = FixedValues.Geometry.A1;

% geometric derived variables
c_tip = taper_outboard * c_kink;
x1 = 0;
x2 = (A1)*tand(LE_sweep);
x3 = (A1 + A2)*tand(LE_sweep);
y1 = 0;
y2 = A1;
y3 = A1 + A2;
z1 = -(fuselage_radius)*tand(dihedral); % --------> position on the z axis of the root leading edge. 
                                                  % The minus is a result of how we defined the frame of reference
z2 = (A1 - fuselage_radius) * tand(dihedral);
z3 = (A1 + A2 - fuselage_radius) * tand(dihedral);
c_root = A1 * tand(LE_sweep) + c_kink - A1 * tand(FixedValues.Geometry.TE_sweep); 

% Wing planform geometry 
%                     x      y      z      chord     twist
Aircraft.Wing.Geom = [x1     y1     z1     c_root    twist(1);
                      x2     y2     z2     c_kink    twist(2);
                      x3     y3     z3     c_tip     twist(3)];

S = wingArea(Aircraft.Wing.Geom);
Constraints.area = S;

% incidence angle is already considered in the first twist angle
Aircraft.Wing.inc = 0;  

% Airfoil coefficients input matrix
Ti = v(5:11);
Bi = v(12:18);
Aircraft.Wing.Airfoils = [1;1;1] * [Ti(:)', Bi(:)'];

% get airfoil parameters (t, c)
chord = 1 - cos(linspace(0, pi/2));
[~, yt] = CSTcurve(chord, Ti);
[~, yb] = CSTcurve(chord, Bi);
thickness = max(yt - yb);
camber = max(1/2 * (yt + yb));

% Spanwise location of the airfoil sections
Aircraft.Wing.eta = [0; A1/(A1+A2); 1];  

% generate wing boxes and compute their volume
Boxes = loftWingBox(Aircraft);
volumes = zeros(1, length(Boxes));
for i = 1:length(Boxes)
     volumes(i) = boxVolume(Boxes(i).X, Boxes(i).Y, Boxes(i).Z);
end

V = sum(volumes) * 1000; % [dm^3 = Liters]
totalFuelVolume = 2*V;

Constraints.VTank = totalFuelVolume;

% plot the current geometry if the thing is different
if different

    figure(10);
    set(gcf, 'Name', 'Wing Geometry', 'NumberTitle', 'off')

    % plot wing 3D geometry
    subplot(2, 1, 1)
    plotWingGeometry(Aircraft.Wing.Geom, Aircraft.Wing.Airfoils)
    hold on
    plotWingGeometry(FixedValues.Reference_Aircraft.Wing.Geom, FixedValues.Reference_Aircraft.Wing.Airfoils, "r")
    hold on
    view(90, 90)
    xlim([0 25])
    axis equal
    title("Current Wing Geometry", FontSize=20)

    % plot fuel tank in the same subfigure
    Boxes = loftWingBox(FixedValues.Reference_Aircraft, 20, 20, 0);
    for i = 1:length(Boxes)

        surf(Boxes(i).X, Boxes(i).Y, Boxes(i).Z, ...
             'FaceColor', [1 0.8 0.8], ...
             'FaceAlpha', 0.5, ...
             'EdgeColor', 'none', ...
             "FaceLighting", "flat");
    end

    Boxes = loftWingBox(Aircraft, 20, 20, 0);
    for i = 1:length(Boxes)

        surf(Boxes(i).X, Boxes(i).Y, Boxes(i).Z, ...
             'FaceColor', [0.5 0.5 0.5], ...
             'FaceAlpha', 0.5, ...
             'EdgeColor', 'none', ...
             "FaceLighting", "flat");
    end
    hold off

    % plot airfoil in a separate subfigure
    subplot(2, 1, 2)

    Ti_ref = FixedValues.Reference_Aircraft.Wing.Airfoils(1, 1:7);
    Bi_ref = FixedValues.Reference_Aircraft.Wing.Airfoils(1, 8:end);
    [~, yt_ref] = CSTcurve(chord, Ti_ref);
    [~, yb_ref] = CSTcurve(chord, Bi_ref);

    plot(chord, yt_ref, "r", chord, yb_ref, "r")
    hold on
    plot(chord, yt, "k", chord, yb, "k", "LineWidth", 2)
    text(0.85, -0.05, sprintf("Thickness = %.1f%% \n Camber = %.1f%%", ...
                          thickness*100, camber*100))
    title("Current Airfoil", FontSize=20)
    legend("Reference", "", "Current")
    axis equal
    hold off

    drawnow

end


% ------------------------------- RUN MDA ------------------------------- %;

try
    % initial target for coupling variable W_wing, from previous iteration
    W_wing_i = Constraints.W_wing;
    if isnan(W_wing_i)
        W_wing_i = 60000;
    end

    W_wing = MDA(Aircraft, W_wing_i, v);

    if isnan(W_wing) || isempty(W_wing)
        error("Unfeasible design.")
    end
   
    % Outside of the MDA, run additional disciplines
    [L_des, D_des] = Aerodynamics(Aircraft, W_wing, v);
    R = Performance(L_des, D_des, W_wing, v);
    
    % output the final optimized values and the iteration counter of the MDA
    vararg = [W_wing, L_des, D_des];
    fprintf("W_wing = %.1f kg\n", W_wing);
    

catch ME
    warning("off", "backtrace")
    warning("Iteration Failed: Setting the Range to 0.")
    warning("on", "backtrace")
    R = 0;
    warning(ME.message)
end


% Evaluate the output of the objective function
f = -R / FixedValues.Performance.R_ref;


fprintf("Range = %d km\n", round(R/1000));

end