% fileName: main_test_sub.m
% initDate:　2020/7/27
% Object:   Twolegflexible周期解かどうか確認したい

clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaultAxesFontSize', 12);
set(0, 'defaultAxesFontName', 'times');
set(0, 'defaultTextFontSize', 16);
set(0, 'defaultTextFontName', 'times');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Construct a questdlg with three options
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


% saveflag = false;

% path追加
addpath(pwd, 'class')
addpath(pwd, 'symbolic')
addpath(pwd, 'eom')
addpath(pwd, 'event')
addpath(pwd, 'func')
addpath(pwd, 'data')
addpath(pwd, 'fig')

model = Twoleg;

Fr = 0;

if Fr == 0
    load('fixedPoints_for_E0=255_dx0=0.mat')
    i = 4;
elseif Fr == 1
    load('fixedPoints_for_E0=383_dx0=2.6.mat')
    i = 1;
elseif Fr == 2
    load('fixedPoints_for_E0=763.352_dx0=5.2.mat')
    i = 1;
end
q_ini = fixedPoint(i).q_ini;
u_ini = fixedPoint(i).u_fix;

model.init
model.bound(q_ini, u_ini)


% 座標変換
xout_ = model.qout(:, 1)/model.l3;
yout_ = model.qout(:, 2)/model.l3;
thout_ = model.qout(:, 3); %radのまま
phout_ = model.qout(:, 4);
dxout_ = model.qout(:, 5)/sqrt(model.g*model.l3);
dyout_ = model.qout(:, 6)/sqrt(model.g*model.l3);
dthout_ = model.qout(:, 7); %radのまま
dphout_ = model.qout(:, 8);

tend = model.tout(end);
tout_ = 100*model.tout/tend;

%% 状態量のグラフ

figure('outerposition', [50, 200, 800, 400])

subplot(1,2,1)
plot(tout_, yout_);
xlabel('Gait cycle [%]', 'Fontsize', 14);
ylabel('COM vertical position', 'Fontsize', 14);
xlim([0, max(tout_)]);
ylim([0.95, 1.02]);

subplot(1,2,2)
plot(tout_, phout_);
xlabel('Gait cycle [%]', 'Fontsize', 14);
ylabel('Spring joint angle', 'Fontsize', 14);
xlim([0, max(tout_)]);
ylim([-0.05, 0.15]);


if saveflag == 1
    figname = [date, 'variable_Fr=',num2str(Fr)];
    saveas(gcf, figname, 'fig')
    saveas(gcf, figname, 'png')
    saveas(gcf, figname, 'pdf')
end
Fr = model.qout(end,1)/(model.tout(end)*sqrt(model.g*model.l3));
