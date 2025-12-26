function stop = outInformation(x, optimValues, state)
    
    stop = false;
    persistent iterHistory

    switch state
        case 'init'
            % initialize the array
            iterHistory = struct();

        case 'iter'
            % save those values for every iteration
            iterHistory.firstOrderOptimality(:,end+1) = optimValues.firstorderopt;
            iterHistory.constraintViolation(:,end+1) = optimValues.constrviolation;
            iterHistory.stepSize(:,end+1) = optimValues.stepsize;
            iterHistory.functionCount(:,end+1) = optimValues.funccount;
            iterHistory.designVector(:,end+1) = x;

        case 'done'
            % return the result to the main.m workspace
            assignin('base', 'iter_hist', iterHistory); 
    end
end