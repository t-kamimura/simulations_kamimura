function plot_legStates(tout, lout, gout, saveFlag)
    
    % 脚長のグラフ
    figure
    plot(tout, lout(:, 1));
    hold on
    plot(tout, lout(:, 2), '--');
    xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
    ylabel('$$l_{\rm h},l_{\rm f}$$', 'interpreter', 'latex', 'Fontsize', 14);
    xlim([0, max(tout)]);
    ylim([min(lout(:, 1)) - 0.01, 1.1 * max(lout(:,1))]);
    legend({'hind leg', 'fore leg'}, 'Location', 'best')

    figname = ['legLengths'];
    if saveFlag == 1
        save_my_figures(figname);
    end

    % 脚角度のグラフ
    figure
    plot(tout, gout(:, 1));
    hold on
    plot(tout, gout(:, 2), '--r');
    xlim([0, max(tout)]);
    xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
    ylabel('$$\gamma_{\rm h},\gamma_{\rm f}$$', 'interpreter', 'latex', 'Fontsize', 14);
    legend({'hind leg', 'fore leg'}, 'Location', 'best')

    figname = ['legAngles'];
    if saveFlag == 1
        save_my_figures(figname);
    end

end