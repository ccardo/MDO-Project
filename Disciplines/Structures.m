function [W_wing] = Structures(Aircraft, L_max, M_max, y_max, W_wing, v, FixedValues)
    
    % check current directory and change to EMWET
    result = changeDirSafe("EMWET");
    
    % Compute the maximum take-off weight from the coupling variable W_wing
    MTOW = W_wing + FixedValues.Weight.A_W + FixedValues.Weight.W_f;

    % SOLVE and return back to parent directory
    if result % If the directory change was successful run EMWET, otherwise give an error
        
        % create EMWET input files:  
        printAirfoil(v(5:11), v(12:18)) % writes current_airfoil.dat
        inputStructures(Aircraft, MTOW, v, FixedValues) % writes a330.init
        inputStructuresLoads(y_max, L_max, M_max) % writes a330.load
        
        % run EMWET 
        EMWET a330
        
        % read a330.weight and obtain the wing weight
        W_wing = readEMWET();
        cd ..\
    else
        error("ERROR: could not change directory to EMWET from Structures")
    end
end