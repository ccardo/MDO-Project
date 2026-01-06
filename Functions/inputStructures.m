function [] = inputStructures(Aircraft, MTOW, v, FixedValues)

    % global FixedValues

    MZF           =    MTOW - FixedValues.Weight.W_f + FixedValues.Weight.deltaPayload ;   %[kg]
    n_max         =    FixedValues.Performance.nMax;  
    span          =   2* (FixedValues.Geometry.A1 + v(20));            %[m]
    c_root        =    Aircraft.Wing.Geom(1,4); 
    c_kink        =    Aircraft.Wing.Geom(2,4);
    c_tip         =    Aircraft.Wing.Geom(3,4);          
    spar_front_1  =    FixedValues.Geometry.spars(1,1);
    spar_front_2  =    FixedValues.Geometry.spars(2,1);
    spar_front_3  =    FixedValues.Geometry.spars(3,1);
    spar_rear_1   =    FixedValues.Geometry.spars(1,2);
    spar_rear_2   =    FixedValues.Geometry.spars(2,2);
    spar_rear_3   =    FixedValues.Geometry.spars(3,2);
    ftank_start   =    FixedValues.Geometry.tank(1);
    ftank_end     =    FixedValues.Geometry.tank(2);
    eng_num       =    1; 
    eng_ypos      =    0.3;          % [%]
    eng_mass      =    5851;         % P&W 4170 [kg]
    E_al          =    70.1E9;       % [N/m2] 
    rho_al        =    2800;         % [kg/m3]
    Ft_al         =    5.3E8;        % [N/m2]
    Fc_al         =    5.3E8;        % [N/m2] 
    pitch_rib     =    0.5;          % [m]
    eff_factor    =    0.96;             
    Airfoil       =    'current_airfoil';
    section_num   =    3;
    airfoil_num   =    3;
    A             = wingArea(Aircraft.Wing.Geom);
    
    % define the leading edge postions of the airfoils that generate the
    % planform
    x1 = Aircraft.Wing.Geom(1,1);
    y1 = Aircraft.Wing.Geom(1,2);
    z1 = Aircraft.Wing.Geom(1,3);
    x2 = Aircraft.Wing.Geom(2,1);
    y2 = Aircraft.Wing.Geom(2,2);
    z2 = Aircraft.Wing.Geom(2,3);
    x3 = Aircraft.Wing.Geom(3,1);
    y3 = Aircraft.Wing.Geom(3,2);
    z3 = Aircraft.Wing.Geom(3,3);

    % print the file inside the current directory (should be \EMWET\)
    fid = fopen( 'a330.init','wt');
    fprintf(fid, '%g %g \n',MTOW,MZF);
    fprintf(fid, '%g \n',n_max);
    
    fprintf(fid, '%g %g %g %g \n',A,span,section_num,airfoil_num);
    
    fprintf(fid, '0 %s \n',Airfoil);
    fprintf(fid, '%g %s \n', FixedValues.Geometry.A1/(FixedValues.Geometry.A1+v(20)),Airfoil);
    fprintf(fid, '1 %s \n',Airfoil);
    fprintf(fid, '%g %g %g %g %g %g \n',c_root,x1,y1,z1,spar_front_1,spar_rear_1);
    fprintf(fid, '%g %g %g %g %g %g \n',c_kink,x2,y2,z2,spar_front_2,spar_rear_2);
    fprintf(fid, '%g %g %g %g %g %g \n',c_tip,x3,y3,z3,spar_front_3,spar_rear_3);
    
    fprintf(fid, '%g %g \n',ftank_start,ftank_end);
    
    fprintf(fid, '%g \n', eng_num);
    fprintf(fid, '%g  %g \n', eng_ypos,eng_mass);
    
    fprintf(fid, '%g %g %g %g \n',E_al,rho_al,Ft_al,Fc_al);
    fprintf(fid, '%g %g %g %g \n',E_al,rho_al,Ft_al,Fc_al);
    fprintf(fid, '%g %g %g %g \n',E_al,rho_al,Ft_al,Fc_al);
    fprintf(fid, '%g %g %g %g \n',E_al,rho_al,Ft_al,Fc_al);
    
    fprintf(fid,'%g %g \n',eff_factor,pitch_rib);
    fprintf(fid,'0 \n');
    fclose(fid);

end
