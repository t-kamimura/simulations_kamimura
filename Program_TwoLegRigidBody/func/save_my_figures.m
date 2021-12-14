function save_my_figures(fileName0)
    figname1 = ['fig/',fileName0,'.fig'];
    saveas(gcf, figname1, 'fig')

    figname2 = ['fig/',fileName0,'.png'];
    saveas(gcf, figname2, 'png')

    figname3 = ['fig/',fileName0,'.pdf'];
    saveas(gcf, figname3, 'pdf')

    disp('save finish!')
end