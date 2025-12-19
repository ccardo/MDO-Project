function [f, vararg] = Optimizer(v)

global FixedValues;
global Constraints;
global currentDesignVector;


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


% plot the current geometry if the thing is different
if different

    figure("Current Wing Geometry")
    title("Current Wing Geometry", FontSize=20)
    plotWingGeometry(Aircraft.Wing.Geom, Aircraft.Wing.Airfoils)
    hold on
    
    % plot fuel tank
    Boxes = LoftWingBox(Aircraft, 20, 20, 0);
    for i = 1:length(Boxes)

        surf(Boxes(i).X, Boxes(i).Y, Boxes(i).Z, ...
             'FaceColor', [0.8 0.8 1], ...
             'EdgeColor', "k", ...
             'FaceAlpha', 0.7, ...
             "FaceLighting", "flat");
    
        axis equal
        hold on
    end
    hold off

    figure("Current Airfoil")
    title("Current Airfoil", FontSize=20)

end
%

% ------------------------------- RUN MDA ------------------------------- %;

try
    % initial target for coupling variable MTOW
    MTOWi = 230000;
    MTOW = MDA(Aircraft, MTOWi, v);
   
    % Outside of the MDA, run additional disciplines
    [L_des, D_des] = Aerodynamics(Aircraft, MTOW, v);
    R = Performance(L_des, D_des, MTOW, v);
    
    % output the final optimized values and the iteration counter of the MDA
    vararg = [MTOW, L_des, D_des];

catch
    warning("Iteration Failed: Setting the Range to 0.")
    R = 0;

end


% Evaluate the output of the objective function
f = -R;

fprintf("MTOW = %d kg", MTOW);
fprintf("Range = %d km", round(R/1000));
disp(newline);

end