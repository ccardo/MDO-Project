function [] = plotWingGeometry(geom, airfoil, style)

arguments
    geom 
    airfoil 
    style = {"Color", "k"}
end
    
    % create airfoil geometry based on CST coefficients
    x = linspace(0, 1)';
    [~, yU] = CSTcurve(x, airfoil(1, 1:end/2));
    [~, yL] = CSTcurve(x, airfoil(2, (end/2+1):end));

    z = [yU(end:-1:2); yL];
    x = [x(end:-1:2); x];
    
    % rotation matrix to allow for twist
    R = @(theta) [cosd(theta) -sind(theta);
                  sind(theta)  cosd(theta)];
    
    % initialize coords & sections
    wingX = zeros(2*size(geom, 1), 1);
    wingY = zeros(2*size(geom, 1), 1);
    wingZ = zeros(2*size(geom, 1), 1);
    wingSectionR = struct();
    wingSectionL = struct();
    
    len = length(wingX);
    for i = 1:size(geom, 1)
        wingX(i) = geom(i, 1);
        wingY(i) = geom(i, 2);
        wingZ(i) = geom(i, 3);
    
        wingX(len-i+1) = wingX(i) + geom(i, 4);
        wingY(len-i+1) = wingY(i);
        wingZ(len-i+1) = wingZ(i) - geom(i, 4) * tand(geom(i, 5));

        % twist & scale by chord length
        theta = geom(i, 5);
        rotated = (R(-theta) * [x(:)'; z(:)'])' * geom(i, 4);

        wingSectionR(i).x = rotated(:, 1) + wingX(i);
        wingSectionR(i).y = 0*rotated(:, 2) + wingY(i);
        wingSectionR(i).z = rotated(:, 2) + wingZ(i);
        wingSectionL(i).x = rotated(:, 1) + wingX(i);
        wingSectionL(i).y = 0*rotated(:, 2) - wingY(i);
        wingSectionL(i).z = rotated(:, 2) + wingZ(i);
        
    end

    plot3(wingX, wingY, wingZ, style{:})
    hold on
    plot3(wingX, -wingY, wingZ, style{:})

    for i = 1:length(wingSectionL)
        plot3(wingSectionR(i).x, wingSectionR(i).y, wingSectionR(i).z, style{:})
        plot3(wingSectionL(i).x, wingSectionL(i).y, wingSectionL(i).z, style{:})
    end

    hold off

    axis equal
    xlabel("X")
    ylabel("Y")
    zlabel("Z")

end