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
B1 = -0.15853;          % \
B2 = -0.082473;         % |
B3 = -0.16792;          % |
B4 = -0.038631;         % } bottom CST coefficients
B5 = -0.26127;          % |
B6 = 0.075531;          % |
B7 = 0.077234;          % /
LE_sweep = 31;          % leading edge sweep [deg]
b2 = 20.81;             % outer span [m]

% bounds
% boundaries for the CST coefficients are temporary, better values needed

lb = [0.9 * FixedValues.Performance.Ma_des_ref          % Ma_des
      0.9 * FixedValues.Performance.h_des_ref           % h_des
      1                                                 % c_kink
      0.5                                               % c_tip
      -7                                                % T1
      -7                                                % T2
      -7                                                % T3
      -7                                                % T4
      -7                                                % T5
      -7                                                % T6
      -7                                                % T7
      -7                                                % B1
      -7                                                % B2
      -7                                                % B3
      -7                                                % B4
      -7                                                % B5
      -7                                                % B6
      -7                                                % B7
      10                                                % LE_sweep
      2];                                               % b2 (need better approx)

ub = [1.1 * FixedValues.Performance.Ma_des_ref          % Ma_des
      1.1 * FixedValues.Performance.h_des_ref           % h_des
      15                                                % c_kink
      5                                                 % c_tip
      7                                                 % T1
      7                                                 % T2
      7                                                 % T3
      7                                                 % T4
      7                                                 % T5
      7                                                 % T6
      7                                                 % T7
      7                                                 % B1
      7                                                 % B2
      7                                                 % B3
      7                                                 % B4
      7                                                 % B5
      7                                                 % B6
      7                                                 % B7
      50                                                % LE_sweep
      25];                                              % b2

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

ub = ub./abs(x0);
lb = lb./abs(x0);
[x0, FixedValues.Key.designVector] = normalize(x0, 'norm');
currentDesignVector = x0;

% Options for the optimization
options.Display                     = 'iter-detailed';
% options.Algorithm                 = 'sqp';
options.FunValCheck                 = 'on';
options.DiffMinChange               = 1e-6;         % Minimum change while gradient searching
options.DiffMaxChange               = 5e-2;         % Maximum change while gradient searching
options.TolCon                      = 1e-6;         % Maximum difference between two subsequent constraint vectors [c, ceq]
options.TolFun                      = 1e-6;         % Maximum difference between two subsequent objective value
options.TolX                        = 1e-6;         % Maximum difference between two subsequent design vectors
options.MaxIter                     = 1;            % Maximum iterations
options.ScaleProblem                = true;         % Normalization of the design vector
options.MaxStepSize                 = 0.001;        % Maximum change in design vector values during optimization
% options.FiniteDifferenceStepSize    = 0.001;

tic;
[x,FVAL,EXITFLAG,OUTPUT] = fmincon(@(x) Optimizer(x),x0,[],[],[],[],lb,ub,@(y) constraints(y),options);
toc;


