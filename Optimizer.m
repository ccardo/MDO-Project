function [f, vararg] = Optimizer(v)

% design variables
b2 = v(20);
h_des = v(2);
Ma_des = v(1);
LE_sweep = v(19);
c_kink = v(3);
c_tip = v(4);

% geometric fixed parameters
dihedral = 5;
b1 = 16.38; % first semispan
TE_sweep = 2.5;

% geometric dervied variables
x1 = 0;
x2 = (b1/2)*tand(LE_sweep);
x3 = 0.5*(b1 + b2)*tand(LE_sweep);
y1 = 0;
y2 = b1/2;
y3 = b1/2 + b2/2;
z1 = -(FixedValues.Geometry.fuselageD/2)*tand(dihedral); % position on the z axis of the root leading edge. 
% The minus is a result of how we defined the frame of reference
z2 = 0.5*b1 * tand(dihedral);
z3 = 0.5 * (b1+b2)* tand(dihedral);
c_root = b1 * tand(LE_sweep) + c_kink - b1 * tand(TE_sweep); 

% Wing planform geometry 
%                x      y       z     chord(m)  twist(deg) -- NOTE, the twist at root should be +5.2
Aircraft.Wing.Geom = [x1     y1      z1      c_root    +5.20;
                      x2     y2      z2      c_kink    +2.54;
                      x3     y3      z3      c_tip       -2];

MAC = meanAeroChord(Aircraft.Wing.Geom);
A = wingArea(Aircraft.Wing.Geom);
Aircraft.Var = [MAC A];
Aircraft.Wing.inc = 0;  % incidence angle is already considered in the first twist angle

% Airfoil coefficients input matrix (ATTENTION: MATRIX MULTIPLICATION!)
Ti = v(5:11);
Bi = v(12:18);
Aircraft.Wing.Airfoils = [1;1;1] * [Ti(:)', Bi(:)'];

Aircraft.Wing.eta = [0; b1/(b1+b2); 1];  % Spanwise location of the airfoil sections

% --------------------------------------------------------------------- %
% ----------------------------- RUN MDA ------------------------------- %
% --------------------------------------------------------------------- %
[R, MTOW, L_design, D_design, L_max, M_max, counter] = ...
                                                MDA(Aircraft, MTOWi, v);

% Evaluate the output of the objective function
f = -R;

% output the final optimized values and the iteration counter of the MDA
vararg = [MTOW, L_design, D_design, L_max, M_max, counter];

end