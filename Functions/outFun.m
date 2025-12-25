function stop = outFun(~,optimValues,state) 
    stop = false; % false --> optimization continues | true --> optimization stops
    persistent f_hist

    switch state
        case 'init'
            f_hist = []; % initialize the array
        case 'iter'
            f = optimValues.fval;
            f_hist = [f_hist; f]; 
        case 'done'
            assignin('base','f_hist',f_hist); % returns the result in the main.m workspace
    end
end