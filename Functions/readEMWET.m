function [wing_weight] = readEMWET()

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

    % read the EMWET output file a330.weight and extract the new W_w
    fid = fopen( 'a330.weight','r');
    
    % there's a problem with this mothafucka function
    % wing_weight = fscanf(fid, 'Wing total weight(kg) %f');
    % returns an empty array
    
    % fixed using fgetl (thanks matlab help center)
    first_line = fgetl(fid);
    wing_weight = sscanf(first_line, "Wing total weight(kg) %f");
    fclose(fid);
        
end