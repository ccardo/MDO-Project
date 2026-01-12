function [] = dispRes(x, FVAL, c1, c2, W_wing)

format short
global FixedValues

% retrieve the optimized  geometric variables
A2 = x(20);
LE_sweep = x(19);
c_kink = x(3);
taper_outboard = x(4);

% obtain the geometric fixed parameters
twist = FixedValues.Geometry.twist;
dihedral = FixedValues.Geometry.dihedral;
A1 = FixedValues.Geometry.A1;

% compute the geometric derived variables
c_tip = taper_outboard * c_kink;
x1 = 0;
x2 = (A1)*tand(LE_sweep);
x3 = (A1 + A2)*tand(LE_sweep);
y1 = 0;
y2 = A1;
y3 = A1 + A2;
z1 = 0; 
z2 = (A1 ) * tand(dihedral);
z3 = (A1 + A2) * tand(dihedral);
c_root = A1 * tand(LE_sweep) + c_kink - A1 * tand(FixedValues.Geometry.TE_sweep); 

% Define the wing planform geometry for Q3D 
%                     x      y      z      chord     twist
Aircraft.Wing.Geom = [x1     y1     z1     c_root    twist(1);
                      x2     y2     z2     c_kink    twist(2);
                      x3     y3     z3     c_tip     twist(3)];

S = wingArea(Aircraft.Wing.Geom);

% incidence angle is already considered in the first twist angle
Aircraft.Wing.inc = 0;  

% Airfoil coefficients input matrix for Q3D
Ti = x(5:11);
Bi = x(12:18);
Aircraft.Wing.Airfoils = [1;1;1] * [Ti(:)', Bi(:)'];

% Spanwise location of the airfoil sections
Aircraft.Wing.eta = [0; A1/(A1+A2); 1];

% Display the required results for the optimized design

% Objective function value
fprintf('Objective function value for the optimized result: %f \n', FVAL)

% All design variables of the optimized design
fprintf(['Design variables of the optimized design \n Ma_des = %f \n h_des = %f [m] \n c_kink = %f [m] \n' ...
    ' taper_outboard = %f \n T1 = %f \n T2 = %f \n T3 = %f \n T4 = %f \n T5 = %f \n T6 = %f \n T7 = %f \n' ...
    ' B1 = %f \n B2 = %f \n B3 = %f \n B4 = %f \n B5 = %f \n B6 = %f \n B7 = %f \n LE_sweep = %f \n A2 = %f\n'], x)

% All constraints

