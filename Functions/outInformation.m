function stop = outInformation(x, optimValues, state)
    
    stop = false;
    persistent iterHistory

    switch state
        case 'init'
            % initialize the array
            iterHistory = struct();
            iterHistory.firstOrderOptimality = [];
            iterHistory.constraintViolation = [];
            iterHistory.stepSize = [];
            iterHistory.functionCount = [];
            iterHistory.designVector = [];

        case 'iter'
            % save those values for every iteration
            try 
                iterHistory.firstOrderOptimality(:,end+1) = optimValues.firstorderopt;
                iterHistory.constraintViolation(:,end+1) = optimValues.constrviolation;
                iterHistory.stepSize(:,end+1) = optimValues.stepsize;
                iterHistory.functionCount(:,end+1) = optimValues.funccount;
                iterHistory.designVector(:,end+1) = x;
            catch
                % if somehow optimValues is empty, an error is raised.
                % Catch it and set everything to NaN.
                disp(optimValues)
                iterHistory.firstOrderOptimality(:,end+1) = NaN;
                iterHistory.constraintViolation(:,end+1) = NaN;
                iterHistory.stepSize(:,end+1) = NaN;
                iterHistory.functionCount(:,end+1) = NaN;
                iterHistory.designVector(:,end+1) = x;
            end

        case 'done'
            % return the result to the main.m workspace
            assignin('base', 'iter_hist', iterHistory); 
    end
end