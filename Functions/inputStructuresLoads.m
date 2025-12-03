function [] = inputStructuresLoads(y_max, L_max, M_max)

    % check current directory and change to EMWET
    directory = dir();
    if contains(directory(1).folder, "Disciplines") || ...
       contains(directory(1).folder, "Functions")   || ...
       contains(directory(1).folder, "Q3D")
        cd ..\EMWET\
    elseif contains(directory(1).folder, "EMWET")
        cd .\
    else
        cd .\EMWET\
    end

    fid = fopen( 'a330.load','wt');

    % format required is n rows (where n is the number of stations where
    % the loads are defined) comprised of position along the span of the
    % current section (y_max), lift acting on the section (L_max) and
    % pitching moment acting on the section (M_max) 
    for i = 1:length(y_max)
    fprintf(fid, '%g %g %g\n',y_max(i), L_max(i), M_max(i));
    end
    
    fclose(fid)

    cd ..\

end