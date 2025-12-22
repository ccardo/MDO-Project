function stop = outConst(~,~,state) 
    stop = false; % false --> optimization continues | true --> optimization stops
    persistent c_hist

    switch state
        case 'init'
            c_hist = []; % initialize the array
        case 'iter'
            [c, ~] = constraints();
            c_hist = [c_hist; c']; % first column is the results of c1, while the second is the results of c2
        case 'done'
            assignin('base','c_hist',c_hist); % returns the result in the main.m workspace
    end
end