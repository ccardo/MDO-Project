function [f, vararg] = Optimizer(v)

global FixedValues;
global Constraints;
global currentDesignVector;


% if v is different than the current design vector (i.e. fmincon has
% changed it) then display the changes.
if v ~= currentDesignVector
    disp(v)
end

currentDesignVector = v;

v = normalize(v, 'denorm', FixedValues.Key.designVector);

% design variables
A2 = v(20);
LE_sweep = v(19);
c_kink = v(3);
taper_outboard = v(4);


% geometric fixed parameters
twist = FixedValues.Geometry.twist;
fuselage_radius = 1/2 * FixedValues.Geometry.fuselageDiameter;
dihedral = FixedValues.Geometry.dihedral;
A1 = FixedValues.Geometry.A1;

% geometric derived variables
c_tip = taper_outboard * c_kink;
x1 = 0;
x2 = (A1)*tand(LE_sweep);
x3 = (A1 + A2)*tand(LE_sweep);
y1 = 0;
y2 = A1;
y3 = A1 + A2;
z1 = -(fuselage_radius)*tand(dihedral); % --------> position on the z axis of the root leading edge. 
                                                  % The minus is a result of how we defined the frame of reference
z2 = (A1 - fuselage_radius) * tand(dihedral);
z3 = (A1 + A2 - fuselage_radius) * tand(dihedral);
c_root = A1 * tand(LE_sweep) + c_kink - A1 * tand(FixedValues.Geometry.TE_sweep); 

% Wing planform geometry 
%                     x      y      z      chord     twist
Aircraft.Wing.Geom = [x1     y1     z1     c_root    twist(1);
                      x2     y2     z2     c_kink    twist(2);
                      x3     y3     z3     c_tip     twist(3)];

S = wingArea(Aircraft.Wing.Geom);
Constraints.area = S;


Aircraft.Wing.inc = 0;  % incidence angle is already considered in the first twist angle

% Airfoil coefficients input matrix
Ti = v(5:11);
Bi = v(12:18);
Aircraft.Wing.Airfoils = [1;1;1] * [Ti(:)', Bi(:)'];

Aircraft.Wing.eta = [0; A1/(A1+A2); 1];  % Spanwise location of the airfoil sections


% ------------------------------- RUN MDA ------------------------------- %;

try
    % initial target for coupling variable MTOW
    MTOWi = 230000;
    MTOW = MDA(Aircraft, MTOWi, v);
    
    % Outside of the MDA, run additional disciplines
    [L_des, D_des] = Aerodynamics(Aircraft, MTOW, v);
    R = Performance(L_des, D_des, MTOW, v);
    
    % output the final optimized values and the iteration counter of the MDA
    vararg = [MTOW, L_des, D_des];

catch
    warning("Iteration Failed: Setting the Range to 0.")
    R = 0;

end


% Evaluate the output of the objective function
f = -R;

fprintf("R = %d km", round(R/1000));
disp(newline);

end