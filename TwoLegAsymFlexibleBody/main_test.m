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
addpath(genpath('class'))
addpath(pwd, 'func')
addpath(pwd, 'data')
addpath(pwd, 'fig')

model = Twoleg(0.5);

% x_ini = 0.0;
% y_ini = 1.0;
% theta_ini = 0;
% phi_ini = deg2rad(0);
% dx_ini = 2.5;
% dy_ini = 0;
% dtheta_ini = deg2rad(0);
% dphi_ini = 0;
% % gb_ini = 0*pi / 8;
% % gf_ini = 0*pi / 8;
% gamma_h_td_ini = deg2rad(18);
% gamma_f_td_ini = deg2rad(14);

% q_ini = [x_ini y_ini theta_ini phi_ini dx_ini dy_ini dtheta_ini dphi_ini];
% u_ini = [gamma_h_td_ini gamma_f_td_ini];

q_ini = [0,0.771805444763325,0,-0.004022061596525,11.826707147929236,0,1.977738571535911,0]; % [x y theta phi dx dy dtheta dphi]
u_ini = [0.817453417228301,0.796122251883640];               % [gamma_b gamma_f]

model.init(0);
model.bound(q_ini, u_ini);

model.plot(saveflag)
model.anime(0.1, false);
