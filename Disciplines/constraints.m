function [c, ceq] = constraints(~)

    global FixedValues
    global Constraints
    global projectDirectory
    
    % constraint #1 limits the wing loading of the optimized wing to the
    % wing loading of the reference aircraft. It is normalized w.r.t. the
    % reference wing loading.
    MTOW_ref = 230000;
    MTOW = Constraints.W_wing + FixedValues.Weight.A_W + FixedValues.Weight.W_f;
    A = Constraints.area;
    A_ref = FixedValues.Geometry.area; 
    c1 = ((MTOW/A) - (MTOW_ref/A_ref)) / (MTOW_ref/A_ref);

    % constraint #2 limits the volume of the fuel tank so that the amount of
    % fuel (which is kept constant) can always be carried by the wing. It
    % is normalized w.r.t. the reference fuel volume
    f_fuel = FixedValues.Geometry.f_tank;
    rho_fuel = FixedValues.Weight.rho_f;
    W_f = FixedValues.Weight.W_f;
    V_tank = Constraints.VTank;
    c2 = (W_f/(rho_fuel) - f_fuel * V_tank) / (W_f/(rho_fuel));

    c = [c1; c2];
    ceq = []; % no equality constraints
    
    % in case c = [] or c = [inf], violate constraints
    if any(isinf(c)) || isempty(c)
        warning("constraints returned NaN or Inf.")
        c(:,:) = NaN;
    end    
    cd(projectDirectory);
end