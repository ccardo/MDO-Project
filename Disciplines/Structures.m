function [MTOW] = Structures(Aircraft, L_max, M_max, y_max, MTOW, v)

    global FixedValues;

    % check current directory and change to Q3D
    result = changeDirSafe("EMWET");

    % SOLVE and return back to parent directory
    if result
        EMWET a330
        % return back to parent dir
        cd ..\
    else
        error("ERROR: could not change directory to EMWET from Structures")
    end

end