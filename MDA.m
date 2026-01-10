function [W_wing] = MDA(Aircraft, W_wing_i, v)

global FixedValues
global Constraints

    % define the wanted tolerance
    error = 10^-5;
    
    % start the iteration counter
    counter = 0;

    % initialize W_wing to evaluate the relative error in the first
    % iteration
    W_wing = 1;
    
    % run the loops for the disciplines that evaluate the coupling
    % variable W_wing
    disp("[MDA] Running Q3D & EMWET...")
    tic
    while abs(W_wing-W_wing_i)/W_wing > error
        % loop counter
        if (counter > 0)
            W_wing_i = W_wing; 
        end

        [W_wing, L_max, M_max, y_max] = LoadStructEval(Aircraft, W_wing_i, v, FixedValues);
    
        % if too many MDA iterations, means it's stuck => error
        if counter >= 20
            warning on
            warning("off", "backtrace")
            warning("off", "verbose")
            warning("Convergence took too many iterations in MDA.");
            warning("on", "backtrace")
            error("Convergence took too many iterations in MDA.")
        end

        % if any resulting quantity is NaN or Inf, warning + error
        if any(isnan([W_wing, norm(L_max), norm(M_max), norm(y_max)])) || ...
           any(isinf([W_wing, norm(L_max), norm(M_max), norm(y_max)]))
            warning on
            warning("off", "backtrace")
            warning("off", "verbose")
            warning("One of the MDA coupling variables is either Inf of NaN.");
            warning("on", "backtrace")
            error("One of the MDA coupling variables is either Inf of NaN.")
        end

        % add to counter & update constraints
        counter = counter +1;
        Constraints.W_wing = W_wing; % required to evaluate the wing loading constraint
    end
    
    finish = toc;
    disp("[MDA] Time elapsed: " + finish + ", iterations: " + counter)
end


function [W_wing, L_max, M_max, y_max] = LoadStructEval(Aircraft, W_wing_i, v, FixedValues)

    % function wrapper necessary for parallel evaluation.
    [L_max, M_max, y_max] = Loads(Aircraft, W_wing_i, v, FixedValues); 
    W_wing = Structures(Aircraft, L_max, M_max, y_max, W_wing_i, v, FixedValues);

end