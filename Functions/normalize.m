function [v_norm, key] = normalize(v, setting, key)

    arguments
        v 
        setting = "norm"
        key = ones(numel(v), 1);
    end


    % normalize (divide)
    if setting == "norm" && all(key == 1)
        key = v;
        v_norm = v ./ v;
    
    % denormalize (multiply by key)
    elseif setting == "denorm" && any(key ~= 1)
        v_norm = v .* key;
    
    % wrong setting
    else
        msg = "Incorrect normalization parameters: key = " + key + ", setting = " + setting;
        error(msg)

    end

end