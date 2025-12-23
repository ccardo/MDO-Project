format short
close all
clear
clc
warning("on", "backtrace")

global projectDirectory
global FixedValues
global currentDesignVector
projectDirectory = cd;

% add paths
addpath(projectDirectory)
addpath("Disciplines\")
addpath("Functions\")
addpath(genpath("EMWET\"))
addpath(genpath("Q3D\"))

run init_FixedValues.m

% Initial values

Ma_des = 0.82;              % mach number 
h_des = 11800;              % altitude [m]
c_kink = 7.514;             % chord at the kink [m]
taper_outboard = 0.3077;    % taper ratio outboard
c_tip = 2.312;              % chord at the tip [m]
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
A2 = 20.81;                 % outer span [m]

% bounds
lb = [0.9 * FixedValues.Performance.Ma_des_ref          % Ma_des
      11700                                             % h_des
      3                                                 % c_kink
      0.1                                               % taper_outboard
    0.0500                                              % T1
    0.0100                                              % T2
    0.0100                                              % T3
    0.0100                                              % T4
    0.0100                                              % T5
    0.1500                                              % T6
    0.1500                                              % T7
   -0.3000                                              % B1
   -0.3000                                              % B2
   -0.3000                                              % B3
   -0.3000                                              % B4
   -0.3000                                              % B5
   -0.3000                                              % B6
   -0.3000                                              % B7
      10                                                % LE_sweep
      12];                                               % b2 

ub = [FixedValues.Performance.Ma_MO                     % Ma_des
      1.1 * FixedValues.Performance.h_des_ref           % h_des
      15                                                % c_kink
      1                                                 % taper_outboard
    0.3000                                              % T1
    0.3000                                              % T2
    0.3000                                              % T3
    0.3000                                              % T4
    0.3000                                              % T5
    0.3000                                              % T6
    0.3000                                              % T7
   -0.0500                                              % B1
    0.0100                                              % B2
    0.0100                                              % B3
    0.0100                                              % B4
    0.0100                                              % B5
    0.1500                                              % B6
    0.1500                                              % B7
      50                                                % LE_sweep
      25];                                              % b2

% initial values for design vector
x0 = [Ma_des
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

% Normalize the bounds
ub = ub./x0;
lb = lb./abs(x0);
[x0, FixedValues.Key.designVector] = normalize(x0, 'norm');
currentDesignVector = x0;

% Options for the optimization
options = optimoptions('fmincon');
options.Display                     = 'iter-detailed';
options.Algorithm                   = 'sqp';
options.FunValCheck                 = 'on';
options.MaxIter                     = 100;           % Maximum iterations
options.ScaleProblem                = true;         % Normalization of the design vector
options.UseParallel                 = false;
options.PlotFcn                     = {@optimplotfval,@optimplotx,@optimplotfirstorderopt,@optimplotstepsize, @optimplotconstrviolation, @optimplotfunccount};
options.FiniteDifferenceType        = 'forward';
options.FiniteDifferenceStepSize    = 5e-3;
options.StepTolerance               = 1e-6; % Convergence criteria: if the step taken in one iteration is lower than the tolerance than the optimization stops
options.FunctionTolerance           = 1e-6; % Convergence criteria: if the change in teh objective function in one iteration is lower than the tolerance than the optimization stops
options.OutputFcn                   = {@outConst, @outFun}; % calls the function at the end of each iteration. Needs to have the following structure: stop = outFun(x, otimValues, state)
% where x is the current design vector, optimValues contains information on the optimization and state can be 'init', 'iter', 'done'. Optimization stops is stop returns true. 

tic;
[x,FVAL,EXITFLAG,OUTPUT] = fmincon(@(x) Optimizer(x), x0, [], [], [], [], lb, ub, @(y) constraints(y), options);
toc;

% Display the optimization results

disp('Optimization Results:')
fprintf('Function Value at Optimal Design: %.3f', FVAL)

% Plot of the convergence history of the objective function 
figure(11)
set(gcf, 'Name', 'Obj function', 'NumberTitle', 'off')
plot(f_hist, 'ro-', 'MarkerFaceColor', 'k', "LineWidth",2)
title("Convergence history of the objective function")
xlabel("Iteration")
ylabel("Objective function")

% Plots of the convergence history of each single constraint function
figure(12)
set(gcf, 'Name', 'Constraints', 'NumberTitle', 'off')
c1 = c_hist(:,1);
c2 = c_hist(:,2);
plot(c1, "Color", 'ro-', 'MarkerFaceColor', 'k', "LineWidth",2)
hold on
plot(c2, "Color", 'bo-', 'MarkerFaceColor', 'k', "LineWidth",2)
title("Convergence history of the constraints")
xlabel("Iteration")
ylabel("Constraint value")
legend("Constraint on wing loading", "Constraint on fuel tank volume")
hold off
