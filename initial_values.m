
format short

% Initial values from table

% Design conditions
M_des = 0.82;
h_des = 11800;

% Top CST coefficients
T1 = 0.14863;
T2 = 0.069323;
T3 = 0.22575;
T4 = 0.040425;
T5 = 0.27305;
T6 = 0.17076;
T7 = 0.27171;

% Bottom CST coefficients
B1 = -0.15853;
B2 = -0.082473;
B3 = -0.16792;
B4 = -0.038631;
B5 = -0.26127;
B6 = 0.075531;
B7 = 0.077234;

% Geometry 
c_kink = 7.514;            % m, chord at kink
c_tip = 2.312;             % m, chord at tip
Lambda_LE = 32.00;         % degrees, leading edge sweep
b2 = 20.810;               % m

V = [M_des
     h_des
     c_kink
     c_tip
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
     Lambda_LE
     b2];
