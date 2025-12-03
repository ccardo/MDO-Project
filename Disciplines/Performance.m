function [R] = Performance(Aircraft, L_des, D_des, MTOW, v)
    
    global FixedValues;

    M_des = v(1);
    h_des = v(2);
    W_f = FixedValues.Weight.W_f;
    V_des_ref = FixedValues.Performance.V_des_ref;
    h_des_ref = FixedValues.Performance.h_des_ref;
    CT_ref = FixedValues.Performance.CT_ref;

    V_des = M_des * airSoundSpeed(h_des);
    
    % Compute performance through given functions
    eta = exp( -(V_des - V_des_ref)^2/(2*70^2) + ...
               -(h_des - h_des_ref)^2/(2*2500^2) );
    CT = CT_ref / eta;
    Wend_Wstart = 1/0.938 * (1 - W_f/MTOW);
    Wstart_Wend = 1 / Wend_Wstart;
    
    % Compute the range.
    R = V_des * L_des / (CT * D_des) * log(Wstart_Wend);

end