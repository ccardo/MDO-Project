function [wing_weight] = readEMWET()

    % read the EMWET output file a330.weight and extract the new W_wing
    fid = fopen( 'a330.weight','r');
    
    % take the first line of the output file 
    first_line = fgetl(fid);

    % scan the first line for the wing weight value
    wing_weight = sscanf(first_line, "Wing total weight(kg) %f");
    fclose(fid);
        
end