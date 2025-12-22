function stop = outWWing(~,~,state) 
    stop = false; % false --> optimization continues | true --> optimization stops
    persistent W_wing_hist
    global Constraints

    switch state
        case 'init'
            W_wing_hist = []; % initialize the array
        case 'iter'
            W_wing = Constraints.W_wing;
            W_wing_hist = [W_wing_hist; W_wing]; 
        case 'done'
            assignin('base','W_wing_hist',W_wing_hist); % returns the result in the main.m workspace
    end
end