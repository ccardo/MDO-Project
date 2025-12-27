function saveFigures(figureNumbers)
    
arguments
    figureNumbers {mustBeNonempty}
end
    
    for i = 1:length(figureNumbers)
        n = figureNumbers(i);
        gcf = figure(n);
        filename = gcf.Name;
        saveas(gcf, filename, "pdf")
    end
end