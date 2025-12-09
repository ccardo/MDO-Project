function [MTOW] = Structures(Aircraft, L_max, M_max, y_max, MTOW, v, counter)

    global FixedValues
    global globalIterationCounter

    % check current directory and change to Q3D
    result = changeDirSafe("EMWET");

    % SOLVE and return back to parent directory
    if result
        
        % create EMWET input files:  
        % current_airfoil.dat, a330.init, a330.load
        printAirfoil(v(5:11), v(12:18))
        inputStructures(Aircraft, FixedValues, MTOW, v)
        inputStructuresLoads(y_max, L_max, M_max)
        
        % run EMWET and display [global.MDA] iteration count.
        iter = "["+globalIterationCounter+"."+counter+"]";
        disp(iter+" Running EMWET [STR]...")
        EMWET a330
        disp(iter+" Done running EMWET [STR].")
        
        % read a330.weight
        MTOW = readEMWET(FixedValues);
        
        cd ..\
    else
        error("ERROR: could not change directory to EMWET from Structures")
    end

    

end