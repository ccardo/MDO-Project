function [result] = changeDirSafe(dirName)

    if nargin == 0
        result = -1;
        return
    end

    check.EMWET = "Q3D";
    check.Q3D = "EMWET";

    % check current dir and change it to either Q3D or EMWET
    directory = dir();
    parentFolder = directory(1).folder;
    if contains(parentFolder, "Disciplines") || ...
       contains(parentFolder, "Functions")
        cd .\
        cd(parentFolder+"\"+dirName)
        result = 1;
    elseif contains(parentFolder, dirName)
        cd .\
        result = 1;
    else
        cd ..\
        cd(parentFolder+"\"+check.(dirName)+"\"+dirName)
        result = 1;
    end
end