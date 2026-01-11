% load iterations
xf = ITERATIONS.designVector(:,end);
AC = createGeom(xf);
geom = AC.Wing.Geom;
airf = AC.Wing.Airfoils;

% plot thing
figNumber = 10;
figure(figNumber)
plotWingGeometry(geom, airf, "k")

%% overlapped airfoils

% load iterations
xf = ITERATIONS.designVector(:,end);
AC = createGeom(xf);
airf = AC.Wing.Airfoils;

% plot thing
figNumber = 100;
figure(figNumber)

T = xf(5:11);
B = xf(12:18);
chord = linspace(0,1,1000);
[~, yt] = CSTcurve(chord, T);
[~, yb] = CSTcurve(chord, B);

plot(chord, yt, "m")
hold on
plot(chord, yb, "m")
axis equal

%% wing box geometry

load FixedValues.mat
close

figure(1000);
reference_wing3D = loftWingBox(FixedValues.Reference_Aircraft, 10, 10);
for i = 1:1

    surf(reference_wing3D(i).X, reference_wing3D(i).Y, reference_wing3D(i).Z, ...
        'FaceColor', [0.7 0 0], ...
        "FaceAlpha", 0.9, ...
        'EdgeColor', "k", ...
        "EdgeAlpha", 1, ...
        "FaceLighting", "gouraud");
    hold on
end

grid off
T = title("Wing Tank Parametrization");
T.FontSize = 20;
T.FontName = "Times New Roman";
xlabel X
ylabel Y
zlabel Z
light
material shiny

FixedValues.Geometry.spars = [0 0.1; 0 0.15; 0 1];

figure(1000);
reference_wing3D = loftWingBox(FixedValues.Reference_Aircraft);
for i = 1:1

    surf(reference_wing3D(i).X, reference_wing3D(i).Y, reference_wing3D(i).Z, ...
        'FaceColor', [0 0 0], ...
        "FaceAlpha", 0.1, ...
        'EdgeColor', "none", ...
        "EdgeAlpha", 0.2, ...
        "FaceLighting", "gouraud");
    hold on
end
grid off
T = title("Wing Tank Parametrization");
T.FontSize = 20;
T.FontName = "Times New Roman";
xlabel X
ylabel Y
zlabel Z
light
material shiny

FixedValues.Geometry.spars = [0.7 1; 0.65 1; 0 1];

figure(1000);
reference_wing3D = loftWingBox(FixedValues.Reference_Aircraft);
for i = 1:1

    surf(reference_wing3D(i).X, reference_wing3D(i).Y, reference_wing3D(i).Z, ...
        'FaceColor', [0 0 0], ...
        "FaceAlpha", 0.1, ...
        'EdgeColor', "none", ...
        "EdgeAlpha", 0.2, ...
        "FaceLighting", "gouraud");
    hold on
end
grid off
T = title("Wing Tank Parametrization");
T.FontSize = 20;
T.FontName = "Times New Roman";
xlabel X
ylabel Y
zlabel Z
light
material shiny


ac = FixedValues.Reference_Aircraft;
plotWingGeometry(ac.Wing.Geom, ac.Wing.Airfoils, {"k", "LineWidth", 2})
axis([-0.1 13 -0.1 8.2 -1.5 1.5])

