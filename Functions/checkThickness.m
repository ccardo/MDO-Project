function [t_max] = checkThickness(T,B)

x = ((1 - cos(linspace(0, pi)))/2);
[~, yT] = CSTcurve(x, T);
[~, yB] = CSTcurve(x, B);
yT = yT(:);
yB = yB(:);
t = zeros(1,length(yT));
for i = 1:length(yT)
    t(i) = abs(yT(i)) + abs(yB(i));
end

t_max = max(t);

end
