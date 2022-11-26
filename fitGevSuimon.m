function pd1 = fitGevSuimon(maxD)
% FITGEVSUIMON conducts GEV fitting for given maxD data.

% coded by T.Koshiba, DPRI
% history   T.Koshiba
%           30 JUL 2020, v1

    x = maxD(:, 1);
    pd1 = fitdist(x, 'generalized extreme value');

    % Prepare figure
    figure;
    hold on;
    LegHandles = []; LegText = {};
    CustomDist = internal.stats.dfgetdistributions('generalized extreme value');
    probplot({CustomDist,[pd1.k, pd1.sigma, pd1.mu]});
    title('');


    % --- Plot data originally in dataset "x data"
    hLine = probplot(gca,x,[],[],'noref'); % add data to existing plot
    set(hLine,'Color',[0.333333 0 0.666667],'Marker','o', 'MarkerSize',6);
    xlabel('Data');
    ylabel('Probability')
    LegHandles(end+1) = hLine;
    LegText{end+1} = 'x data';

    % plot pdf
    hLine = probplot(gca,pd1);
    set(hLine,'Color',[1 0 0],'LineStyle','-', 'LineWidth',2);
    LegHandles(end+1) = hLine;
    LegText{end+1} = 'fit 1';

    % Adjust figure
    box on;
    hold off;

    % Create legend from accumulated handles and labels
    hLegend = legend(LegHandles,LegText,'Orientation', 'vertical',...
                     'FontSize', 9, 'Location', 'northeast');
    set(hLegend,'Interpreter','none');
end