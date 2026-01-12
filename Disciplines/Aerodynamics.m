function [L_des, D_des, D_des_wing, alpha] = Aerodynamics(Aircraft, W_wing, v)

    global FixedValues
    global projectDirectory
    
    % Define the design condition for the current design to evaluate the
    % aerodynamic quantities
    h_des = v(2);
    Ma_des = v(1);
    D_A_W_q = FixedValues.Performance.D_A_W_q;

    % compute the aircraft CL at the design point
    MTOW = W_wing + FixedValues.Weight.A_W + FixedValues.Weight.W_f;
    W_f = FixedValues.Weight.W_f;
    W_des = sqrt(MTOW * (MTOW-W_f));
    Force = W_des * 9.81;

    a = airSoundSpeed(h_des);
    rho = airDensity(h_des);
    T = airTemperature(h_des);
    mu = sutherland(T);

    V_des = a * Ma_des;
    q = 1/2 * rho * V_des^2;
    S = wingArea(Aircraft.Wing.Geom);
    MAC = meanAeroChord(Aircraft.Wing.Geom);
    
    CL = Force / (q * S);

    % Insert the variables that define the design point in the Q3D input
    Aircraft.Aero.CL = CL;
    Aircraft.Aero.Re = rho * V_des * MAC / mu;
    Aircraft.Aero.V = V_des;
    Aircraft.Aero.alt = h_des;
    Aircraft.Aero.M = Ma_des;
    Aircraft.Aero.MaxIterIndex = 200;
    
    % Since we want to evaluate the viscous drag
    Aircraft.Visc = 1;
    
    disp("[AER] Running Q3D...")

    [Res, finish, q3dwarning] = AeroEval(Aircraft);

    if q3dwarning == 1
        % catches Q3D failures and throws an error (to be caught by outer
        % try/catch routine).
        error("Q3D did not converge.")
    end

    disp("[AER] Time elapsed: " + finish)
    
    % Process the Q3D results.
    alpha = Res.Alpha;
    L_des = q * S * Res.CLwing;
    D_des_wing = q * S * Res.CDwing;
    D_des = D_des_wing + q * D_A_W_q;

    function [Res, finish, q3dwarning] = AeroEval(Aircraft)

        % Q3D wrapper for parfeval:
        % this function resets the last warning to catch Q3D failures and
        % runs Q3D itself.
        
        changeDirSafe("Q3D");
        lastwarn("")
        warning("off", "backtrace")
        
        % run Q3D and time
        tic;
        Res = Q3D_solver(Aircraft);
        finish = toc;
        
        % catch Q3D failure: 
        % not "diverged in section (x)" because the drag distribution is
        % still acceptable in most cases (as far as we have experimented).
        % Only catch complete transonic analysis divergence.

        [msg, ~] = lastwarn();
        if contains(msg, "airfoil transonic analysis diverged")
            q3dwarning = 1;
            cd ..\
            return
        end
        
        q3dwarning = 0;
        cd ..\
    
    end

    function changeWorkerDir(projectDirectory)
        % reset parallel worker directory
        cd(projectDirectory)
    end

end