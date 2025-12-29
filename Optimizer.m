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
currentDesignVector = v;

v = normalize(v, 'denorm', FixedValues.Key.designVector);

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
for i = 1:length(Boxes)
     volumes(i) = boxVolume(Boxes(i).X, Boxes(i).Y, Boxes(i).Z);
end

V = sum(volumes) * 1000; % [dm^3 = Liters]
totalFuelVolume = 2*V;

Constraints.VTank = totalFuelVolume;

% plot the current geometry if the thing is different
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


try
    % initial target for coupling variable W_wing, from previous iteration
    W_wing_i = Constraints.W_wing;
    if isnan(W_wing_i)
        W_wing_i = 60000;
    end

    W_wing = MDA(Aircraft, W_wing_i, v);

    if isnan(W_wing) || isempty(W_wing)
        error("Unfeasible design.")
    end
   
    % Outside of the MDA, run additional disciplines
    [L_des, D_des] = Aerodynamics(Aircraft, W_wing, v);
    R = Performance(L_des, D_des, W_wing, v);

    if isnan(R)
        error("R is NaN.")
    end
    
    % output the final optimized values and the iteration counter of the MDA
    vararg = [W_wing, L_des, D_des];
    fprintf("W_wing = %.1f kg\n", W_wing);
    

catch ME
    warning("off", "backtrace")
    warning("Iteration Failed: Setting the Range to NaN.")
    warning("on", "backtrace")
    R = NaN; % By setting the range to NaN the algorithm knows to not 
    % explore this region of the design space without "breaking" the
    % gradient evaluation (which occurs if R is set to zero)
    warning(ME.message)
end


% Evaluate the output of the objective function (normalized by 10 000 km)
f = -R / FixedValues.Performance.R_ref;


fprintf("Range = %d km\n", round(R/1000));

end