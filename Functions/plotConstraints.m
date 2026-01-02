function [] = plotConstraints(c_hist, iterCount)
figure(12)
set(gcf, 'Name', 'Constraints', 'NumberTitle', 'off')
c1 = c_hist(:,1);
c2 = c_hist(:,2);
plot(0:iterCount, c1, 'r.-', 'MarkerSize', 20, "LineWidth", 2)
hold on
plot(0:iterCount, c2, 'b.-', 'MarkerSize', 20, "LineWidth", 2)
yl = [1e-3 , min(c_hist, [], "all")-0.02 , min(c_hist, [], "all")-0.02, 1e-3];  
patch([0, 0, 22, 22], yl, 'green', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
axis tight
ylim([min(c_hist, [], "all")-0.02, max(c_hist, [], "all")+0.05])
title("Convergence history of the constraints")
xlabel("Iteration")
ylabel("Constraint value")
L = legend("Constraint on wing loading", "Constraint on fuel tank volume");
L.FontSize = 15;
L.Location = "best";
hold off
grid minor
