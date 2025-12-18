function [c, ceq] = constraints(~)

    global FixedValues
    global Constraints
    
    % constraint #1 limits the wing loading of the optimized wing to the
    % wing loading of the reference aircraft.
    MTOW = Constraints.MTOW;
    A = Constraints.area;
    A_ref = FixedValues.Geometry.area; 
    c1 = (MTOW/A)-(MTOW/A_ref);
        
    % constrain #2 limits the volume of the fuel tank so that the amount of
    % fuel (which is kept constant) can always be carried by the wing
    f_fuel = FixedValues.Geometry.f_tank;
    rho_fuel = FixedValues.Weight.rho_f;
    W_f = FixedValues.Weight.W_f;

    % constraints on fuel weight and volume
    V_tank = Constraints.VTank;
    c2 = (f_fuel*W_f)/rho_fuel - V_tank;

    c = [c1; c2];
    ceq = [];
       
end