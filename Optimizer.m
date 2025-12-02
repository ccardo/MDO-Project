function [f, vararg] = Optimizer(x)

% geometric fixed parameters
dihedral = 5;
b1 = 16.38; % first semispan
fuselage_d = 5.64; % diameter fo the fuselage
TE_sweep = ;

% geometric dervied variables
x1 = 0;
x2 = (b1/2)*tand(x(19));
x3 = 0.5*(b1 + x(20))*tand(x(19));
y1 = 0;
y2 = b1/2;
y3 = b1/2 + x(20)/2;
z1 = -(fuselage_d/2)*tand(dihedral); % position on the z axis of the root leading edge. 
% The minus is a result of how we defined the frame of reference
z2 = 0.5*b1 * tand(dihedral);
z3 = 0.5 * (b1+x(20))* tand(dihedral);
c_root = b1 * tand(x(19)) + x(3) - b1 * tand(TE_sweep); 

% Wing planform geometry 
%                x      y       z     chord(m)  twist(deg) -- NOTE, the twist at root should be +5.2
AC.Wing.Geom = [x1     y1      z1      cR    +5.20;
                x2     y2      z2      cK    +2.54;
                x3     y3      z3      cT       -2];

AC.Wing.inc  = 0;  % incidence angle is already considered in the first twist angle


end