function stop = outFun(~,optimValues,state) 
    stop = false; % false --> optimization continues | true --> optimization stops
    persistent f_hist
    global FixedValues

    switch state
        case 'init'
            f_hist = []; % initialize the array
        case 'iter'
            try
                f = optimValues.fval * FixedValues.Performance.R_ref; % denormalize the objective function
                f_hist = [f_hist; f]; 
            catch
                f_hist = [f_hist; NaN]; 
            end
        case 'done'
            assignin('base','f_hist',f_hist); % returns the result in the main.m workspace
    end
end