fprintf('Wing loading constraint value for the optimized design: %.3f \n',c1 * (FixedValues.Weight.MTOW_ref/FixedValues.Geom.area)
fprintf('Fuel tank volume constraint value for the optimized design: %.3f \n',c2 *((FixedValues.Weight.W_f/rho_fuel)/1e3))

% Wfuel (fuel weight) 
fprintf('Fuel weight of the optimized design: %.1f [kg] \n', FixedValues.Weight.W_f)

% WTO_max (maximum takeoff weight) 
MTOW_opt = W_wing + FixedValues.Weight.A_W + FixedValues.Weight.W_f;
fprintf('Maximum takeoff weight of the optimized design: %.2f [kg] \n', MTOW_opt)

% Wstr_wing (wing structure weight) 
fprintf('Structural wing weight of the optimized design: %.2f [kg] \n', W_wing)

% WCO2 (mass of emitted CO2 during mission)  
W_CO2 = 3.16 * FixedValues.Weight.W_f;
fprintf('Mass of emitted CO2 during mission for the optimized design: %.2f [kg] \n', W_CO2)

% Vfuel (fuel volume)  
Fuel_v = FixedValues.Weight.W_f/(1000 * FixedValues.Weight.rho_f);
fprintf('Fuel volume for the optimized design: %.2f [m^3] \n', Fuel_v)

% Vtank (wing tank capacity) 
Boxes = loftWingBox(Aircraft);
volumes = zeros(1, length(Boxes));
for i = 1:length(Boxes)
     volumes(i) = boxVolume(Boxes(i).X, Boxes(i).Y, Boxes(i).Z);
end

V = sum(volumes);
V_tank = 2*V;
fprintf('Wing tank capacity for the optimized design: %.2f [m^3] \n', V_tank)

% V, h, Mach, dynamic pressure and Reynolds number @design point 
rho = airDensity(x(2));
mu = sutherland(airTemperature(x(2)));
V_des = airSoundSpeed(x(2)) * x(1);
MAC = meanAeroChord(Aircraft.Wing.Geom);
fprintf('Design flight velocity for the optimized design: %.2f [m/s] \n', V_des)
fprintf('Design flight altitude for the optimized design: %.2f [m] \n', x(2))
fprintf('Design Mach number for the optimized design: %.3f \n', x(1))
q = 1/2 * rho * V_des^2;
fprintf('Dynamic pressure in the design condition for the optimized design: %.2f [Pa]\n', q)
Re = rho * V_des * MAC / mu;
fprintf('Reynolds number in the design condition for the optimized design: %.2f \n', Re)

% CT (specific fuel consumption) and η (propulsion efficiency factor) @design point 
V_des_ref = FixedValues.Performance.V_des_ref;
h_des_ref = FixedValues.Performance.h_des_ref;
CT_ref = FixedValues.Performance.CT_ref;
eta = exp( -(V_des - V_des_ref)^2/(2*70^2) + ...
               -(x(2) - h_des_ref)^2/(2*2500^2) );
fprintf('Propulsion efficiency factor η in the design condition for the optimized design: %f \n', eta)
CT = CT_ref / eta;
fprintf('Specific fuel consumption in the design condition for the optimized design: %f [N/Ns] \n', CT)

% CL (aircraft lift coefficient) and α (aircraft angle of attack) @design point 
% Run the viscous aerodynamic solver once to obtain the relevant forces
% acting on the otimized design
[L_des, D_des, D_des_wing, alpha] = Aerodynamics(Aircraft, W_wing, x);
fprintf('Angle of attack in the design condition for the optimized design: %.4f [deg] \n', alpha)
CL_des = L_des/(q*S);
fprintf('Aircraft lift coefficient in the design condition for the optimized design: %f \n', CL_des)

% CD,wing (wing drag coefficient) and its component CDi,wing (wing induced drag coefficient) @design point 
CD_des_wing = D_des_wing/(q*S);
fprintf('Wing drag coefficient in the design condition for the optimized design: %f \n', CD_des_wing)
[~,~,~,CDi] = Loads(Aircraft, W_wing, x, FixedValues);
fprintf('Wing induced drag coefficient in the design condition for the optimized design: %f \n', CDi)

% CL/CD (aircraft aerodynamic efficiency)  @design point 
CD_des = D_des/(q*S);
fprintf('Aircraft aerodynamic efficiency in the design condition for the optimized design: %f \n', CL_des/CD_des)

% D A-W (aircraft-less-wing drag force) @design point 
D_A_W = FixedValues.Performance.D_A_W_q * q;
fprintf('Aircraft-less-wing drag force in the design condition for the optimized design: %.2f [N] \n', D_A_W)

% CD,A-W (aircraft-less-wing drag force coefficient) @design point 
CD_A_W = D_A_W/ (q*S);
fprintf('Aircraft-less-wing drag force coefficient in the design condition for the optimized design: %f \n', CD_A_W)

% WA-W (aircraft-less-wing-and-fuel weight) 
fprintf('Aircraft-less-wing-and-fuel weight for the optimized design: %.2f [kg] \n', FixedValues.Weight.A_W)

% S (wing area), MAC (Mean Aerodynamic Chord), WTO_max/S (wing loading), 
% AR (aspect ratio) for the whole wing, and LE sweep angle, chords and 
% span for each wing trapezoidal element. 

fprintf('Wing area for the optimized design: %.2f [m^2] \n', S)
fprintf('Mean Aerodynamic Chord for the optimized design: %.3f [m] \n', MAC)
fprintf('Wing loading for the optimized design: %.3f [Pa] \n', MTOW_opt/S)
AR = ((2 * (A1 + A2))^2)/S;
fprintf('Aspect ratio for the optimized design: %.3f \n', AR)

fprintf('Root chord for the optimized design: %.3f [m] \n', c_root)
fprintf('Kink chord for the optimized design: %.3f [m] \n', c_kink)
fprintf('Tip chord for the optimized design: %.3f [m] \n', c_tip)
fprintf('Inboard semi-span for the optimized design: %.3f [m] \n', A1)
fprintf('Inboautboard semi-span for the optimized design: %.3f [m] \n', A2)