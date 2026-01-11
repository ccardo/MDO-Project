function VOLUME = boxVolume(X, Y, Z)
    
    % inputs = surface mesh points that define the 3d wing box.
    arguments (Input)
        X                 
        Y
        Z
    end

    loftLayers = size(X, 2);
    vol = zeros(loftLayers-1, 1);
    for i = 1:loftLayers-1
        
        % get "ring" base perimeters and witdh
        contour1 = [X(:, i) Z(:, i)];
        contour2 = [X(:, i+1) Z(:, i+1)];
        height = Y(1, i+1) - Y(1, i);

        % area of the sections
        Area1 = polyarea(contour1(:, 1), contour1(:, 2));
        Area2 = polyarea(contour2(:, 1), contour2(:, 2));
        
        % volume of this chunk of solid
        vol(i) = height/3 * (Area1 + Area2 + sqrt(Area1 * Area2));

    end

    VOLUME = sum(vol);

end