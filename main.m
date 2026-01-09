format short
close all
clear all
clc

% make sure to start this script in the appropriate project directory
global projectDirectory
global FixedValues
global currentDesignVector
projectDirectory = cd;

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

% Requires: Parallel Processing Toolbox
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

% lower bounds
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
   -0.3000                                              % B5
   -0.3000                                              % B6
   -0.3000                                              % B7
      10                                                % LE_sweep
      12];                                              % b2 

% upper bounds
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

% Normalize the bounds
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
options.MaxIter                     = 1000;          % Maximum number of iterations
options.ScaleProblem                = true;         % Normalization of the variables
options.PlotFcn                     = {@optimplotfval, @optimplotx, @optimplotfirstorderopt, @optimplotstepsize, @optimplotconstrviolation, @optimplotfunccount};
options.FiniteDifferenceType        = 'forward';
options.FiniteDifferenceStepSize    = 1e-1;
options.StepTolerance               = 1e-9; % Convergence criterion: if the step taken in one iteration is lower then the tolerance than the optimization stops
options.OptimalityTolerance         = 1e-3; % Convergence criterion: first-order optimality near zero (null gradient)
options.ConstraintTolerance         = 1e-3; % Determines the contraint tolerance
options.MaxFunEvals                 = 10000;
options.OutputFcn                   = {@outConst, @outFun, @outWWing, @outInformation}; % calls functions at the end of each iteration. 
% ^^^ Needs to have the following structure: stop = outFun(x, optimValues, state)
% where x is the current design vector, optimValues contains information on the optimization and state can be 'init', 'iter', 'done'. Optimization stops is stop returns true. 

optimStart = tic;
[x,FVAL,EXITFLAG,OUTPUT] = fmincon(@Optimizer, v0, [], [], [], [], lb, ub, @constraints, options);
optimEnd = toc(optimStart);

% Plot of the convergence history of the objective function 
figure('Name', 'Obj function', 'NumberTitle', 'off')
iterCount = size(c_hist, 1)-1;
plot(0:iterCount, f_hist, 'k.-', "MarkerSize", 25, "LineWidth",2)
axis tight
ylim([min(f_hist)-0.01, max(f_hist)+0.01])
title("Convergence history of the objective function")
xlabel("Iteration")
ylabel("Objective function")
grid minor

% Plots of the convergence history of the constraint functions

plotConstraints(c_hist, iterCount)

fprintf("Current directory: %s", cd)
fprintf("Current project directory: %s", projectDirectory)
disp(newline)

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

% put the results into a  struct:
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
save("output.mat", "OUTPUT", "-mat")         % fmincon output
save("iterations.mat", "ITERATIONS", "-mat") % fval, constraints, wing weight, design vector, step size, optimality, function count, constraint violation
save("bounds.mat", "BOUNDS", "-mat")         % [lb ub] original and normalized
save("Aircraft.mat", "Aircraft", "-mat") 
cd ..\..\

% denormalize X and f
FVAL = FVAL * FixedValues.Performance.R_ref;
final_V = normalize(x, "denorm", FixedValues.Key.designVector);

% display all of the optimization results
% dispRes(final_V, FVAL, c1(end), c2(end), W_wing_hist(end))

figNumbers = randi(1e9, 6, 1);

% plot airfoil geometry
Ti = final_V(5:11);
Bi = final_V(12:18);
chord = 1 - cos(linspace(0, pi/2));
[~, yt] = CSTcurve(chord, Ti);
[~, yb] = CSTcurve(chord, Bi);
thickness = yt - yb;
camber = 1/2 * (yt + yb);
Ti_ref = FixedValues.Reference_Aircraft.Wing.Airfoils(1, 1:7);
Bi_ref = FixedValues.Reference_Aircraft.Wing.Airfoils(1, 8:end);
[~, yt_ref] = CSTcurve(chord, Ti_ref);
[~, yb_ref] = CSTcurve(chord, Bi_ref);

