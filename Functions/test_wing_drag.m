format short G
close all
clear
clc

% initialize FixedValues (don't want to run the whole thing every time I
% restart this script)
load FixedValues.mat

% initialize design vector
x0 = [
    0.82
    11800
    7.514
    0.3077
    0.14863
    0.069323
    0.22575
    0.040425
    0.27305
    0.17076
    0.27171
    -0.15853
    -0.082473
    -0.16792
    -0.038631
    -0.26127
    0.075531
    0.077234
    31
    20.81
];

% initialize aircraft geometry
AC = createGeom(x0);
% AC.Wing.Airfoils = [1;1;1] * [      
%      0.23978
%      0.074022
%        0.2882
%      0.048346
%       0.28214
%       0.21019
%       0.41751 % whitcomb CST coefficients
%      -0.23742
%      -0.11177
%      -0.24963
%    -0.0053665
%      -0.54929
%       0.28346
%       0.25452
% ]';

AC.Wing.Geom = [
        0            0            0       7.514          5.2
    4.921         8.19      0.71653        7.514         2.54
   17.425           29       2.5372       2.3121        -2];

x = x0;
for i = 1:50

    Ma_des = x(1);
    h_des = x(2);
    c_kink = x(3);
    taper2 = x(4);
    Sw_LE = x(19);
    b2 = x(20);
    wing_twist = AC.Wing.Geom(:,5);
    
    try
        % generate random modification to design vector (not to airfoil)
        Ma_des_new = x(1) + 0.1 * (rand-0.6);
        h_des_new = x(2) + 100 * (rand-0.5);
        c_kink_new = x(3) + 2 * (rand-0.5);
        taper2_new = x(4) + 0.2 * (rand-0.5);
        Sw_LE_new = x(19) + 6 * (rand-0.5);
        b2_new = x(20) + 6 * (rand-0.5);
        wing_twist_new = wing_twist + 0.5 * [(rand-0.5); (rand-0.5); (rand-0.5)];
    
        % b = check_bounds(Ma_des_new, h_des_new, c_kink_new, taper2_new, Sw_LE_new, b2_new);
        % if ~all(b)
        %     msg = sprintf("[%d] bounds violated", i);
        %     failed(end+1) = i;
        %     disp(msg)
        %     continue
        % end
    
        x(1) = Ma_des_new;
        x(2) = h_des_new;
        x(3) = c_kink_new;
        x(4) = taper2_new;
        x(19) = Sw_LE_new;
        x(20) = b2_new;
        
        % recreate aircraft geometry
        AC = createGeom(x);
        % delete twist
        AC.Wing.Geom(:,end) = [0;0;0];
        % AC.Wing.Geom(:,5) = wing_twist_new;
    
        W_wing_i = 30000;
        W_wing = MDA(AC, W_wing_i, x);
        
        h_des = x(2);
        Ma_des = x(1);
        D_A_W_q = FixedValues.Performance.D_A_W_q;
    
        % get design weight
        MTOW = W_wing + FixedValues.Weight.A_W + FixedValues.Weight.W_f;
        W_f = FixedValues.Weight.W_f;
        W_des = sqrt(MTOW * (MTOW-W_f));
        Load = W_des * 9.81;
    
        a = airSoundSpeed(h_des);
        rho = airDensity(h_des);
        T = airTemperature(h_des);
        mu = sutherland(T);
    
        V_des = a * Ma_des;
        q = 1/2 * rho * V_des^2;
        S = wingArea(AC.Wing.Geom);
        MAC = meanAeroChord(AC.Wing.Geom);
        
        CL = Load / (q * S);
    
        % Wing geometry defined inside AC.Wing
        AC.Aero.CL = CL;
        AC.Aero.Re = rho * V_des * MAC / mu;
        AC.Aero.V = V_des;
        AC.Aero.alt = h_des;
        AC.Aero.M = Ma_des;
        AC.Aero.MaxIterIndex = 200;
        AC.Visc = 1;
        
        % run q3d
        % create a new background pool (if there is none)
        pool = gcp('nocreate');
        if isempty(pool)
            pool = parpool(1);
        end
        
        disp("[AER] Running Q3D...")
       
        % run Q3D in parallel (2 expected outputs)
        Aero = parfeval(pool, @AeroEval, 3, ...
            AC);
    
        startingTime = tic;
        while toc(startingTime) < 20
            % if finishes early, continue without a problem
            if Aero.State == "finished"
                break
            end
        end

        % if function is still running after 120 seconds, warning + error
        if Aero.State ~= "finished"
            cancelAll(pool.FevalQueue)
            cancel(Aero)
            warning on
            warning("off", "backtrace")
            warning("off", "verbose")
            warning("Q3D [AER] has been running for more than 120 seconds.");
            warning("on", "backtrace")
    
            parfeval(pool, @changeWorkerDir, 0, projectDirectory);
    
            error("Q3D [AER] has been running for more than 120 seconds.")
        end
    
        % get results from Q3D
        Res = Aero.OutputArguments{1};
        finish = Aero.OutputArguments{2};
        q3dwarning = Aero.OutputArguments{3};
    
        if q3dwarning == 1
            error("Q3D did not converge.")
        end
        
        % extract values
        alpha = Res.Alpha;
        y = Res.Section.Y;
        Cd = Res.Section.Cd;
        Cdi = Res.Wing.cdi;
        Cl = Res.Wing.cl;
        yst = Res.Wing.Yst;
        Cd = interp1(y, Cd, yst);
        
        figure(1)
        area(yst, Cd, "FaceAlpha", 0.3, EdgeColor="none");
        hold on
        area(yst, Cdi, "FaceAlpha", 0.3, EdgeColor="none");
        area(yst, Cd-Cdi, "FaceAlpha", 0.3, EdgeColor="none");
        legend("CD", "CDi", "CD-CDi")
        title("CD")
        hold off

        figure(2)
        area(yst, Cl, "FaceAlpha", 0.3, EdgeColor="none")
        text(0.5, 0, sprintf("Alpha: %.3f", alpha))
        title("CL")
    
        figure(3)
        plotWingGeometry(AC.Wing.Geom, AC.Wing.Airfoils)
        title("GEOM")
        view(90,90)

        figure(4)
        plotWingGeometry(AC.Wing.Geom, AC.Wing.Airfoils)
        title("AIRFOILS")
        view(0,0)
        
        drawnow

    catch ME
        
        % reset wing to previous state in case of error
        x(1) = Ma_des;
        x(2) = h_des;
        x(3) = c_kink;
        x(4) = taper2;
        x(19) = Sw_LE;
        x(20) = b2;
        rethrow(ME)
    end

end


function [Res, finish, q3dwarning] = AeroEval(Aircraft)
        % Q3D wrapper for ParfEval

        changeDirSafe("Q3D");

        tic;
        Res = Q3D_solver(Aircraft);
        finish = toc;
        
        warning("o nummr e Nepero")

        [msg, ~] = lastwarn();
        if contains(msg, "airfoil transonic analysis diverged")
            q3dwarning = 1;
            cd ..\
            return
        end
        
        q3dwarning = 0;
        cd ..\
    
end