format short
close all
clear
clc

global projectDirectory
global FixedValues
global Constraints

projectDirectory = cd;

% Initial values

Ma_des = 0.82;              % mach number 
h_des = 11800;              % altitude [m]
c_kink = 7.514;             % chord at the kink [m]
taper_outboard = 0.3077;    % taper ratio outboard
T1 = 0.14863;               % \
T2 = 0.069323;              % |
T3 = 0.22575;               % |
T4 = 0.040425;              % } top CST coefficients
T5 = 0.27305;               % |
T6 = 0.17076;               % |
T7 = 0.27171;               % /
B1 = -0.15853;              % \
B2 = -0.082473;             % |
B3 = -0.16792;              % |
B4 = -0.038631;             % } bottom CST coefficients
B5 = -0.26127;              % |
B6 = 0.075531;              % |
B7 = 0.077234;              % /
LE_sweep = 31;              % leading edge sweep [deg]
A2 = 20.81;                 % outer span [m]

% initial values for design vector
v = [Ma_des
      h_des
      c_kink 
      taper_outboard
      T1 
      T2 
      T3 
      T4 
      T5 
      T6 
      T7 
      B1 
      B2 
      B3 
      B4 
      B5 
      B6 
      B7 
      LE_sweep 
      A2];

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

Aircraft.Wing.inc = 0;  % incidence angle is already considered in the first twist angle


% Airfoil coefficients input matrix
Ti = v(5:11);
Bi = v(12:18);
Aircraft.Wing.Airfoils = [1;1;1] * [Ti(:)', Bi(:)'];

% Spanwise location of the airfoil sections
Aircraft.Wing.eta = [0; A1/(A1+A2); 1];  

% SET REFERENCE AIRCRAFT IN FIXED VALUES
FixedValues.Reference_Aircraft = Aircraft;
% SET REFERENCE AIRCRAFT IN FIXED VALUES

Boxes = loftWingBox(Aircraft, 20, 20);
volumes = zeros(size(Boxes, 1), 1);
makePlot = 0;
for i = 1:length(Boxes)
    
    volumes(i) = boxVolume(Boxes(i).X, Boxes(i).Y, Boxes(i).Z); % [m^3]

    % if makePlot
    %     surf(Boxes(i).X, Boxes(i).Y, Boxes(i).Z, ...
    %          'FaceColor', [0.8 0.8 1], ...
    %          'EdgeColor', "k", ...
    %          'FaceAlpha', 0.7, ...
    %          "FaceLighting", "flat");
    % 
    %     axis equal
    %     hold on
    % end
end

% plotWingGeometry(Aircraft.Wing.Geom, Aircraft.Wing.Airfoils)

V = sum(volumes) * 1000; % [dm^3 = Liters]
totalFuelVolume = 2*V;

Constraints.VTank = totalFuelVolume;

% ------------------------------- RUN MDA ------------------------------- %;


% initial target for coupling variable W_wing
disp("[MDA] Running Q3D & EMWET...")
MTOWi = 230000;
W_wing_i = MTOWi - FixedValues.Weight.A_W - FixedValues.Weight.W_f;
[L_max, M_max, y_max] = Loads(Aircraft, W_wing_i, v); 
W_wing = Structures(Aircraft, L_max, M_max, y_max, W_wing_i, v);

W_A_W_new = 230000 - W_wing - FixedValues.Weight.W_f;

% Outside of the MDA, run additional disciplines
[L_des, D_des] = Aerodynamics(Aircraft, W_wing, v);
R = Performance(L_des, D_des, W_wing, v);

% output the final optimized values and the iteration counter of the MDA
vararg = [W_wing, L_des, D_des];

% Evaluate the output of the objective function
f = -R;

fprintf("R = %d km", round(R/1000));
disp(newline);

% Evaluate the constraints

[c, eq] = constraints();
if c(1) < 0
    fprintf("Wing loading constraint respected with c1 = %.2f \n", c(1))
else
    fprintf("Wing loading constraint violated with c1 = %.2f \n", c(2));
end

if c(2) < 0
    fprintf("Fuel tank volume constraint respected with c2 = %.2f \n", c(2))
else
    fprintf("Fuel tank volume constraint violated with c2 = %.2f \n", c(2));
end