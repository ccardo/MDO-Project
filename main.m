format short
close all
clear all
clc

global projectDirectory
global FixedValues
global currentDesignVector
projectDirectory = cd;

% make sure that the script is run while on the correct directory
if ~contains(projectDirectory, "Project")
    warning("Current project directory is: %s\nMake sure this is intentional.", projectDirectory)
end

% add paths
addpath(projectDirectory)
addpath("Disciplines\")
addpath("Functions\")
addpath(genpath("EMWET\"))
addpath(genpath("Q3D\"))

% define all the values that are fixed during the optimization process
run init_FixedValues.m

% Initial run required to have a consistent intial design
fprintf("Defining initial configuration.\n")
run Initial_run.m
fprintf("Reference aircraft configured.\n")

% Required: Parallel Processing Toolbox
% create a new background pool (if there is none)
pool = gcp('nocreate');
if isempty(pool)
    pool = parpool(1);
end

% Initial values for the design vector

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

% Define the lower bounds for the design variables
lb = [0.9 * FixedValues.Performance.Ma_des_ref          % Ma_des
      10700                                             % h_des
      5                                                 % c_kink
      0.2                                               % taper_outboard
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
   -0.5000                                              % B5
   -0.3000                                              % B6
   -0.3000                                              % B7
      10                                                % LE_sweep
      12];                                              % b2 

% Define the upper bounds for the design variables
ub = [FixedValues.Performance.Ma_MO                     % Ma_des
      1.1 * FixedValues.Performance.h_des_ref           % h_des
      15                                                % c_kink
      1                                                 % taper_outboard
    0.3000                                              % T1
    0.3000                                              % T2
    0.3000                                              % T3
    0.3000                                              % T4
    0.5000                                              % T5 
    0.3000                                              % T6
    0.5000                                              % T7 
   -0.0500                                              % B1
   -0.0500                                              % B2
    0.0100                                              % B3
    0.0100                                              % B4
    0.0100                                              % B5
    0.1500                                              % B6
    0.1500                                              % B7
      50                                                % LE_sweep
      25];                                              % b2

% Define the design vector
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

% Normalize the bounds and the design vector
BOUNDS = struct();
BOUNDS.original = [lb ub];
ub = ub./abs(x0);
lb = lb./abs(x0);
[v0, FixedValues.Key.designVector] = normalize(x0, 'norm');
currentDesignVector = v0;

% Options for the optimization
options = optimoptions('fmincon');
options.Display                     = 'iter-detailed';
options.Algorithm                   = 'sqp';
options.FunValCheck                 = 'off';        % When turned on displays an error when the objective function or constraints return a value that is complex, NaN, or Inf. By turning it off, fmincon can handle NaN values
options.MaxIter                     = 1000;         % Maximum number of iterations
options.ScaleProblem                = true;         % Normalization of the the constraints and objective functions by their initial values
options.PlotFcn                     = {@optimplotfval, @optimplotx, @optimplotfirstorderopt, @optimplotstepsize, @optimplotconstrviolation, @optimplotfunccount};
options.FiniteDifferenceType        = 'central'; % Finite difference method used
options.FiniteDifferenceStepSize    = 5e-2; % Scalar step size factor for finite differences
options.StepTolerance               = 1e-8; % Convergence criterion: if the step taken in one iteration is lower then the tolerance than the optimization stops
options.OptimalityTolerance         = 1e-3; % Convergence criterion: first-order optimality near zero (null gradient)
options.ConstraintTolerance         = 1e-3; % Determines the contraint tolerance
options.MaxFunEvals                 = 10000; % Maximum number of function evalutations
options.OutputFcn                   = {@outConst, @outFun, @outWWing, @outInformation}; % calls functions at the end of each iteration. 

% run the optimization
optimStart = tic;
[x,FVAL,EXITFLAG,OUTPUT] = fmincon(@Optimizer, v0, [], [], [], [], lb, ub, @constraints, options);
optimEnd = toc(optimStart);

% create a non-existing folder to store the optimization's results
cd Results\
subDirName = 0;
while exist(num2str(subDirName), "dir")
    subDirName = subDirName+1;
end
subDirName = num2str(subDirName);
mkdir(subDirName)

% insert total time inside output
OUTPUT.totalTime = optimEnd;
OUTPUT;

% put the results into a struct:
ITERATIONS = iter_hist;
ITERATIONS.designVectorNorm = iter_hist.designVector;
ITERATIONS.designVector = normalize(iter_hist.designVector, "denorm", FixedValues.Key.designVector);
ITERATIONS.fval = f_hist(:)';
ITERATIONS.constraints = c_hist';
ITERATIONS.wingWeight = W_wing_hist(:)';

% store the bounds
BOUNDS.normalized = [lb, ub];
BOUNDS.original;

% save optimization run results
cd(subDirName)
save("output.mat", "OUTPUT", "-mat")         % store fmincon output
save("iterations.mat", "ITERATIONS", "-mat") % store fval, constraints, wing weight, design vector, step size, optimality, function count, constraint violation
save("bounds.mat", "BOUNDS", "-mat")         % store [lb ub] original and normalized
save("Aircraft.mat", "Aircraft", "-mat")     % store Aircraft struct
cd ..\..\

% denormalize X and f
FVAL = FVAL * FixedValues.Performance.R_ref;
final_V = normalize(x, "denorm", FixedValues.Key.designVector);

% display all of the optimization results
dispRes(final_V, FVAL, c_hist(1, end), c2(2, end), W_wing_hist(end))

% plot the results
plotRes(c_hist, f_hist, Final_V)

% save the plots in the same results folder
cd Results\
figuresDir = sprintf("%s\\figures", subDirName);
mkdir(figuresDir)
cd(figuresDir)
formats = ["pdf", "png", "fig", "svg"];
saveFigures("all", formats);
cd ..\..\