function [MTOW] = readEMWET(FixedValues)

    % check current directory and change to EMWET
    % directory = dir();
    % if contains(directory(1).folder, "Disciplines") || ...
    %    contains(directory(1).folder, "Functions")   || ...
    %    contains(directory(1).folder, "Q3D")
    %     cd ..\EMWET\
    % elseif contains(directory(1).folder, "EMWET")
    %     cd .\
    % else
    %     cd .\EMWET\
    % end

    result = changeDirSafe("EMWET");
    
    if result
        fid = fopen( 'a330.load','r');
        wing_weight = fscanf(fid, 'Wing total weight(kg) %f');
        MTOW = wing_weight + FixedValues.Weight.A_W + FixedValues.Weight.W_f; % not sure about this formula
        fclose(fid);
        
        cd ..\
    else
        error("ERROR: could not change directory to EMWET from readValues")
    end
end