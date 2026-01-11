function [] = plotRes(c_hist, f_hist, final_V)

global FixedValues

% Plot of the convergence history of the objective function
iterCount = size(f_hist, 1)-1;
figure('Name', 'Obj function', 'NumberTitle', 'off')
plot(0:iterCount, f_hist, 'k.-', "MarkerSize", 25, "LineWidth",2)
axis tight
ylim([min(f_hist)-0.01, max(f_hist)+0.01])
title("Convergence history of the objective function")
xlabel("Iteration")
ylabel("Objective function")
grid minor

% Plot the convergence history of the constraint functions
figure('Name', 'Constraints', 'NumberTitle', 'off')
c1 = c_hist(:,1);
c2 = c_hist(:,2);
plot(0:iterCount, c1, 'r.-', 'MarkerSize', 20, "LineWidth", 2)
hold on
plot(0:iterCount, c2, 'b.-', 'MarkerSize', 20, "LineWidth", 2)
yl = [1e-3 , min(c_hist, [], "all")-0.02 , min(c_hist, [], "all")-0.02, 1e-3];  
patch([0, 0, iterCount, iterCount], yl, 'green', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
axis tight
ylim([min(c_hist, [], "all")-0.02, max(c_hist, [], "all")+0.05])
title("Convergence history of the constraints")
xlabel("Iteration")
ylabel("Constraint value")
L = legend("Constraint on wing loading", "Constraint on fuel tank volume");
L.FontSize = 15;
L.Location = "best";
hold off
grid minor

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

gcf = figure('Name', 'Airfoils Equal Axes', 'NumberTitle', 'off');
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

gcf = figure('Name', 'Airfoils Scaled Axes', 'NumberTitle', 'off');
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

gcf = figure('Name', 'Wing Planforms', 'NumberTitle', 'off');
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
FixedValues.Geometry.tank = [0 1];
FixedValues.Geometry.spars = [0 1; 0 1; 0 1];

gcf = figure('Name', 'Reference Wing Isometric View', 'NumberTitle', 'off');
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

gcf = figure('Name', 'Final Wing Isometric View', 'NumberTitle', 'off');
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

gcf = figure('Name', 'Overlapped Wings Isometric View', 'NumberTitle', 'off');
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
