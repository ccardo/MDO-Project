function [W_wing] = MDA(Aircraft, W_wing_i, v)

    % define the wanted tolerance
    error = 10^-4;
    
    % start the iteration counter
    counter = 0;

    % initialize W_wing
    W_wing = 1;
    
    % run the loops for the disciplines that evaluate the W_wing
    disp("[MDA] Running Q3D & EMWET...")
    tic
    while abs(W_wing-W_wing_i)/W_wing > error
        % loop counter
        if (counter > 0)
            W_wing_i = W_wing; 
        end
        [L_max, M_max, y_max] = Loads(Aircraft, W_wing_i, v); 
        W_wing = Structures(Aircraft, L_max, M_max, y_max, W_wing_i, v);
        
        % if any resulting quantity is NaN or Inf, display a warning but continue
        if any(isnan([W_wing, norm(L_max), norm(M_max), norm(y_max)])) || ...
           any(isinf([W_wing, norm(L_max), norm(M_max), norm(y_max)]))
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