gcf = figure(figNumbers(1));
gcf.Name = "Airfoils Equal Axes";
line(chord, yt, "Color", "k", "LineWidth", 1)
line(chord, yb, "Color", "k", "LineWidth", 1)
line(chord, yt_ref, "Color", "r", "LineStyle", "--", "LineWidth", 1)
line(chord, yb_ref, "Color", "r", "LineStyle", "--", "LineWidth", 1)
L = legend("Current Airfoil", "", "Reference Airfoil");
L.Location = "best";
L.FontSize = 15;
title("Final Airfoil", "FontSize", 15);
T = title(gcf.Name);
T.FontSize = 20;
T.FontName = "Times New Roman";
ylabel("y/c", FontSize=15)
xlabel("x/c", FontSize=15)
axis equal

gcf = figure(figNumbers(2));
gcf.Name = "Airfoils Scaled Axes";
line(chord, yt, "Color", "k", "LineWidth", 1)
line(chord, yb, "Color", "k", "LineWidth", 1)
line(chord, yt_ref, "Color", "r", "LineStyle", "--", "LineWidth", 1)
line(chord, yb_ref, "Color", "r", "LineStyle", "--", "LineWidth", 1)
L = legend("Current Airfoil", "", "Reference Airfoil");
L.Location = "best";
L.FontSize = 15;
title("Final Airfoil", "FontSize", 15);
T = title(gcf.Name);
T.FontSize = 20;
T.FontName = "Times New Roman";
ylabel("y/c", FontSize=15)
xlabel("x/c", FontSize=15)
axis normal

% plot wing planforms with and without tanks

gcf = figure(figNumbers(3));
gcf.Name = "Wing Planforms";
styleRef = {"r--", "LineWidth", 1};
styleNew = {"Color", [0.4 0.4 0.7 1], "LineWidth", 1};
plotWingGeometry(FixedValues.Reference_Aircraft.Wing.Geom, FixedValues.Reference_Aircraft.Wing.Airfoils, styleRef)
hold on
final_AC = createGeom(final_V);
plotWingGeometry(final_AC.Wing.Geom, final_AC.Wing.Airfoils, styleNew);
hold on
% plot fuel tank in the same subfigure
Boxes = loftWingBox(FixedValues.Reference_Aircraft, 20, 20, 0);
for i = 1:length(Boxes)

    surf(Boxes(i).X, Boxes(i).Y, Boxes(i).Z, ...
         'FaceColor', [1 0.8 0.8], ...
         'FaceAlpha', 0.5, ...
         'EdgeColor', 'none', ...
         "FaceLighting", "flat");
end
Boxes = loftWingBox(final_AC, 20, 20, 0);
for i = 1:length(Boxes)

    surf(Boxes(i).X, -Boxes(i).Y, Boxes(i).Z, ...
         'FaceColor', [0.5 0.5 1], ...
         'FaceAlpha', 0.3, ...
         'EdgeColor', 'none', ...
         "FaceLighting", "flat");
end
view(90, 90)
L = legend("Reference Wing", "", "", "", "", "", "", "", "", "", "Final Wing");
L.Position = [0.77 0.59 0.1 0.05];
T = title(gcf.Name);
T.FontSize = 20;
T.FontName = "Times New Roman";
xlabel X
ylabel Y
zlabel Z
hold off
axis padded


% plotting 3D wings
% little exploit, pretend that the tank is actually the whole wing to reuse
% the old loftWingBox function
FixedValues.Geometry.tank = [0 1];
FixedValues.Geometry.spars = [0 1; 0 1; 0 1];

