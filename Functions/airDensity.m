function rho = airDensity(h)

          % adiabatic troposphere, isothermal stratosphere
    rho = 1.225 * (airTemperature(h)/288.15) .^ (5.2561-1) .* (h <= 11000) + ...
        0.3639 * exp(-157.69e-6 * (h - 11000)) .* (h > 11000);

end