% fileName: symbolic_torque.m
% initDate: 20210914
% Object:   Stance中の床反力が及ぼすトルクなどを計算

%% initial settings
clear
close all

%% definition

% parameters
syms m J kt xh yh xf yf dxh dyh dxf dyf
syms kh kf kt
syms xf_toe xh_toe gamma_h_td gamma_f_td% x*_toe :足先位置
syms L l3 l4 D
syms g
param = [m J kh kf kt xf_toe xh_toe gamma_h_td gamma_f_td L l3 l4 D g];

% state variables
syms x y theta phi
q = [x y theta phi];
syms dx dy dtheta dphi
dq = [dx dy dtheta dphi];

% Energy functions
syms T1 T2 U1 U2 U3 U4
syms Lag

%それ以外のパラメータ定義
xh = x - L * cos(phi) * cos(theta);
yh = y - L * cos(phi) * sin(theta);
xf = x + L * cos(phi) * cos(theta);
yf = y + L * cos(phi) * sin(theta);
dxh = jacobian(xh, q) * dq.';
dyh = jacobian(yh, q) * dq.';
dxf = jacobian(xf, q) * dq.';
dyf = jacobian(yf, q) * dq.';

Xf = xf + D * cos(theta + phi); % shoulder position
Yf = yf + D * sin(theta + phi); % shoulder position
delta_xf = xf_toe - Xf;
lf = sqrt(Yf^2 + delta_xf^2);

Xh = xh - D * cos(theta - phi);    % hip position
Yh = yh - D * sin(theta - phi);    % hip position
delta_xh = xh_toe - Xh;
lb = sqrt(Yh^2 + delta_xh^2);
% xh_toe = Xh + lb * sin(gamma_h_td);

Xf = xf + D * cos(theta + phi);
Yf = yf + D * sin(theta + phi);
delta_xf = xf_toe - Xf;
lf = sqrt(Yf^2 + delta_xf^2);
Yh = yh - D * sin(theta - phi);    % hip position
delta_xh = xh_toe - Xh;
lh = sqrt(Yh^2 + delta_xh^2);

% Energy
U2 = 0.5 * kh * (l4 - lh)^2;; % 後足バネのポテンシャルエネルギー
U3 = 0.5 * kf * (l4 - lf)^2; % 前足バネのポテンシャルエネルギー
U4 = 0.5 * kt * (2 * phi)^2; % 体幹バネのポテンシャルエネルギー

% Differentials
torque_GRF_hind = jacobian(U2,q);
torque_GRF_fore = jacobian(U3,q);
torque_spring = jacobian(U4,q);

% save as functions
matlabFunction(torque_GRF_hind, 'file', 'torque_GRF_hind', 'vars', {q, dq,param});
matlabFunction(torque_GRF_fore, 'file', 'torque_GRF_fore', 'vars', {q, dq, param});
matlabFunction(torque_spring, 'file', 'torque_spring', 'vars', {q, dq, param});
