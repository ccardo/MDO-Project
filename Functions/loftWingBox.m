function [Boxes] = loftWingBox(Aircraft, nLayers, nPoints, makePlot)

    arguments (Input)
        Aircraft                            % Struct, formatted in the same way as the Q3D "AC".
        nLayers {mustBeNonempty} = 20       % n. of layers in the lofted surface
        nPoints {mustBeNonempty} = 20       % n. of points with which to interpolate each upper and lower side of the sections
        makePlot {mustBeNonempty} = 0       % boolean (0 or 1)
    end
    
    global FixedValues;

    % extract relevant quantities
    geom = Aircraft.Wing.Geom;
    airfoil = Aircraft.Wing.Airfoils;
    spars = FixedValues.Geometry.spars;
    fuelTankStart = FixedValues.Geometry.tank(1);
    fuelTankEnd = FixedValues.Geometry.tank(2);

    span = geom(end, 2);
    lastSectionSpan = span - geom(end-1,2);
    firstSectionSpan = geom(2,2) - geom(1,2);
    % normalize FT start and end with their section length
    fuelTankEnd = (lastSectionSpan - span * (1 - fuelTankEnd)) / lastSectionSpan;
    fuelTankStart = (firstSectionSpan - span * fuelTankStart) / firstSectionSpan;
    
    % create airfoil curves
    CSTU = airfoil(1, 1:end/2);
    CSTL = airfoil(1, (end/2+1):end);
    x = linspace(0, 1, 10000)';
    [~, zU] = CSTcurve(x, CSTU);
    [~, zL] = CSTcurve(x, CSTL);

    % set n. of points for the front spar and rear spar sides
    Nspar = 2;

    Boxes = struct();
    
    for i = 1:size(geom, 1)-1
    
        % pull out the spar locations for current and next section.
        frontSpar1 = spars(i,1);
        rearSpar1 = spars(i,2);
        frontSpar2 = spars(i+1,1);
        rearSpar2 = spars(i+1,2);
        
        % difference in twist of the two surfaces
        twist1 = deg2rad(geom(i, 5));
        twist2 = deg2rad(geom(i+1, 5));
        
        % chord lengths
        c1 = geom(i, 4);
        c2 = geom(i+1, 4);
        
        % LE positions
        LEx1 = geom(i, 1);
        LEy1 = geom(i, 2);
        LEz1 = geom(i, 3);

        LEx2 = geom(i+1, 1);
        LEy2 = geom(i+1, 2);
        LEz2 = geom(i+1, 3);
    
        % ------------------------------------------------------------------ %
        % ---------------------- CREATING BASE CURVES ---------------------- %
        % ------------------------------------------------------------------ %
        
        % compute intersections with spars (ATTENTION: I overwrite the indices
        % of section 1 with  the ones of section 2 (iFront, iRear) both for the
        % upper and lower surfaces.
        %
        % NOTE: remove extremum elements of Front and RearSide because they
        % will be duplicates with the extremum elements of Upper and LowerSide.
        % The last element of FrontSide stays because this will close the
        % lofted surface (try to run the code without that last element)
        [~, iF] = min(abs(x - frontSpar1));
        [~, iR] = min(abs(x - rearSpar1));
        UpperSide1 = [x(iF:iR), zeros(length(x(iF:iR)), 1), zU(iF:iR)] * c1; % x y z
        [~, iF] = min(abs(x - frontSpar1));
        [~, iR] = min(abs(x - rearSpar1));
        LowerSide1 = [x(iF:iR), zeros(length(x(iF:iR)), 1), zL(iF:iR)] * c1;
        
        FrontSide1 = [x(iF) * ones(Nspar,1), zeros(Nspar, 1), linspace(zL(iF), zU(iF), Nspar)'] * c1;
        FrontSide1(1, :) = [];
        RearSide1 = [x(iR) * ones(Nspar,1), zeros(Nspar, 1), linspace(zL(iR), zU(iR), Nspar)'] * c1;
        RearSide1(1, :) = [];
        RearSide1(end, :) = [];
    
        % NOW the other section is: shifted and twisted (relative to Sect. 1)
        % first you scale and compute the intersections, then you shift and
        % twist the section to match the next airfoil of the wing.
        [~, iF] = min(abs(x - frontSpar2));
        [~, iR] = min(abs(x - rearSpar2));
        UpperSide2 = [x(iF:iR), zeros(length(x(iF:iR)), 1), zU(iF:iR)] * c2; % x y z
        [~, iF] = min(abs(x - frontSpar2));
        [~, iR] = min(abs(x - rearSpar2));
        LowerSide2 = [x(iF:iR), zeros(length(x(iF:iR)), 1), zL(iF:iR)] * c2;
    
        FrontSide2 = [x(iF) * ones(Nspar,1), zeros(Nspar, 1), linspace(zL(iF), zU(iF), Nspar)'] * c2;
        FrontSide2(1, :) = [];
        RearSide2 = [x(iR) * ones(Nspar,1), zeros(Nspar, 1), linspace(zL(iR), zU(iR), Nspar)'] * c2;
        RearSide2(1, :) = [];
        RearSide2(end, :) = [];
    
        % before going forward we must make sure that section 1 and 2 are
        % compatible, i.e. have the same number of points.
        intU1 = griddedInterpolant(UpperSide1(:, 1), UpperSide1(:, 3), "linear");
        intL1 = griddedInterpolant(LowerSide1(:, 1), LowerSide1(:, 3), "linear");
        intU2 = griddedInterpolant(UpperSide2(:, 1), UpperSide2(:, 3), "linear");
        intL2 = griddedInterpolant(LowerSide2(:, 1), LowerSide2(:, 3), "linear");
        
        % for section 1
        xInterp1 = linspace(UpperSide1(1, 1), UpperSide1(end, 1), nPoints)';
        UpperSide1 = [xInterp1, zeros(nPoints, 1), intU1(xInterp1)];
        LowerSide1 = [xInterp1, zeros(nPoints, 1), intL1(xInterp1)];
    
        % and section 2
        xInterp2 = linspace(UpperSide2(1, 1), UpperSide2(end, 1), nPoints)';
        UpperSide2 = [xInterp2, zeros(nPoints, 1), intU2(xInterp2)];
        LowerSide2 = [xInterp2, zeros(nPoints, 1), intL2(xInterp2)];

        % Order the points so that they form a single curve (clockwise) for
        % both Section 1 and 2 ==> Starting point: top left.
        RearSide1 = RearSide1(end:-1:1, :);
        LowerSide1 = LowerSide1(end:-1:1, :);
        Section1 = [UpperSide1; RearSide1; LowerSide1; FrontSide1];
    
        RearSide2 = RearSide2(end:-1:1, :);
        LowerSide2 = LowerSide2(end:-1:1, :);
        Section2 = [UpperSide2; RearSide2; LowerSide2; FrontSide2];
        
        % Now we twist and shift the sections.
        Section1 = twistSection(Section1, twist1);
        Section1 = shiftSection(Section1, [LEx1 LEy1 LEz1]);

        Section2 = twistSection(Section2, twist2);
        Section2 = shiftSection(Section2, [LEx2 LEy2 LEz2]);
 
        
        % ------------------------------------------------------------------ %
        % ---------------------- LOFTING THE SURFACE ----------------------- %
        % ------------------------------------------------------------------ %

        % first, linearly interpolate between the two panels to get the
        % fuel tank ending "y" and not the tip coord (same for tank start)
        if i == 1
            SectionStart = fuelTankStart * Section1 + ...
                           (1 - fuelTankStart)  * Section2;
            SectionEnd = Section2;
        elseif i == size(geom, 1)-1
            SectionStart = Section1;
            SectionEnd = (1 - fuelTankEnd) * Section1 + ...
                            + fuelTankEnd  * Section2;  
        end
        
        % Loft the curve into a surface from section 1 to 2 by linearly
        % interpolating, sliding along the parameter "t".
        t = linspace(0, 1, nLayers);
        
        % now for each point we linearly interpolate up to the corresponding
        % point in section 2.
        X = (1 - t) .* SectionStart(:, 1) + t .* SectionEnd(:, 1);
        Y = (1 - t) .* SectionStart(:, 2) + t .* SectionEnd(:, 2);
        Z = (1 - t) .* SectionStart(:, 3) + t .* SectionEnd(:, 3);
        
        % finally assign them to the returning struct.
        Boxes(i).X = X;
        Boxes(i).Y = Y;
        Boxes(i).Z = Z;
        
        % optionally plot
        if makePlot
    
            figure("Name", "Wing Box Part"+i)
    
            surf(X, Y, Z, ...
             'FaceColor', [0.8 0.8 1], ...
             'EdgeColor', 'k', ...
             'FaceAlpha', 0.7, ...
             "FaceLighting", "flat");
        
            axis equal
            xlabel X; ylabel Y; zlabel Z
            title('Lofted Surface Between Two Arbitrary Shapes');
        end
    end
end

function rotatedCurve = twistSection(curve, theta)

    % rotation matrix about the Y axis (so on the XZ plane)
    Ry = [ cos(theta)  0  sin(theta)
               0       1       0    
          -sin(theta)  0  cos(theta)];

    if size(curve, 1) ~= 3
        curve = curve';
    end 

    rotatedCurve = (Ry * curve)';
    
end

function shiftedCurve = shiftSection(curve, vec)

    vec = vec(:);
    if length(vec) ~= 3
        error("Shifting vector must be 3-dimensional")
    end
    len = size(curve, 1);

    shiftedCurve = curve + ones(len, 1) * vec';

end