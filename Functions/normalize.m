function [v_norm, key] = normalize(v, setting, key)

    arguments
        v 
        setting = "norm"
        key = ones(numel(v), 1);
    end

    % normalize (divide) // note: if the element in V is <0, the division
    % will keep its sign to ensure consistency with upper and lower bounds.
    if setting == "norm" && all(key == 1) % to normalize no key is necessary
        key = abs(v);
        v_norm = v ./ key;
    
    % denormalize (multiply by key)
    elseif setting == "denorm" && any(key ~= 1)
        v_norm = v .* key;
    
    % wrong setting
    else
        msg = "Incorrect normalization parameters: key = " + key + ", setting = " + setting;
        error(msg)

    end

end