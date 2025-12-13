function [bound_norm, key] = normalizeBounds(bound, v)

     bound_norm = bound ./ v;
     key = v;

end