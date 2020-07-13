% fileName: main_test.m
% initDate:　2020/7/13
% Object:   Twolegflexible

clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaultAxesFontSize', 12);
set(0, 'defaultAxesFontName', 'times');
set(0, 'defaultTextFontSize', 16);
set(0, 'defaultTextFontName', 'times');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

saveflag = false;

% path追加
addpath(pwd, 'class')
addpath(pwd, 'symbolic')
addpath(pwd, 'eom')
addpath(pwd, 'event')
addpath(pwd, 'func')
addpath(pwd, 'data')
addpath(pwd, 'fig')

model = Twoleg;

x_ini = 0;
y_ini = 0.324;
theta_ini = 0;
phi_ini = deg2rad(15);
dx_ini = 1.39;
dy_ini = 0;
dtheta_ini = deg2rad(100);
dphi_ini = deg2rad(100);
% gb_ini = 0*pi / 8;
% gf_ini = 0*pi / 8;
gamma_h_td_ini = deg2rad(16);
gamma_f_td_ini = deg2rad(14);

q_ini = [x_ini y_ini theta_ini phi_ini dx_ini dy_ini dtheta_ini dphi_ini];
u_ini = [gamma_h_td_ini gamma_f_td_ini];

model.init
model.bound(q_ini, u_ini)

model.plot(saveflag)
model.anime(0.1, false);
