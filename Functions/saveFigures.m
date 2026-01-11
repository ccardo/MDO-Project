function saveFigures(figureNumbers, format)
    
arguments
    figureNumbers = "all"
    format {mustBeText} = "png"
end
    
    % if unspecified, save all figures
    if isempty(figureNumbers)
        figureNumbers = "all";
    end
    
    % if "all", save all active figures
    if num2str(figureNumbers) == "all"
        figureNumbers = findobj("Type", "figure");
    end
    
    % loop through figures and save.
    for i = 1:length(figureNumbers)
        n = figureNumbers(i).Number;
        fig = figure(n);
        filename = fig.Name;

        if isempty(filename)
            filename = sprintf("Figure %d", n);
        end

        for F = 1:length(format)
            saveas(fig, filename, format(F))
        end
    end
end