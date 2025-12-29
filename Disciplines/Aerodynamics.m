function [L_des, D_des, D_des_wing, alpha] = Aerodynamics(Aircraft, W_wing, v)

    global FixedValues

    h_des = v(2);
    Ma_des = v(1);
    D_A_W_q = FixedValues.Performance.D_A_W_q;

    % get design weight
    MTOW = W_wing + FixedValues.Weight.A_W + FixedValues.Weight.W_f;
    W_f = FixedValues.Weight.W_f;
    W_des = sqrt(MTOW * (MTOW-W_f));
    load = W_des * 9.81;

    a = airSoundSpeed(h_des);
    rho = airDensity(h_des);
    T = airTemperature(h_des);
    mu = sutherland(T);

    V_des = a * Ma_des;
    q = 1/2 * rho * V_des^2;
    S = wingArea(Aircraft.Wing.Geom);
    MAC = meanAeroChord(Aircraft.Wing.Geom);
    
    CL = load / (q * S);

    % Wing geometry defined inside Aircraft.Wing
    Aircraft.Aero.CL = CL;
    Aircraft.Aero.Re = rho * V_des * MAC / mu;
    Aircraft.Aero.V = V_des;
    Aircraft.Aero.alt = h_des;
    Aircraft.Aero.M = Ma_des;
    Aircraft.Aero.MaxIterIndex = 200;

    Aircraft.Visc = 1;

    % check current directory and change to Q3D
    result = changeDirSafe("Q3D");

    if result
        
        lastwarn("")
        warning("off", "backtrace")

        % set a 30-second timer for Aero to complete, else mark it as an 
        % error. Do this using a parallel worker so it can kill the process
        %  if the solver times out. Same as for the MDA.
        
        % create a new background pool (if there is none)
        pool = gcp('nocreate');
        if isempty(pool)
            pool = parpool(1);
        end
        
        disp("[AER] Running Q3D...")

        % run Q3D in parallel (2 expected outputs)
        Aero = parfeval(pool, @AeroEval, 2, ...
            Aircraft);

        startingTime = tic;
        while toc(startingTime) < 30
            % if finishes early, continue without a problem
            if Aero.State == "finished"
                break
            end
        end

        % if function is still running after 30 seconds, warning + error
        if Aero.State ~= "finished"
            cancelAll(pool.FevalQueue)
            cancel(Aero)
            warning on
            warning("off", "backtrace")
            warning("off", "verbose")
            warning("Aerodynamics has been running for more than 30 seconds.");
            warning("on", "backtrace")
            error("Aerodynamics has been running for more than 30 seconds.")
        end
        
        % if q3d outputs some errors for some reason then boom
        if ~isempty(Aero.Error)
            warning on
            warning("off", "backtrace")
            warning("off", "verbose")
            warning("Q3D [AER] has produced an unexpected error");
            warning("on", "backtrace")
            error("Q3D [AER] has produced an unexpected error")
        end

        % catch ALL warnings by q3d, catch error by outer block
        [msg, ~] = lastwarn();
        if contains(msg, "airfoil transonic analysis diverged")
            error("Q3D did not converge.")
        end

        % get results from Q3D
        Res = Aero.OutputArguments{1};
        finish = Aero.OutputArguments{2};

        disp("[AER] Time elapsed: " + finish)
        cd ..\
    else
        error("ERROR: could not change directory to Q3D from Aerodynamics")
    end
    
    alpha = Res.Alpha;
    L_des = q * S * Res.CLwing;
    D_des_wing = q * S * Res.CDwing;
    D_des = D_des_wing + q * D_A_W_q;

    function [Res, finish] = AeroEval(Aircraft)
        % Q3D wrapper for ParfEval

        changeDirSafe("Q3D")

        tic;
        Res = Q3D_solver(Aircraft);
        finish = toc;
    
    end

end