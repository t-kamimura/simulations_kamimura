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

load('fixedPoints_for_y0=0.68_dx0=11.111.mat')

i=16;
q_ini = fixedPoint(i).q_ini;
u_ini = fixedPoint(i).u_fix;
% x_ini = fixedPoint(7).q_ini(1);
% y_ini = fixedPoint(7).q_ini(2);
% theta_ini = fixedPoint(7).q_ini(3);
% phi_ini = fixedPoint(7).q_ini(4);
% dx_ini = fixedPoint(7).q_ini(5);
% dy_ini = fixedPoint(7).q_ini(6);
% dtheta_ini = fixedPoint(7).q_ini(7);
% dphi_ini = fixedPoint(7).q_ini(8);
% % gb_ini = 0*pi / 8;
% % gf_ini = 0*pi / 8;
% gamma_h_td_ini = fixedPoint(7).u_fix(1);
% gamma_f_td_ini = fixedPoint(7).u_fix(2);
% 
% q_ini = [x_ini y_ini theta_ini phi_ini dx_ini dy_ini dtheta_ini dphi_ini];
% u_ini = [gamma_h_td_ini gamma_f_td_ini];

model.init
model.bound(q_ini, u_ini)

model.plot(saveflag)
model.anime(0.05, saveflag);
