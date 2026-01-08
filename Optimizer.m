function [f, vararg] = Optimizer(v)

global FixedValues
global Constraints
global currentDesignVector
fprintf("\n")

% if v is different than the current design vector (i.e. fmincon has
% changed it) then display the changes.
different = false;
if ~isempty(currentDesignVector)
    if v ~= currentDesignVector
        disp(v)
        different = true;
    end
end
currentDesignVector = v; % update the current design vector so the plot of the wing geometry changes only when the design vector changes

% denormalize the design vector
v = normalize(v, 'denorm', FixedValues.Key.designVector);

% get airfoil parameters (t, c) required for the plots
Ti = v(5:11);
Bi = v(12:18);
chord = 1 - cos(linspace(0, pi/2));
[~, yt] = CSTcurve(chord, Ti);
[~, yb] = CSTcurve(chord, Bi);
thickness = max(yt - yb);
camber = max(1/2 * (yt + yb));

% Generate the geometry needed for the disciplines
Aircraft = createGeom(v);

% Compute the fuel tank volume
Boxes = loftWingBox(Aircraft);
volumes = zeros(1, length(Boxes));
for i = 1:length(Boxes)
     volumes(i) = boxVolume(Boxes(i).X, Boxes(i).Y, Boxes(i).Z);
end

V = sum(volumes) * 1000; % the result is in m^3, however the fuel density is a value stored in kg/l [dm^3 = Liters]
totalFuelVolume = 2*V;

Constraints.VTank = totalFuelVolume; % required to evaluate the constraint on fuel tank volume

% plot the current geometry if the design vector has changed from one
% fucntion evaluation to another
if different

    figure(10);
    set(gcf, 'Name', 'Wing Geometry', 'NumberTitle', 'off')

    % plot wing 3D geometry
    subplot(2, 1, 1)
    plotWingGeometry(Aircraft.Wing.Geom, Aircraft.Wing.Airfoils)
    hold on
    plotWingGeometry(FixedValues.Reference_Aircraft.Wing.Geom, FixedValues.Reference_Aircraft.Wing.Airfoils, "r")
    hold on
    view(90, 90)
    xlim([0 25])
    axis equal
    title("Current Wing Geometry", FontSize=20)

    % plot fuel tank in the same subfigure
    Boxes = loftWingBox(FixedValues.Reference_Aircraft, 20, 20, 0);
    for i = 1:length(Boxes)

        surf(Boxes(i).X, Boxes(i).Y, Boxes(i).Z, ...
             'FaceColor', [1 0.8 0.8], ...
             'FaceAlpha', 0.5, ...
             'EdgeColor', 'none', ...
             "FaceLighting", "flat");
    end

    Boxes = loftWingBox(Aircraft, 20, 20, 0);
    for i = 1:length(Boxes)

        surf(Boxes(i).X, Boxes(i).Y, Boxes(i).Z, ...
             'FaceColor', [0.5 0.5 0.5], ...
             'FaceAlpha', 0.5, ...
             'EdgeColor', 'none', ...
             "FaceLighting", "flat");
    end
    hold off

    % plot airfoil in a separate subfigure
    subplot(2, 1, 2)

    Ti_ref = FixedValues.Reference_Aircraft.Wing.Airfoils(1, 1:7);
    Bi_ref = FixedValues.Reference_Aircraft.Wing.Airfoils(1, 8:end);
    [~, yt_ref] = CSTcurve(chord, Ti_ref);
    [~, yb_ref] = CSTcurve(chord, Bi_ref);

    plot(chord, yt_ref, "r", chord, yb_ref, "r")
    hold on
    plot(chord, yt, "k", chord, yb, "k")
    text(0.85, -0.05, sprintf("Thickness = %.1f%% \n Camber = %.1f%%", ...
                          thickness*100, camber*100))
    title("Current Airfoil", FontSize=20)
    legend("Reference", "", "Current")
    axis equal
    hold off

    drawnow

end


% --------------------------- RUN DISCIPLINES --------------------------- %;

unexpectedErrorCounter = 0;

try
    % initial target for coupling variable W_wing, from previous iteration
    % of from the initial run
    W_wing_i = Constraints.W_wing;
    if isnan(W_wing_i)
        W_wing_i = 60000; % if EMWET crashes, the initial guess is set to the reference value
    end

    W_wing = MDA(Aircraft, W_wing_i, v);

    if isnan(W_wing) || isempty(W_wing)
        error("Unfeasible design. Empty W_wing.") % if Loads or Structure fails return an error that is caught by the try-catch
    end
   
    % Outside of the MDA, run teh remaining disciplines
    [L_des, D_des] = Aerodynamics(Aircraft, W_wing, v);
    R = Performance(L_des, D_des, W_wing, v);

    if isnan(R)
        error("Unfeasible design. R is NaN.") % if Aerodynamics fails return an error that is caught by the try-catch
    end
    
    vararg = [W_wing, L_des, D_des];
    fprintf("W_wing = %.1f kg\n", W_wing);
    

catch ME
    
    % stop algorithm execution on unexpected error for 5 consecutive times.
    
    if contains(ME.message, "has produced an unexpected error")
        unexpectedErrorCounter = unexpectedErrorCounter + 1;
    else
        unexpectedErrorCounter = 0;
    end

    if unexpectedErrorCounter == 5 && ...
        contains(ME.message, "has produced an unexpected error")
        rethrow(ME)
    end

    warning("off", "backtrace")
    warning("Iteration Failed: Setting the Range to NaN.")
    warning("on", "backtrace")
    warning(ME.message)

    % By setting the range to NaN the algorithm knows to not 
    % explore this region of the design space without "breaking" the
    % gradient evaluation 
    R = 0; 
    
end


% Evaluate the objective function (normalized by initial range) 
f = -R / FixedValues.Performance.R_ref;


fprintf("Range = %d km\n", round(R/1000));

end