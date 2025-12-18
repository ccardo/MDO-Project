function [MTOW] = MDA(Aircraft, MTOWi, v)

    % define the wanted tolerance
    error = 10^-6;
    
    % start the iteration counter
    counter = 0;

    % initialize MTOW
    MTOW = 1;
    
    % run the loops for the disciplines that evaluate the MTOW
    disp("[MDA] Running Q3D & EMWET...")
    tic
    while abs(MTOW-MTOWi)/MTOW > error
        % loop counter
        if (counter > 0)
            MTOWi = MTOW; 
        end
        [L_max, M_max, y_max] = Loads(Aircraft, MTOWi, v); 
        MTOW = Structures(Aircraft, L_max, M_max, y_max, MTOWi, v);
        
        % if any resulting quantity is NaN or Inf, display a warning but continue
        if any(isnan([MTOW, norm(L_max), norm(M_max), norm(y_max)])) || ...
           any(isinf([MTOW, norm(L_max), norm(M_max), norm(y_max)]))
            warning on
            warning("off", "backtrace")
            warning("off", "verbose")
            warning("One of the MDA coupling variables is either Inf of NaN.");
            warning("on", "backtrace")
        end

        % add to counter
        counter = counter +1;
    end
    
    finish = toc;
    disp("[MDA] Time elapsed: " + finish + ", iterations: " + counter)
end
