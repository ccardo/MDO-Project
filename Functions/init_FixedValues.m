
global FixedValues;

% initialize the struct that keeps all the values which stay constant
% during the optimization
FixedValues = struct();

% geometric variables
FixedValues.Geometry.f_tank = 0.93;             % [-] geometric factor to account for the wing-tank volume occupied by structural elements, fuel systems, unusable fuel, gas, etc
FixedValues.Geometry.area = 363.1;              % [m^2] reference planform area
FixedValues.Geometry.dihedral = 5;              % [deg] reference dihedral angle
FixedValues.Geometry.A1 = 8.19;                 % [m] reference half-span of the inboard trapezoid element
FixedValues.Geometry.TE_sweep = 2.5;            % [deg] reference trailing edge sweep of the inboard trapezoid element
FixedValues.Geometry.twist = [+5.2, +2.54, -2]; % [deg] reference twist defined at the three sections which define the geometry of the wing (i.e. root, kink and tip)
FixedValues.Geometry.tank = [0, 0.85];          % [-] position, as a percentage of the total half-span, where the fuel tank starts and ends
FixedValues.Geometry.spars = [0.10     0.70
                              0.15     0.65
                              0.15     0.65];   % [-] chordwise position, 
% as a percentage of the corresponding chord, of the front spar 
% (first column) and the rear spar (second column) at the three sections 
% which define the geometry of the wing (i.e. root, kink and tip)

% Variables related to mass, obtained from the reference aircraft
FixedValues.Weight.rho_f = 0.81;                % [l/m^3] Fuel density 
FixedValues.Weight.W_f = 85765;                 % [kg] Fuel weight
FixedValues.Weight.A_W = 115940;                % [kg] Aircraft-less-Wing weight (this is just the intial guess)
FixedValues.Weight.deltaPayload = 12365;        % [kg] Maximum payload minus the design payload, used to compute the MZF in structures
FixedValues.Weight.MTOW_ref = 230000;           % [kg] Maximum Take-off weight

% Variables related to aircraft performance
FixedValues.Performance.nMax = 2.5;             % [-] Maximum load factor
FixedValues.Performance.CT_ref = 9.21e-5;       % [-] specific fuel consumption for the reference aircraft engine when operating at Vcr_ref and hcr_ref  
FixedValues.Performance.CD_ref = 3.27e-2;       % [-] aircraft drag coefficient of the reference aircraft
FixedValues.Performance.V_des_ref = 242;        % [m/s] design flight speed of the reference aircraft
FixedValues.Performance.h_des_ref = 11800;      % [m] design altitude of the reference aircraft
FixedValues.Performance.D_A_W_q = 5.4375;       % [-] Aircraft-less-Wing 
% drag force divided by the reference dynamic pressure at cruise. This 
% value stays constant throughout the optimization, however this is jsut 
% an initial guess that is then updated in the initial run which ensure a 
% consistent intial design

FixedValues.Performance.Ma_des_ref = 0.82;      % [-] design Mach number of the reference aircraft
FixedValues.Performance.Ma_MO = 0.86;           % [-] maximum operating Mach number of the reference aircraft
FixedValues.Performance.V_MO = 168.3;           % [m/s] maximum operating flight speed of the reference aircraft

