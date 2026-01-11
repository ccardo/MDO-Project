function a = airSoundSpeed(h)
    
    % air sound speed based on air temperature
    a = sqrt(1.4 * 287.05 * airTemperature(h));

end