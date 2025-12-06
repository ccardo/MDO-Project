format short
close all
clear
clc

run init_FixedValues.m

global projectDirectory;
projectDirectory = cd;

% Initial values

Ma_des = 0.82;          % mach number 
h_des = 11800;          % altitude [m]
c_kink = 7.514;         % chord at the kink [m]
c_tip = 2.312;          % chord at the tip [m]
T1 = 0.14863;           % \
T2 = 0.069323;          % |
T3 = 0.22575;           % |
T4 = 0.040425;          % } top CST coefficients
T5 = 0.27305;           % |
T6 = 0.17076;           % |
T7 = 0.27171;           % /
B1 = -0.15853;         % \
B2 = -0.082473;         % |
B3 = -0.16792;          % |
B4 = -0.038631;         % } bottom CST coefficients
B5 = -0.26127;          % |
B6 = 0.075531;          % |
B7 = 0.077234;          % /
LE_sweep = 32;          % leading edge sweep [deg]
b2 = 20.81;             % outer span [m]

% bounds
lb = [0.9 * FixedValues.Performance.Ma_des_ref
      0.9 * FixedValues.Performance.h_des_ref
      1
      0.5
      -Inf
      -Inf
      -Inf
      -Inf
      -Inf
      -Inf
      -Inf
      -Inf
      -Inf
      -Inf
      -Inf
      -Inf
      -Inf
      -Inf
      10
      0];

ub = [1.1 * FixedValues.Performance.Ma_des_ref
      1.1 * FixedValues.Performance.h_des_ref
      15
      Inf
      Inf
      Inf
      Inf
      Inf
      Inf
      Inf
      Inf
      Inf
      Inf
      Inf
      Inf
      Inf
      Inf
      Inf
      50
      25];

% initial values for design vector
x0 = [Ma_des
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
      LE_sweep 
      b2];

% Options for the optimization
options.Display         = 'iter-detailed';
options.Algorithm       = 'sqp';
options.FunValCheck     = 'off';
options.DiffMinChange   = 1e-6;         % Minimum change while gradient searching
options.DiffMaxChange   = 5e-2;         % Maximum change while gradient searching
options.TolCon          = 1e-6;         % Maximum difference between two subsequent constraint vectors [c and ceq]
options.TolFun          = 1e-6;         % Maximum difference between two subsequent objective value
options.TolX            = 1e-6;         % Maximum difference between two subsequent design vectors
options.MaxIter         = 4;           % Maximum iterations

tic;
[x,FVAL,EXITFLAG,OUTPUT] = fmincon(@(x) Optimizer(x),x0,[],[],[],[],lb,ub,@(y) constraints(y),options);
toc;

% [f,vararg] = Optim_MDFGauss(x);
% NOTE: we define the objective function and the constraints as functions
% of x. This is a variable that is defined inside fmincon as the design
% vector and it is initially definde as x = x0

