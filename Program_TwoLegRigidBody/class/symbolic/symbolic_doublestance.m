% fileName: symbolic.m
% initDate: 20190719
% Object:   double stance phaseの運動方程式を導く

%% initial settings
clear
close all

%% definition

% parameters
syms m J kh kf xf_toe xh_toe gamma_h_td gamma_f_td% x*_toe :足先位置
syms L l3 l4
syms g
param = [m J kh kf xf_toe xh_toe gamma_h_td gamma_f_td L l3 l4 g]

% state variables
syms x y theta
q = [x y theta];
syms dx dy dtheta
dq = [dx dy dtheta];

% Energy functions
syms T1 T2 U1 U2 U3
syms L

%それ以外のパラメータ定義
Xh = x - L * cos(theta);    % hip position
Yh = y - L * sin(theta);    % hip position
delta_xh = xh_toe - Xh;
lb = sqrt(Yh^2 + delta_xh^2);

Xf = x + L * cos(theta);
Yf = y + L * sin(theta);
delta_xf = xf_toe - Xf;
%gamma_f_td = arctan(delta_xf/Yf);
lf = sqrt(Yf^2 + delta_xf^2);

% Energy
T1 = 0.5 * m * (dx^2 + dy^2); % 並進の運動エネルギー
T2 = 0.5 * J * dtheta^2; % 回転の運動エネルギー
U1 = m * g * y; % 重力のポテンシャルエネルギー
U2 = 0.5 * kh * (l3 - lb)^2; % 後足バネのポテンシャルエネルギー
U3 = 0.5 * kf * (l4 - lf)^2; % 前足バネのポテンシャルエネルギー

L = simplify(T1 + T2 - U1 - U2 - U3);
E = simplify(T1 + T2 + U1 + U2 + U3);

% Differentials
dLddq = jacobian(L, dq);
d_dLddq_dt = jacobian(dLddq, q) * dq.';
dLdq = jacobian(L, q);

M = jacobian(dLddq, dq); % Inertia matrix
M = simplify(M);

f_cg = d_dLddq_dt - dLdq.'; % Corioris & gravitational force
f_cg = simplify(f_cg);

% save as functions
matlabFunction(M, 'file', 'myMassMatrix_Doublestance', 'vars', {q, param});
matlabFunction(f_cg, 'file', 'myF_CoriGrav_Doublestance', 'vars', {q, dq, param});
matlabFunction(E, 'file', 'myTotalEnergy_Doublestance', 'vars', {q, dq, param});
