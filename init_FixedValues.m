format short

global FixedValues;
FixedValues = struct();

FixedValues.Geometry.f_tank = 0.93;             % [-]
FixedValues.Geometry.area = 363.1;              % [m^2]
FixedValues.Geometry.dihedral = 5;              % [deg]
FixedValues.Geometry.fuselageDiameter = 5.64;   % [m]
FixedValues.Geometry.b1 = 8.19;                 % [m]
FixedValues.Geometry.TE_sweep = 2.5;            % [deg]
FixedValues.Geometry.twist = [+5.2, +2.54, -2]; % [deg]
FixedValues.Geometry.tank = [0, 0.85];          % [-]
FixedValues.Geometry.spars = [0.15     0.65
                              0.15     0.65
                              0.15     0.65];   % [-]

FixedValues.Weight.rho_f = 0.81;                % [-]
FixedValues.Weight.W_f = 81651.25;              % [kg]
FixedValues.Weight.A_W = 111710;                % [kg]
FixedValues.Weight.deltaPayload = 12365;        % [kg]

FixedValues.Performance.nMax = 2.5;             % [-]
FixedValues.Performance.CT_ref = 9.21e-5;       % [-]
FixedValues.Performance.V_des_ref = 242;        % [m/s]
FixedValues.Performance.h_des_ref = 11800;      % [m]
FixedValues.Performance.CD_A_W = 0.015387;      % [-]
FixedValues.Performance.Ma_des_ref = 0.82;      % [-]
FixedValues.Performance.Ma_MO = 0.86;           % [-]
