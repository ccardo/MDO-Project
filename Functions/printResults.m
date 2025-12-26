function printResults(filename, FixedValues, x0, x, f_hist, iterCount, options)
    
    arguments
        filename {mustBeNonempty}
        FixedValues 
        x0 
        x 
        f_hist
        iterCount
        options
    end
    
    i = 1;
    filepath = sprintf("Results\%s", filename);
    while exist(filepath, "file")
        filepath = sprintf("%s_%d", filepath, i);
    end

    fid = fopen(filepath, "w");
    
    % spar positions
    spars = FixedValues.Geometry.spars;
    fprintf(fid, "Root spars: [%.2f %.2f]\n", spars(1,1), spars(1,2));
    fprintf(fid, "Kink spars: [%.2f %.2f]\n", spars(2,1), spars(2,2));
    fprintf(fid, "Tip  spars: [%.2f %.2f]\n", spars(3,1), spars(3,2));

    disp(newline)
    
    % fuel tank ends
    fuelTank = FixedValues.Geometry.tank;
    fprintf(fid, "Fuel Tank Ends: [%.2f %.2f]\n", fuelTank(1), fuelTank(2));

    disp(newline)

    % performance
    D_A_W_q = FixedValues.Performance.D_A_W_q;
    fprintf(fid, "A-w Drag / qinf: %.2f\n", D_A_W_q);

    disp(newline)
    
    % initial airfoil
    Tcst0 = x0(5:11);
    Bcst0 = x0(12:18);
    fprintf(fid, "Initial Airfoil:\n");
    fprintf(fid, "Top CST: "); fprintf(fid, "%.3f ", Tcst0); disp(newline)
    fprintf(fid, "Bot CST: "); fprintf(fid, "%.3f ", Bcst0);

    disp(newline);

    % final airfoil
    Tcst = x(5:11);
    Bcst = x(12:18);
    fprintf(fid, "Final Airfoil:\n");
    fprintf(fid, "Top CST: "); fprintf(fid, "%.3f ", Tcst); disp(newline)
    fprintf(fid, "Bot CST: "); fprintf(fid, "%.3f ", Bcst);

    % function eval
    R_ref = FixedValues.Performance.R_ref;
    maxDeltaF = max(abs(f_hist(2:end) - f_hist(1:end-1)));
    fprintf(fid, "Initial Objective Function: %.4f\n", -f_hist(1) * R_ref);
    fprintf(fid, "Final   Objective Function: %.4f\n", -f_hist(end) * R_ref);
    fprintf(fid, "Maximum Change in Objective Function: %.4f\n", maxDeltaF * R_ref);
    fprintf(fid, "Iteration Count: %d", iterCount);

    disp(newline);

    % fmincon options
    fprintf(fid, "Algorithm:              %s", options.Algorithm);
    fprintf(fid, "Step Tolerance:         %f", options.StepTolerance);
    fprintf(fid, "Optimality Tolerance:   %f", options.OptimalityTolerance);
    fprintf(fid, "Step Tolerance:         %f", options.StepTolerance);
    fprintf(fid, "Step Size:              %f", options.FiniteDifferenceStepSize);
    fprintf(fid, "Finite Difference Type: %f", options.FiniteDifferenceType);

    fclose(fid);

end