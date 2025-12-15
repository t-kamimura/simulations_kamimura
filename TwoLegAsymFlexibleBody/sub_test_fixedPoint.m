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

model = Twoleg(0.2);

load("fixedPoints_for_kt=144.mat")

i = 1;
u_fix = fixedPoint(i).u_fix;

x0 = 0.0;
y0 = u_fix(1);
theta0 = 0;
phi0 = u_fix(2);
dx0 = u_fix(3);
dy0 = 0;
dtheta0 = u_fix(4);
dphi0 = 0 ;

gb_ini = u_fix(5);
gf_ini = u_fix(6);

q_ini = [x0 y0 theta0 phi0 dx0 dy0 dtheta0 dphi0];
u_ini = [gb_ini gf_ini];

model.init
model.bound(q_ini, u_ini)

model.plot(saveflag)
model.anime(0.1, false);
