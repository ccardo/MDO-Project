function [f, vararg] = Optimizer(v)

global globalIterationCounter;
global FixedValues;
global Constraints;
globalIterationCounter = globalIterationCounter + 1;

% design variables
b2 = v(20);
LE_sweep = v(19);
c_kink = v(3);
c_tip = v(4);

% geometric fixed parameters
twist = FixedValues.Geometry.twist;
fuselage_radius = 1/2 * FixedValues.Geometry.fuselageDiameter;
dihedral = FixedValues.Geometry.dihedral;
b1 = FixedValues.Geometry.b1;

% geometric derived variables
x1 = 0;
x2 = (b1)*tand(LE_sweep);
x3 = (b1 + b2)*tand(LE_sweep);
y1 = 0;
y2 = b1;
y3 = b1 + b2;
z1 = -(fuselage_radius)*tand(dihedral); % --------> position on the z axis of the root leading edge. 
                                                  % The minus is a result of how we defined the frame of reference
z2 = (b1 - fuselage_radius) * tand(dihedral);
z3 = (b1 + b2 - fuselage_radius) * tand(dihedral);
c_root = b1 * tand(LE_sweep) + c_kink - b1 * tand(FixedValues.Geometry.TE_sweep); 

% Wing planform geometry 
%                     x      y      z      chord     twist
Aircraft.Wing.Geom = [x1     y1     z1     c_root    twist(1);
                      x2     y2     z2     c_kink    twist(2);
                      x3     y3     z3     c_tip     twist(3)];

% Attenzio! could remove the Aircraft.Var substruct and put MAC and A
% inside Aircraft.Wing (it doesn't break Q3D if we do this)
MAC = meanAeroChord(Aircraft.Wing.Geom);
A = wingArea(Aircraft.Wing.Geom);
Aircraft.Var = [MAC A];
Constraints.area = A;


Aircraft.Wing.inc = 0;  % incidence angle is already considered in the first twist angle

% Airfoil coefficients input matrix (ATTENTION: MATRIX MULTIPLICATION!)
Ti = v(5:11);
Bi = v(12:18);
Aircraft.Wing.Airfoils = [1;1;1] * [Ti(:)', Bi(:)'];

%plotWingGeometry(Aircraft.Wing.Geom, Aircraft.Wing.Airfoils, "r")
% t_max = checkThickness(Ti,Bi);
% disp(t_max)

Aircraft.Wing.eta = [0; b1/(b1+b2); 1];  % Spanwise location of the airfoil sections

" ======================================================================= ";
% ------------------------------- RUN MDA ------------------------------- %;
" ======================================================================= ";

% initial target for coupling variable MTOW
MTOWi = 230000;
[R, MTOW, L_des, D_des, counter] = MDA(Aircraft, MTOWi, v);

% Evaluate the output of the objective function
f = -R;

% output the final optimized values and the iteration counter of the MDA
vararg = [MTOW, L_des, D_des, counter];

end