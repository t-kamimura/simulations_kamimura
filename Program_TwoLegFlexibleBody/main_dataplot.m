% fileName: main_dataplot.m
% initDate:　2020/7/30
% Object:  matfileプロットしなおす

clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaultAxesFontSize', 12);
set(0, 'defaultAxesFontName', 'times');
set(0, 'defaultTextFontSize', 16);
set(0, 'defaultTextFontName', 'times');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% path追加
addpath(pwd, 'class')
addpath(pwd, 'symbolic')
addpath(pwd, 'eom')
addpath(pwd, 'event')
addpath(pwd, 'func')
addpath(pwd, 'data')
addpath(pwd, 'fig')

model = Twoleg;


load('fixedPoints_for_y0=0.68_dx0=11.111.mat')


%% -------------------------------------------------------------------------------------------------------
% phiとpitchrate

figure
hold on

for i = 1:length(fixedPoint)
    plot(rad2deg(fixedPoint(i).q_constants(3)), rem(rad2deg(fixedPoint(i).u_fix(1)),360), 'd', 'markerfacecolor', 'b', 'markeredgecolor', 'none');
    plot(rad2deg(fixedPoint(i).q_constants(3)), rem(rad2deg(fixedPoint(i).u_fix(2)),360), 'o', 'markerfacecolor', 'none', 'markeredgecolor', 'r');
end

xlabel("pitch rate [deg/s]")
ylabel("touchdown angle [deg]")

%% ---------------------------------------------------------------------------------------------------------

% phiとpitchrate

figure
hold on

for i = 1:length(fixedPoint)
    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's', 'markerfacecolor', 'r', 'markeredgecolor', 'r');
end

xlabel("pitch rate [deg/s]")
ylabel("phi [deg]")



model.init
% model.bound(q_ini, u_ini)

% model.plot(saveflag)
% model.anime(0.05, saveflag);
