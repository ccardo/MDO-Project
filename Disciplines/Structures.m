function [W_wing] = Structures(Aircraft, L_max, M_max, y_max, W_wing, v)
    
    global FixedValues
    global Constraints

    % check current directory and change to Q3D
    result = changeDirSafe("EMWET");
    
    MTOW = W_wing + FixedValues.Weight.A_W + FixedValues.Weight.W_f;

    % SOLVE and return back to parent directory
    if result
        
        % create EMWET input files:  
        % current_airfoil.dat, a330.init, a330.load
        printAirfoil(v(5:11), v(12:18))
        inputStructures(Aircraft, MTOW, v)
        inputStructuresLoads(y_max, L_max, M_max)
        
        % run EMWET and display [global.MDA] iteration count.
        EMWET a330
        
        % read a330.weight
        W_wing = readEMWET();
        cd ..\
    else
        error("ERROR: could not change directory to EMWET from Structures")
    end
    
    Constraints.W_wing = W_wing;

end