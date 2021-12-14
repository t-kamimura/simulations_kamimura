function plot_energy(tout, Eout, saveFlag)

    figure
    Eout_ = [Eout(:, 1), Eout(:, 2), Eout(:, 3), Eout(:, 4), Eout(:, 5)];
    area(tout, Eout_)
    xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
    ylabel('Energy', 'interpreter', 'latex', 'Fontsize', 14);
    legend('trans.', 'rot.', 'grav.', 'hind leg', 'fore leg')
    xlim([0, tout(end)])
    ylim([0, max(Eout(:, 6))])
    
    figname = ['energyProfile'];
    if saveFlag == 1
        save_my_figures(figname);
    end
end