format short
close all
clc


global projectDirectory
global Constraints
projectDirectory = cd;

% add paths
addpath(projectDirectory)
addpath("Disciplines\")
addpath("Functions\")
addpath(genpath("EMWET\"))
addpath(genpath("Q3D\"))

run init_FixedValues.m

% Load the optimized design vector
load("C:\Users\ronch\Documents\MATLAB\MDO-Project\Results\3\optDesignVector.mat")
load("C:\Users\ronch\Documents\MATLAB\MDO-Project\Results\3\objHistory.mat")

N = 10; % number of different optimized designs checked

% Perturb slightly the design vector and check if any better solutions are
% found
for i = 1:N
    for k = 1:length(final_V)
        r = 0.98 + (1.02 - 0.98 ) * rand;
        new_V(k) = final_V(k) *r;
    end
    
    v = new_V';
    
    % get airfoil parameters (t, c)
    Ti = v(5:11);
    Bi = v(12:18);
    chord = 1 - cos(linspace(0, pi/2));
    [~, yt] = CSTcurve(chord, Ti);
    [~, yb] = CSTcurve(chord, Bi);
    thickness = max(yt - yb);
    camber = max(1/2 * (yt + yb));
    
    % geometry creation in this function
    Aircraft = createGeom(v);
    
    % generate wing boxes and compute their volume
    Boxes = loftWingBox(Aircraft);
    volumes = zeros(1, length(Boxes));
    for l = 1:length(Boxes)
         volumes(l) = boxVolume(Boxes(l).X, Boxes(l).Y, Boxes(l).Z);
    end
    
    V = sum(volumes) * 1000; % [dm^3 = Liters]
    totalFuelVolume = 2*V;
    
    Constraints.VTank = totalFuelVolume;

    W_wing_i = 37317.2;
    W_wing = MDA(Aircraft, W_wing_i, v);

    if isnan(W_wing) || isempty(W_wing)
        error("Unfeasible design. Empty W_wing.")
    end
    [L_des, D_des] = Aerodynamics(Aircraft, W_wing, v);
    R = Performance(L_des, D_des, W_wing, v);

    if isnan(R)
        error("Unfeasible design. R is NaN.")
    end

    f_new = -R;
    [c,~] = constraints();
    if c(1) < 0 && c(2) < 0
        if f_new < f_hist(end) && isreal(f_new)
            fprintf('Improved objective function of %f for the following design vector:\n', f_new)
            improved_V = new_V;
            disp(improved_V)
            pause(5)
        else
            fprintf('Original optimized deisgn is better\n')
        end
    else
        fprintf('New design vector does not respect the constraints\n')
    end
end