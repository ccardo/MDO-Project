format short
close all
clear
clc

run init_FixedValues.m

global projectDirectory
global FixedValues
global currentDesignVector
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
b2 = 20.81;                 % outer span [m]

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
      b2];

[v, FixedValues.Key.designVector] = normalize(v, 'norm');
currentDesignVector = v;

global FixedValues;
global Constraints;

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


Aircraft.Wing.inc = 0;  % incidence angle is already considered in the first twist angle

% Airfoil coefficients input matrix
Ti = v(5:11);
Bi = v(12:18);
Aircraft.Wing.Airfoils = [1;1;1] * [Ti(:)', Bi(:)'];

Aircraft.Wing.eta = [0; A1/(A1+A2); 1];  % Spanwise location of the airfoil sections

Boxes = loftWingBox(Aircraft, 20, 20, 1);
volumes = zeros(size(Boxes, 1), 1);
makePlot = 1;
for i = 1:length(Boxes)
    
    volumes(i) = boxVolume(Boxes(i).X, Boxes(i).Y, Boxes(i).Z); % [m^3]

    if makePlot
        surf(Boxes(i).X, Boxes(i).Y, Boxes(i).Z, ...
             'FaceColor', [0.8 0.8 1], ...
             'EdgeColor', "k", ...
             'FaceAlpha', 0.7, ...
             "FaceLighting", "flat");
    
        axis equal
        hold on
    end
end

plotWingGeometry(Aircraft.Wing.Geom, Aircraft.Wing.Airfoils)

V = sum(volumes) * 1000; % [dm^3 = Liters]
totalFuelVolume = 2*V;

% ------------------------------- RUN MDA ------------------------------- %;

% try
    % initial target for coupling variable MTOW
    MTOWi = 230000;
    MTOW = MDA(Aircraft, MTOWi, v);
    
    % Outside of the MDA, run additional disciplines
    [L_des, D_des] = Aerodynamics(Aircraft, MTOW, v);
    R = Performance(L_des, D_des, MTOW, v);
    
    % output the final optimized values and the iteration counter of the MDA
    vararg = [MTOW, L_des, D_des];

% catch
%     warning("Iteration Failed: Setting the Range to 0.")
%     R = 0;
% 
% end


% Evaluate the output of the objective function
f = -R;

fprintf("R = %d km", round(R/1000));
disp(newline);
disp(f)
