function savePlot(fname)
    % savePlot saves the current figure with a given name

    % Prepend saved figs path
    fpath = ['../output/', fname];

    % Common formatting
    grid on;
    width = 400;
    height = 400;
    set(gcf, 'PaperPositionMode', 'auto');
    set(gcf, 'Position', [0 0 width height]);

    % Save in multiple formats to specified path
    saveas(gcf, fpath, 'fig');
    saveas(gcf, fpath, 'epsc');
    saveas(gcf, fpath, 'png');

    close gcf;
end
