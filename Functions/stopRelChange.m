function stop = stopRelChange(~, optimValues, state)

    %{
    Return stop = true (and stop fmincon) if the relative change in
    objective function has been less than the set tolerance for a set
    number of iterations.
    %}
        
    persistent previousF iterStall
    stop = false;

    try
        currentF = optimValues.fval;
    catch
        optimValues.fval = 1e9;
    end

    switch state
        case "init"
            previousF = optimValues.fval;
            iterStall = 0;

        case "iter"
            currentF = optimValues.fval;

            % tolerances for relative change
            % tolRel = 1e-5 is under a kilometer
            tolRel = 1e-6;
            tolStall = 4;

            changeRel = abs((currentF - previousF)/previousF);
            fprintf("Relative change in R: %.2e", changeRel)
            if changeRel < tolRel
                iterStall = iterStall + 1;
            else
                iterStall = 0;
            end

            if iterStall > tolStall
                fprintf('Stopping: relative ΔR/R < %.2e for %d iterations\n', ...
                            tolRel, tolStall);
                stop = true;
            end
            previousF = optimValues.fval;
            
        case "done" % do nothing in case solver is already done
    end
end