% fileName: sub_gamma_lo_dataplot.m
% initDate:　2020/10/5
% Object:  gamma_lo_f = minus gamma_td_hの式でプロット
% Object:  2020/11/27 loとtd両方プロットする

clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaultAxesFontSize', 12);
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

model = Twoleg;


load('main_fixedPoints_for_y0=0.62_dx0=13,D=0.06,kt=220.mat')

%% -------------------------------------------------------------------------------------------------------
% gammaとpitchrate
%固定点によってmodかrem最適な方法で計算(8/18修正)

figure
hold on

for i = 1:length(fixedPoint)    

    gamma_hind = rem(rad2deg(fixedPoint(i).u_fix(1)),360);
    gamma_fore = rem(rad2deg(fixedPoint(i).u_fix(2)),360);


    if abs(gamma_hind) > 180
    gamma_hind = mod(rad2deg(fixedPoint(i).u_fix(1)),360);
    end

    if abs(gamma_fore) > 180
    gamma_fore = mod(rad2deg(fixedPoint(i).u_fix(2)),360);
    end


    %Poulakakisの式でgamma_loに変換
    gamma_lo_hind = - gamma_fore;
    gamma_lo_fore = - gamma_hind;


    plot(rad2deg(fixedPoint(i).q_constants(3)), gamma_lo_hind, 'o', 'markerfacecolor', 'b', 'markeredgecolor', 'none');
    plot(rad2deg(fixedPoint(i).q_constants(3)), gamma_lo_fore, 'o', 'markerfacecolor', 'r', 'markeredgecolor', 'r');
    plot(rad2deg(fixedPoint(i).q_constants(3)), gamma_hind, 'd', 'markerfacecolor', 'b', 'markeredgecolor', 'b'); 
    plot(rad2deg(fixedPoint(i).q_constants(3)), gamma_fore, 'd', 'markerfacecolor', 'r', 'markeredgecolor', 'r');

end

xlabel('$$\dot{\theta_0}$$[deg/s]','Interpreter','latex')
ylabel('\gamma [deg]')
%title('dx=13,y=0.62,D=0.06,kt=220')


if saveflag == true

    figname1 = ['data_lo_gamma'];
    saveas(gcf, figname1, 'png')
    saveas(gcf, figname1, 'pdf')
    disp('save finish!')
end



%% ---------------------------------------------------------------------------------------------------------
% phiとpitchrate

% figure
% hold on

% for i = 1:length(fixedPoint)
%     plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's', 'markerfacecolor', 'r', 'markeredgecolor', 'r');
% end

% xlabel('$$\dot{\theta_0}$$[deg/s]','Interpreter','latex')
% ylabel('\phi_0 [deg]')
% title('dx=17,y=0.645')


% if saveflag == true

%     figname2 = ['data_phi']
%     saveas(gcf, figname2, 'png')
%     disp('save finish!')
% end

% model.init
% model.bound(q_ini, u_ini)

% model.plot(saveflag)
% model.anime(0.05, saveflag);
