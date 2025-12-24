function [W_wing] = MDA(Aircraft, W_wing_i, v)

    % define the wanted tolerance
    error = 10^-3;
    
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
        
        % set a 30-second timer for Loads and Structures to complete,
        % else mark it as an error. Do this using a parallel worker so it
        % can kill the process if the solver times out.
        
        % create a new background pool (if there is none)
        pool = gcp('nocreate');
        if isempty(pool)
            pool = parpool(1);
        end
        
        % this creates the actual parallel thing (1 is the number of
        % expected outputs)
        f = parfeval(pool, @LoadStructEval, 1, ...
            Aircraft, W_wing_i, v);

        startingTime = tic;
        while toc(startingTime) < 30
            % if finishes early, continue without a problem
            if f.State == "finished"
                break
            end
        end
        
        % if function is still running after 30 seconds, warning + error
        if f.State == "running"
            warning on
            warning("off", "backtrace")
            warning("off", "verbose")
            warning("Either Loads or Structures has been running for more than 30 seconds.");
            warning("on", "backtrace")
            error("to be caught by outer try/catch")
        end

        % get actual output from function
        W_wing = f.OutputArguments{1};

        % if any resulting quantity is NaN or Inf, warning + error
        if any(isnan([W_wing, norm(L_max), norm(M_max), norm(y_max)])) || ...
           any(isinf([W_wing, norm(L_max), norm(M_max), norm(y_max)]))
            warning on
            warning("off", "backtrace")
            warning("off", "verbose")
            warning("One of the MDA coupling variables is either Inf of NaN.");
            warning("on", "backtrace")
            error("to be caught by outer try/catch")
        end

        % add to counter
        counter = counter +1;
    end
    
    finish = toc;
    disp("[MDA] Time elapsed: " + finish + ", iterations: " + counter)
end


function W_wing = LoadStructEval(Aircraft, W_wing_i, v)
    
    % function wrapper necessary for parallel evaluation.

    [L_max, M_max, y_max] = Loads(Aircraft, W_wing_i, v); 
    W_wing = Structures(Aircraft, L_max, M_max, y_max, W_wing_i, v);

end