function [W_wing] = MDA(Aircraft, W_wing_i, v)

global FixedValues
global Constraints

    % define the target relative tolerance. Set to 1e-5 since this
    % corresponds to an error on the order of 0.1 kg which is acceptable
    % for a wing weight in the order of 1e4 kg
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

        if (counter > 0)
            W_wing_i = W_wing; % update the current guess for the initial weight with the result EMWET gave in the previous MDA iteration
        end
        
        % Run the Loads and Structures disciplines to get the sizing loads
        [W_wing, L_max, M_max, y_max] = LoadStructEval(Aircraft, W_wing_i, v, FixedValues);
    
        % if the MDA takes too many iterations to converge to a valid
        % structural weight of the wing give an error that is caught in the
        % optimizer and invalidates the current function evaluation
        if counter >= 50
            warning on
            warning("off", "backtrace")
            warning("off", "verbose")
            warning("Convergence took too many iterations in MDA.");
            warning("on", "backtrace")
            error("Convergence took too many iterations in MDA.")
        end

        % Give an error that is caught in the optimizer and invalidates 
        % the current function evaluation if any value that is an output of
        % a discipline returns NaN 
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
        Constraints.W_wing = W_wing; % Required to calculate the constaints for the current design vector
    end
    
    finish = toc;
    disp("[MDA] Time elapsed: " + finish + ", iterations: " + counter)
end

% MDA disciplines wrapper
function [W_wing, L_max, M_max, y_max] = LoadStructEval(Aircraft, W_wing_i, v, FixedValues)

    [L_max, M_max, y_max] = Loads(Aircraft, W_wing_i, v, FixedValues); 
    W_wing = Structures(Aircraft, L_max, M_max, y_max, W_wing_i, v, FixedValues);

end