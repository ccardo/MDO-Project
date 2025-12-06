function [R, MTOW, L_design, D_design, counter] = MDA(Aircraft, MTOWi, v)

    % define the wanted tolerance
    error = 10^-3;
    
    % start the iteration counter
    counter = 0;

    % initialize MTOW

    MTOW = 1;
    
    % run the loops for the disciplines that evaluate the MTOW
    
    while abs(MTOW-MTOWi)/MTOW > error
        % loop counter
        if (counter > 0)
            MTOWi = MTOW; 
        end
        [L_max, M_max, y_max] = Loads(Aircraft, MTOWi, v); 
        MTOW = Structures(Aircraft, L_max, M_max, y_max, MTOWi, v);
        counter = counter +1;    
    end
    
    [L_design, D_design] = Aerodynamics(Aircraft, MTOW, v);
    R = Performance(L_design, D_design, MTOW, v);

end
