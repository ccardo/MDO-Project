function [MTOW] = Structures(Aircraft, L_max, M_max, y_max, MTOW, v)

    global FixedValues

    % check current directory and change to Q3D
    result = changeDirSafe("EMWET");

    % SOLVE and return back to parent directory
    if result
        
        % create EMWET input files:  
        % current_airfoil.dat, a330.init, a330.load
        printAirfoil(v(5:11), v(12:18))
        inputStructures(Aircraft, FixedValues, MTOW, v)
        inputStructuresLoads(y_max, L_max, M_max)

        disp("> Running EMWET for Structures...")
        EMWET a330
        disp("> Finished running EMWET.")
        
        % read a330.weight
        MTOW = readEMWET(FixedValues);
        
        cd ..\
    else
        error("ERROR: could not change directory to EMWET from Structures")
    end

    

end