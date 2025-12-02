function mu = sutherland(T)

%   This function uses the standard constants for air:
%       T0 = 273.15 K
%       mu0 = 1.716e-5 kg/(m·s)
%       S  = 110.4 K


    T0  = 273.15;          % Reference temperature (K)
    mu0 = 1.716e-5;        % Reference viscosity (kg/m·s)
    S   = 110.4;           % Sutherland constant (K)

    mu = mu0 * (T / T0)^(3/2) * (T0 + S) / (T + S);
    
end
