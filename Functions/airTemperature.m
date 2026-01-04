function T = airTemperature(h)

    T = (288.15 - 6.5e-3 * h) .* (h<11000) + 216.65 .* (h>=11000);

end