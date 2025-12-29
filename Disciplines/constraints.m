function [c, ceq] = constraints(~)

    global FixedValues
    global Constraints
    global projectDirectory
    
    % constraint #1 limits the wing loading of the optimized wing to the
    % wing loading of the reference aircraft.
    MTOW_ref = 230000;
    MTOW = Constraints.W_wing + FixedValues.Weight.A_W + FixedValues.Weight.W_f;
    A = Constraints.area;
    A_ref = FixedValues.Geometry.area; 
    c1 = ((MTOW/A) - (MTOW_ref/A_ref)) / (MTOW_ref/A_ref);

    % constrain #2 limits the volume of the fuel tank so that the amount of
    % fuel (which is kept constant) can always be carried by the wing
    f_fuel = FixedValues.Geometry.f_tank;
    rho_fuel = FixedValues.Weight.rho_f;
    W_f = FixedValues.Weight.W_f;

    % constraints on fuel weight and volume
    V_tank = Constraints.VTank;
    c2 = (W_f/(rho_fuel) - f_fuel * V_tank) / (f_fuel * V_tank);

    c = [c1; c2];
    ceq = [];
    
    % in case MTOW = NaN, violate constraints
    if any(isnan(c)) || any(isinf(c)) || isempty(c)
        warning("constraints returned NaN or Inf. Setting c = 1e9;")
    end

    % display available fuel tank volume with constant W_f
    fprintf("Available Fuel Tank volume = %.1f%%\n", -c2*100)
    
    cd(projectDirectory);
end