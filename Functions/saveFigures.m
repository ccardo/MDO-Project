function saveFigures(figureNumbers, format)
    
arguments
    figureNumbers = "all"
    format {mustBeText} = "png"
end
    
    if isempty(figureNumbers)
        figureNumbers = "all";
    end

    if num2str(figureNumbers) == "all"
        figureNumbers = findobj("Type", "figure");
    end

    for i = 1:length(figureNumbers)
        n = figureNumbers(i);
        gcf = figure(n);
        filename = gcf.Name;
        for F = 1:length(format)
            saveas(gcf, filename, format(F))
        end
    end
end