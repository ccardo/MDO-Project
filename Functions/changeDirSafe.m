function [result] = changeDirSafe(dirName)
    
    if nargin == 0
        result = -1;
        return
    end
    
    % The project directory has to be changed to MDO-Project (as is the
    % name of the GitHub repository) for this to work!
    check.EMWET = "Q3D";
    check.Q3D = "EMWET";

    % get current working directory
    directory = dir();
    parentFolder = directory(1).folder;

    % if current working directory IS Disciplines, Functions or
    % check.(dirName): go up a folder and change dir to dirName
    if contains(parentFolder, "Disciplines") || ...
       contains(parentFolder, "Functions")   || ...
       contains(parentFolder, check.(dirName))
        cd ..\
        cd(dirName)
        result = 1;

    % else, if the current working directory is already dirName: do nothing
    elseif contains(parentFolder, dirName)
        result = 1;

    % else, if the current working directory is projectDirectory then stay 
    % in the same folder and change to dirName (check: contains main, MDA,
    % Optimizer) 

    elseif any(strcmp(deblank(string(ls)), "main.m")) && ...
            any(strcmp(deblank(string(ls)), "MDA.m")) && ...
            any(strcmp(deblank(string(ls)), "Optimizer.m"))
        cd(dirName)
        result = 1;

    % in any other case: return an error
    else
        result = -1;
        error("ERROR: current working directory outside of scope: "+parentFolder)
    end
end