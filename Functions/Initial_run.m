% Script runs the first iteration that ensures a consistent initial design 

global FixedValues
global Constraints

% Initial values for the design variables

Ma_des = 0.82;              % mach number [-]
h_des = 11800;              % altitude [m]
c_kink = 7.514;             % chord at the kink [m]
taper_outboard = 0.3077;    % taper ratio outboard [-]
T1 = 0.14863;               % \
T2 = 0.069323;              % |
T3 = 0.22575;               % |
T4 = 0.040425;              % } top CST coefficients [-]
T5 = 0.27305;               % |
T6 = 0.17076;               % |
T7 = 0.27171;               % /
B1 = -0.15853;              % \
B2 = -0.082473;             % |
B3 = -0.16792;              % |
B4 = -0.038631;             % } bottom CST coefficients [-]
B5 = -0.26127;              % |
B6 = 0.075531;              % |
B7 = 0.077234;              % /
LE_sweep = 31;              % leading edge sweep [deg]
A2 = 20.81;                 % outer span [m]

% Define the design vector
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

% Define the geometry of the wing required by the aerodynamic solver
Aircraft = createGeom(v);
S = wingArea(Aircraft.Wing.Geom);

% Set the reference aircraft in FixedValues
FixedValues.Reference_Aircraft = Aircraft;

% compute fuel tank volume
Boxes = loftWingBox(Aircraft, 20, 20); % from the geometry of the wing 
% defined for Q3D, obtain the coordinates of the vertices of the fuel tank 
% inside the wing. For simplicity, this box is divided into two boxes that
% correspond to the fuel tank section in the outer wing trapezoid and the
% inner wing trapezoid.

% Initialize the array containing the volume of all boxes that make up the 
% fuel tank (in our case that is 2)
volumes = zeros(size(Boxes, 1), 1); 
makePlot = 0;
for i = 1:length(Boxes)
    volumes(i) = boxVolume(Boxes(i).X, Boxes(i).Y, Boxes(i).Z); % [m^3] Given the coordinates of the vertices, computes the volume 
end

% Compute the total volume of the fuel tank present in a half-wing
V = sum(volumes) * 1000; %  the output of this function is in [m^3], however the fuel density value is saved in [l/m^3], so to ensure consistency in evaluating the constraints the following conversion is made [dm^3 = Liters]
totalFuelVolume = 2*V; % variable V accounts only for the tank volume of one half-wing

% Save the value to compute the constraints for the initial design
Constraints.VTank = totalFuelVolume;

% Evaluate a consistent initial value for the wing weight, given the
% reference maximum take-off weight
disp("[MDA] Running Q3D & EMWET...")
MTOWi = 230000;

% Compute the required initial guess for the wing weight
W_wing_i = MTOWi - FixedValues.Weight.A_W - FixedValues.Weight.W_f;
[L_max, M_max, y_max] = Loads(Aircraft, W_wing_i, v, FixedValues); 
W_wing = Structures(Aircraft, L_max, M_max, y_max, W_wing_i, v, FixedValues);
Constraints.W_wing = W_wing;

% update A-W weight
W_A_W_new = MTOWi - W_wing - FixedValues.Weight.W_f;
FixedValues.Weight.A_W = W_A_W_new;


% run aero ONCE to get the right D_A_W_q
[~, ~, D_ref_wing] = Aerodynamics(Aircraft, W_wing, v);

% compute A-W drag / q_inf at reference design conditions
rho = airDensity(h_des);
FixedValues.Performance.V_des_ref = airSoundSpeed(h_des) * Ma_des;
q_des_ref = 1/2 * rho * FixedValues.Performance.V_des_ref^2;
D_A_W_new = q_des_ref * S * FixedValues.Performance.CD_ref - D_ref_wing;

% save the value since it stays constant throughout the optimization
% process
FixedValues.Performance.D_A_W_q = D_A_W_new / q_des_ref;

% run aero once again to find the actual D_res and L_res for the intial
% design
[L_des, D_des, ~] = Aerodynamics(Aircraft, W_wing, v);

% compute the initial range
R = Performance(L_des, D_des, W_wing, v);
FixedValues.Performance.R_ref = R;
fprintf("initial R = %d km\n", round(R/1000));

% Evaluate the initial constraints
[c, eq] = constraints();
if c(1) < 0
    fprintf("Wing loading constraint respected with c1 = %.2f \n", c(1))
else
    fprintf("Wing loading constraint violated with c1 = %.2f \n", c(1));
end

if c(2) < 0
    fprintf("Fuel tank volume constraint respected with c2 = %.2f \n", c(2))
else
    fprintf("Fuel tank volume constraint violated with c2 = %.2f \n", c(2));
end
