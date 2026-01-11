function [] = inputStructuresLoads(y_max, L_max, M_max)

    % Write the file given to EMWET as input where the sizing loads are
    % defined

    % print the file in the current folder 
    fid = fopen( 'a330.load','wt');

    % format required is n rows (where n is the number of stations where
    % the loads are defined) comprised of position along the span of the
    % current section (y_max), lift acting on the section (L_max) and
    % pitching moment acting on the section (M_max) 

    for i = 1:length(y_max)
    fprintf(fid, '%g %g %g\n',y_max(i), L_max(i), M_max(i));
    end
    
    fclose(fid);

end