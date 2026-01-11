format short
close all
clc

global projectDirectory
global Constraints
projectDirectory = cd;

run init_FixedValues.m
run Initial_run.m

% Load the optimized design vector
load("C:\Users\ronch\Documents\MATLAB\MDO-Project\Results\3\optDesignVector.mat")
load("C:\Users\ronch\Documents\MATLAB\MDO-Project\Results\3\objHistory.mat")

N = 1000; % number of different designs checked around the optimum design

% Perturb slightly the design vector and check if any better solutions are
% found

for i = 1:N
    for k = 1:length(final_V)
        r = 0.99 + (1.01 - 0.99 ) * rand; % generate a random perturbation ranging from -1% to +1%
        new_V(k) = final_V(k) *r; % define the test design vector
    end
    
    v = new_V';
    
    % Generate the geometry needed for the disciplines
    Aircraft = createGeom(v);
    
    % Compute the fuel tank volume
    Boxes = loftWingBox(Aircraft);
    volumes = zeros(1, length(Boxes));
    for l = 1:length(Boxes)
         volumes(l) = boxVolume(Boxes(l).X, Boxes(l).Y, Boxes(l).Z);
    end
    
    V = sum(volumes) * 1000; % [dm^3 = Liters]
    totalFuelVolume = 2*V; % take into account the tanks in the two wings
    
    Constraints.VTank = totalFuelVolume; % required to evaluate the constraint on fuel tank volume

    W_wing_i = 28000; % initial guess for the wing weight based on the optimized design
    W_wing = MDA(Aircraft, W_wing_i, v); % run both the Loads and Structures disciplines

    if isnan(W_wing) || isempty(W_wing)
        continue % if either Loads or Structure fails, skip the iteration
    end

    % run the remaining disciplines
    [L_des, D_des] = Aerodynamics(Aircraft, W_wing, v);
    R = Performance(L_des, D_des, W_wing, v);

    if isnan(R)
        continue % if aerodynamics fails, skip the iteration
    end

    f_new = -R;
    [c,~] = constraints(); % evaluate the constraint functions
    if c(1) < 0 && c(2) < 0 % if both constraints are inactive
        if f_new < f_hist(end) && isreal(f_new) && isreal(W_wing) % if the perturbed design has found a better optimum
            fprintf('Improved objective function of %f for the following design vector:\n', f_new)
            improved_V = new_V;
            disp(improved_V)
            pause(5) % Pause to check the improved design
        else
            fprintf('Original optimized deisgn is better\n')
        end
    else
        fprintf('New design vector does not respect the constraints\n')
    end
end