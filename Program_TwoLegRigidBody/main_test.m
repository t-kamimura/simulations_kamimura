% fileName: main_test.m
% initDate: むかし
% Object:   Poulakakis (2006)の再現プログラムの実行テスト

clear
close all
add_subfolders();
default_settings(16,'times');
saveFlag = set_saveFlag('No');

model = TwoLeg;

x_ini = 0;
y_ini = 0.324;
theta_ini = 0;
dx_ini = 1.39;
dy_ini = 0;
dtheta_ini = deg2rad(145.9);
gamma_h_td_ini = deg2rad(16);
gamma_f_td_ini = deg2rad(14);

q_ini = [x_ini y_ini theta_ini dx_ini dy_ini dtheta_ini];
u_ini = [gamma_h_td_ini gamma_f_td_ini];

model.bound(q_ini, u_ini)

model.plot(saveFlag)
model.anime(0.1, false);
