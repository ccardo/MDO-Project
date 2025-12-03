format short

global FixedValues;
FixedValues = struct();

FixedValues.Geometry.dihedral = 5;              % [deg]
FixedValues.Geometry.fuselageDiameter = 5.64;   % [m]
FixedValues.Geometry.b1 = 8.19;                 % [m]
FixedValues.Geometry.TE_sweep = 2.5;            % [deg]
FixedValues.Geometry.twist = [+5.2, +2.54, -2]; % [deg]
FixedValues.Geometry.tank = [0, 0.85];          % [-]
FixedValues.Geometry.spars = [0.1       0.7
                              0.13404   0.7
                              0.2       0.6];   % [-]

FixedValues.Weight.W_f = 81651.25;              % [kg]
FixedValues.Weight.A_W = 111710;                % [kg]
FixedValues.Weight.deltaPayload = 12365;        % [kg]

FixedValues.Performance.nMax = 2.5;             % [-]
FixedValues.Performance.CT_ref = 1.8639e-4;     % [-]
FixedValues.Performance.V_des_ref = 242;        % [m/s]
FixedValues.Performance.h_des_ref = 11800;      % [m]
FixedValues.Performance.CD_A_W = 0.015387;      % [-]
FixedValues.Performance.Ma_des_ref = 0.82;      % [-]