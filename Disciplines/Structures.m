function [MTOW] = Structures(Aircraft, L_max, M_max, y_max, MTOW, v)

    global FixedValues
    global Constraints

    % check current directory and change to Q3D
    result = changeDirSafe("EMWET");

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
        MTOW = readEMWET(FixedValues);
        cd ..\
    else
        error("ERROR: could not change directory to EMWET from Structures")
    end
    
    Constraints.MTOW = MTOW;

    % generate wing boxes and compute their volume
    Boxes = loftWingBox(Aircraft);
    volume = zeros(1, length(Boxes));
    for i = 1:length(Boxes)
         volume(i) = boxVolume(Boxes(i).X, Boxes(i).Y, Boxes(i).Z);
    end
    V_tank = sum(volume);
    
    Constraints.VTank = V_tank;
        

end