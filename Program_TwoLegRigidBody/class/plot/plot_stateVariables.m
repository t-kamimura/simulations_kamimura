function plot_stateVariables(tout, qout, saveFlag)

    % rad2deg
    qout(:, 3) = qout(:, 3) * 180 / pi; %degに変換
    qout(:, 6) = qout(:, 6) * 180 / pi; %degに変換;


    qlabelset = {'$$x$$', '$$y$$', '$$\theta$$', ...
                '$$\dot{x}$$', '$$\dot{y}$$', '$$\dot{\theta}$$'};
    
    figure
    for pp = 1:6
        subplot(2, 3, pp)
        plot(tout, qout(:, pp));
        hold on
        xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
        ylabel(qlabelset{pp}, 'interpreter', 'latex', 'Fontsize', 14);
        xlim([0, max(tout)]);
    end

    figname = ['stateVariables'];
    if saveFlag == 1
        save_my_figures(figname);
    end
    
end