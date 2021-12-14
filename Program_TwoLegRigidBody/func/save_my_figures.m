function save_my_figures(fileName0)
    figname1 = [figname0,'.fig'];
    saveas(gcf, figname1, 'fig')
    figname2 = [figname0,'.png'];
    saveas(gcf, figname2, 'png')
    figname3 = [figname0,'.pdf'];
    saveas(gcf, figname3, 'pdf')
    disp('save finish!'))
end