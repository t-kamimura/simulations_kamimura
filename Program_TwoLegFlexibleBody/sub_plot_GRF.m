% fileName: sub_calc_stabolity.m
% initDate: 2021/9/8
% Object:  すでに見つかっている解の安定性を求める

clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaultAxesFontSize', 16);
set(0, 'defaultAxesFontName', 'times');
set(0, 'defaultTextFontSize', 16);
set(0, 'defaultTextFontName', 'times');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Construct a questdlg with three options
choice = questdlg('Do you want to save the result(s)?', ...
    'Saving opptions', ...
    'Yes', 'No', 'Yes');
% Handle response
saveflag = false;

switch choice
    case 'Yes'
        saveflag = true;
    case 'No'
        saveflag = false;
end

% path追加
addpath(pwd, 'class')
addpath(pwd, 'symbolic')
addpath(pwd, 'eom')
addpath(pwd, 'event')
addpath(pwd, 'func')
addpath(pwd, 'data')
addpath(pwd, 'fig')

% 定数の決定
model = Twoleg;

E0 = 4500; % [J]

%% データの抜き出し

filename = ['data/fixedPoints_for_E0=', num2str(E0), '_interporated_minus.mat'];
% filename = ['data/fixedPoints_for_E0=', num2str(E0), '_interporated_plus.mat'];
load(filename);

%% 解の描画
% カラーマップにする
h1 = figure();
h1.Renderer = "painters";
GRFset = NaN(length(dtheta0set),length(y0set));
for i_y = 1:length(y0set)
    y0 = y0set(i_y);
    for i_dtheta = 1:length(dtheta0set)
        dtheta0 = dtheta0set(i_dtheta);
        if isempty(solset(i_y,i_dtheta).q_ini)
        else
            GRFset(i_dtheta,i_y) = solset(i_y,i_dtheta).GRF;
        end
    end
end

surf(y0set,dtheta0set,GRFset,'FaceColor','interp','LineStyle','none')
view(2)
xlabel('$$y$$ [m]','Interpreter','latex')
ylabel('$$\dot{\theta}$$ [rad/s]','Interpreter','latex')

% xlim([min(y0set),max(y0set)])
% ylim([-max(abs(dtheta0set)),max(abs(dtheta0set))])
xlim([0.6,0.75])
ylim([-2.25,2.25])
caxis([1000 2500])
colorbar
colormap jet

if saveflag == true
    figname_png = ['fig/GRF_colormap_E0=',num2str(E0),'.png'];
    figname_fig = ['fig/GRF_colormap_E0=',num2str(E0),'.fig'];
    figname_pdf = ['fig/GRF_colormap_E0=',num2str(E0),'.pdf'];
    saveas(gcf, figname_png)
    saveas(gcf, figname_fig)
    saveas(gcf, figname_pdf)
    disp('save finish!')
end
%%
h2 = figure();
h2.Renderer = "painters";
v = 1000:200:2500;
contour(y0set,dtheta0set,GRFset,v,'LineColor','r','ShowText','off')
hold on
contour(y0set,dtheta0set,GRFset,v,'LineColor','k','ShowText','on')
xlabel('$$y$$ [m]','Interpreter','latex')
ylabel('$$\dot{\theta}$$ [rad/s]','Interpreter','latex')

% xlim([min(y0set),max(y0set)])
% ylim([-max(abs(dtheta0set)),max(abs(dtheta0set))])
xlim([0.6,0.75])
ylim([-2.25,2.25])
caxis([1000 2500])
colorbar
colormap jet

if saveflag == true
    figname_png = ['fig/GRF_contour_E0=',num2str(E0),'.png'];
    figname_fig = ['fig/GRF_contour_E0=',num2str(E0),'.fig'];
    figname_pdf = ['fig/GRF_contour_E0=',num2str(E0),'.pdf'];
    saveas(gcf, figname_png)
    saveas(gcf, figname_fig)
    saveas(gcf, figname_pdf)
    disp('save finish!')
end
h = msgbox('Caluculation finished !');
