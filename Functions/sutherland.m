function mu = sutherland(T)

%   This function uses the standard constants for air:
%       T0 = 273.15 K
%       mu0 = 1.716e-5 kg/(m*s)
%       S  = 110.4 K

    T0  = 273.15;
    mu0 = 1.716e-5;
    S   = 110.4;

    mu = mu0 * (T / T0)^(3/2) * (T0 + S) / (T + S);
    
end
