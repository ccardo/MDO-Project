function rho = airDensity(h)

    rho = 1.225 * (airTemperature(h)/288.15) ^ (5.2561-1);

end