gcf = figure(figNumbers(4));
gcf.Name = "Reference Wing Isometric View";
reference_wing3D = loftWingBox(FixedValues.Reference_Aircraft, 10, 20);
for i = 1:length(Boxes)

    surf(reference_wing3D(i).X, reference_wing3D(i).Y, reference_wing3D(i).Z, ...
        'FaceColor', [1 0.7 0.7], ...
        "FaceAlpha", 0.9, ...
         'EdgeColor', 'k', ...
         "EdgeAlpha", 0.3, ...
         "FaceLighting", "gouraud");
    hold on
    surf(reference_wing3D(i).X, -reference_wing3D(i).Y, reference_wing3D(i).Z, ...
        'FaceColor', [1 0.7 0.7], ...
         'EdgeColor', 'k', ...
         "EdgeAlpha", 0.3, ...
         "FaceLighting", "gouraud");
end
grid off
T = title(gcf.Name);
T.FontSize = 20;
T.FontName = "Times New Roman";
xlabel X
ylabel Y
zlabel Z
light
material shiny
axis equal
axis padded

gcf = figure(figNumbers(5));
gcf.Name = "Final Wing Isometric View";
final_wing3D = loftWingBox(final_AC, 10, 20);
for i = 1:length(Boxes)

    surf(final_wing3D(i).X, final_wing3D(i).Y, final_wing3D(i).Z, ...
        'FaceColor', [0.7 0.7 1], ...
         'EdgeColor', 'k', ...
         "EdgeAlpha", 0.3, ...
         "FaceLighting", "gouraud");
    hold on
    surf(final_wing3D(i).X, -final_wing3D(i).Y, final_wing3D(i).Z, ...
        'FaceColor', [0.7 0.7 1], ...
         'EdgeColor', 'k', ...
         "EdgeAlpha", 0.3, ...
         "FaceLighting", "gouraud");
end
grid off
T = title(gcf.Name);
T.FontSize = 20;
T.FontName = "Times New Roman";
xlabel X
ylabel Y
zlabel Z
light
axis equal
axis padded


gcf = figure(figNumbers(6));
gcf.Name = "Overlapped Wings Isometric View";
for i = 1:length(Boxes)

    % reference
    surf(reference_wing3D(i).X, reference_wing3D(i).Y, reference_wing3D(i).Z, ...
         'FaceColor', [1 0.7 0.7], ...
         "FaceAlpha", 0.5, ...
         'EdgeColor', 'k', ...
         "EdgeAlpha", 0.1, ...
         "FaceLighting", "flat");
    hold on
    surf(reference_wing3D(i).X, -reference_wing3D(i).Y, reference_wing3D(i).Z, ...
         'FaceColor', [1 0.7 0.7], ...
         "FaceAlpha", 0.5, ...
         'EdgeColor', 'k', ...
         "EdgeAlpha", 0.1, ...
         "FaceLighting", "flat");
    
    % final
    surf(final_wing3D(i).X, final_wing3D(i).Y, final_wing3D(i).Z, ...
         'FaceColor', [0.7 0.7 1], ...
         "FaceAlpha", 0.7, ...
         'EdgeColor', 'k', ...
         "EdgeAlpha", 0.1, ...
         "FaceLighting", "gouraud");
    surf(final_wing3D(i).X, -final_wing3D(i).Y, final_wing3D(i).Z, ...
         'FaceColor', [0.7 0.7 1], ...
         "FaceAlpha", 0.7, ...
         'EdgeColor', 'k', ...
         "EdgeAlpha", 0.1, ...
         "FaceLighting", "gouraud");
end
grid off
L = legend("Reference Wing", "", "Final Wing");
L.Position = [0.67 0.64 0.15 0.07];
T = title(gcf.Name);
T.FontSize = 20;
T.FontName = "Times New Roman";
xlabel X
ylabel Y
zlabel Z
light
axis equal
axis padded

% save the plots in the same results folder
cd Results\
figuresDir = sprintf("%s\\figures", subDirName);
mkdir(figuresDir)
cd(figuresDir)
figList = [figNumbers(:); 11; 12; 1];
formats = ["pdf", "png", "fig", "svg"];
saveFigures("all", formats);
cd ..\..\