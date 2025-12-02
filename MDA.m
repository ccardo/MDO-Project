function [R, MTOW, L_design, D_design, L_max, M_max, counter] = MDA(Aircraft, MTOWi, v, error)

% define an error if not specified in the functions inputs

if nargin < 2
    error = 1e-6;
end

%start the iteration counter

counter = 0;

% run the loops for the disciplines that evaluate the MTOW

while abs(MTOW-MTOWi)/MTOW > error
    %loop counter
    if (counter > 0)
        MTOWi = MTOW; 
    end
    [L_max, M_max, y_max] = Loads(Aircraft, MTOWi, v); 
    MTOW = Structures(Aircraft, L_max, M_max, y_max, MTOWi, v);
    counter = counter +1;    
end

[L_design, D_design, Aircraft] = Aerodynamics(Aircraft, MTOW, v);
R = Performane(Aircraft, L_design, D_design, MTOW, v);

end