
global FixedValues;
FixedValues = struct();

FixedValues.Geometry.f_tank = 0.93;             % [-]
FixedValues.Geometry.area = 363.1;              % [m^2]
FixedValues.Geometry.dihedral = 5;              % [deg]
FixedValues.Geometry.fuselageDiameter = 5.64;   % [m]
FixedValues.Geometry.A1 = 8.19;                 % [m]
FixedValues.Geometry.TE_sweep = 2.5;            % [deg]
FixedValues.Geometry.twist = [+5.2, +2.54, -2]; % [deg]
FixedValues.Geometry.tank = [0, 0.85];          % [-]
FixedValues.Geometry.spars = [0.10     0.70
                              0.15     0.65
                              0.15     0.65];   % [-]

FixedValues.Weight.rho_f = 0.81;                % [-]
FixedValues.Weight.W_f = 85765;                 % [kg]
FixedValues.Weight.A_W = 87478;                 % [kg]
FixedValues.Weight.deltaPayload = 12365;        % [kg]

FixedValues.Performance.nMax = 2.5;             % [-]
FixedValues.Performance.CT_ref = 9.21e-5;       % [-]
FixedValues.Performance.CD_ref = 3.27e-2;       % [-]
FixedValues.Performance.V_des_ref = 242;        % [m/s]
FixedValues.Performance.h_des_ref = 11800;      % [m]
FixedValues.Performance.D_A_W_q = 5.4375;       % [-]
FixedValues.Performance.Ma_des_ref = 0.82;      % [-]
FixedValues.Performance.Ma_MO = 0.86;           % [-]
FixedValues.Performance.V_MO = 168.3;           % [m/s] EAS
FixedValues.Performance.h_MO = 10700;           % [m]

% to get the reference aircraft geometry
fprintf("Defining initial configuration.\n")
run Initial_run.m
fprintf("Reference aircraft configured.\n")