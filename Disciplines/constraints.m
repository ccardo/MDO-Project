function [c1, c2] = constraints(Aircraft, MTOW)
    % constraint #1 limits the wing loading of the optimized wing to the
    % wing loading of the reference aircraft.
    % if the design complies with the constraint then c = 1, otherwise
    % c = 0

    global FixedValues;
    
    A = wingArea(Aircraft.Wing.Geom);
    A_ref = FixedValues.Geometry.A; % NEED TO ADD IT TO THE FIXEDVALUES STRUCT
    if (MTOW/A)-(MTOW/A_ref) <= 0 
        c1 = 1;
    else
        c1 = 0;
    end
    
    % constrain #2 limits the volume of the fuel tank so that the amount of
    % fuel (which is kept constant) can always be carried by the wing
    f_fuel = FixedValues.Geometry.f_tank;
    rho_fuel = FixedValues.Weight.rho_f;
    W_f = FixedValues.Weight.W_f;
    
    % generate wing boxes and compute their volume
    Boxes = loftWingBox(Aircraft);
    volume = zeros(1, length(Boxes));
    for i = 1:length(Boxes)
        volume(i) = boxVolume(Boxes(i).X, Boxes(i).Y, Boxes(i).Z);
    end
    V_tank = sum(volume);

    % constraints on fuel weight and volume
    if (f_fuel*W_f)/rho_fuel-V_tank <= 0 
        c2 = 1;
    else
        c2 = 0;
    end
    
end


