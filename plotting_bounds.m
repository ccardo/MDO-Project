close all

% Extract bounds
B = BOUNDS.normalized;
lb = B(:,1);
ub = B(:,2);

% Extract final design vector
x = OUTPUT.bestfeasible.x;

% Extract design vector
x = ITERATIONS.designVectorNorm;

% "normalized" between 0 and 1 to see relative bound proximity
eta = (x - lb) ./ (ub - lb);
ksi_ub = ones(1, size(x,2));
ksi_lb = zeros(1, size(x,2));

n = size(x,1);
variable_names = ["M_{des}", "h_{des}", "c_k", "\lambda_{outboard}", ...
                  "T_1", 'T_2', 'T_3', 'T_4', 'T_5', 'T_6', 'T_7', ...
                  'B_1', 'B_2', 'B_3', 'B_4', 'B_5', 'B_6', 'B_7', ...
                  '\Lambda_{LE}', 'A_2'];


figure(1); hold on
figure(2); hold on
colormap("sky")
cmap = sky(size(x,2));
for i = 1:n
    dash_b = [i-0.3 i+0.3];
    dash_x = [i-0.2 i+0.2];
    
    % fmincon design variables
    figure(1)
    hold on
    
    level_ub = [ub(i) ub(i)];
    level_lb = [lb(i) lb(i)];
    level_x = [x(i,:); x(i,:)];
    plot([i i], [lb(i) ub(i)], "k");
    plot(dash_b, level_lb, "k");
    plot(dash_b, level_ub, "k");
    plot(dash_x, level_x, "r");
    
    if any(i == 1:11)
        text(i, level_lb(1)-0.5,  variable_names(i), "VerticalAlignment", "middle", "Rotation", 90, "HorizontalAlignment", "right")
    elseif any(i == 12:20)
        text(i, level_ub(1)+0.5,  variable_names(i), "VerticalAlignment", "middle", "Rotation", 90, "HorizontalAlignment", "left")
    end


    % normalized bounds in [0,1]
    figure(2)
    set(gca, 'ColorOrder', cmap, 'NextPlot', 'ReplaceChildren')
    hold on

    level_ksi_ub = [1 1];
    level_ksi_lb = [0 0];
    level_eta = [eta(i,:); eta(i,:)];
    plot([i i], [0 1], "k")
    plot(dash_b, level_ksi_lb, "k")
    plot(dash_b, level_ksi_ub, "k")
    plot(dash_x, level_eta, Linewidth=1)

    text(i, 1.02,  variable_names(i), ...
        "FontSize", 12, ...
        "VerticalAlignment", "middle", ...
        "Rotation", 90)

end

figure(1)
set(gcf, "Name", "Design Vector Bounds")
xlabel('Design variable index', FontSize=14)
ylabel('Value', FontSize=14)
axis padded
title('Final design vector relative to bounds')
legend("Bounds", "", "", "", "Variable")
grid minor

figure(2)
set(gcf, "Name", "Design Vector Bounds Relative")
ylabel('Design variable index', FontSize=14)
xlabel('Value relative to bounds', FontSize=14)
xlim([0 21])
ylim([-0.05 1.20])
pbaspect([3.5 1 1])
title('Design vector relative to bounds', FontSize=20, FontName="Times New Roman")
clim([0 size(x,2)])
grid minor
% legend("Bounds", "", "", "", "", "", "Variable")
axis off
set(colorbar, "ytick", 0:3:21)
ylabel(colorbar, "Iteration")