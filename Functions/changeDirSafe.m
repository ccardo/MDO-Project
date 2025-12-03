function [result] = changeDirSafe(dirName)

    if nargin == 0
        result = -1;
        return
    end

    check.EMWET = "Q3D";
    check.Q3D = "EMWET";

    % check current dir and change it to either Q3D or EMWET
    directory = dir();
    if contains(directory(1).folder, "Disciplines") || ...
       contains(directory(1).folder, "Functions")   || ...
       contains(directory(1).folder, check.(dirName))
        cd("..\"+dirName+"\")
        result = 1;
    elseif contains(directory(1).folder, dirName)
        cd .\
        result = 1;
    else
        cd(".\"+dirName+"\")
        result = 1;
    end
end