% fileName: symbolic.m
% initDate: 20190719
% Object:   double stance phaseの運動方程式を導く

%% initial settings
clear
close all

%% definition

% parameters
syms m J kt x_h y_h x_f y_f
syms kh kf kt
syms xf_toe xh_toe gamma_h_td gamma_f_td% x*_toe :足先位置
syms l l0 D
syms g
param = [m J kt x_h y_h x_f y_f kh kf kt xf_toe xh_toe gamma_h_td gamma_f_td l l0 D g]

% state variables
syms x y theta phi
q = [x y theta phi];
syms dx dy dtheta dphi
dq = [dx dy dtheta dphi];

% Energy functions
syms T1 T2 U1 U2 U3 U4
syms L

%それ以外のパラメータ定義
x_h = x - l * cos(phi) * cos(theta);
y_h = y - l * cos(phi) * sin(theta);
x_f = x + l * cos(phi) * cos(theta);
y_f = y + l * cos(phi) * sin(theta);
dx_h = jacobian(x_h,q) * dq.';
dy_h = jacobian(y_h,q) * dq.';
dx_f = jacobian(x_f,q) * dq.';
dy_f = jacobian(x_f,q) * dq.';

Xh = x_h - D * cos(theta - phi);    % hip position
Yh = y_h - D * sin(theta - phi);    % hip position
delta_xh = xh_toe - Xh;
lb = sqrt(Yh^2 + delta_xh^2);
xh_toe = Xh + lb * sin(gamma_h_td);

Xf = x_f + D * cos(theta + phi);
Yf = y_f + D * sin(theta + phi);
delta_xf = xf_toe - Xf;
%gamma_f_td = arctan(delta_xf/Yf);
lf = sqrt(Yf^2 + delta_xf^2);
xf_toe = Xf + lf * sin(gamma_f_td);

% Energy
T1 = 0.5 * m * (dx_h^2 + dy_h^2) + 0.5 * m * (dx_f^2 +dy_f^2); % 並進の運動エネルギー
T2 = J * (dtheta^2 + dphi^2); % 回転の運動エネルギー
U1 = 2 * m * g * y; % 重力のポテンシャルエネルギー
U2 = 0.5 * kh * (l0 - lb)^2; % 後足バネのポテンシャルエネルギー
U3 = 0.5 * kf * (l0 - lf)^2; % 前足バネのポテンシャルエネルギー
U4 = 0.5 * kt * (2 * phi)^2; % 体幹バネのポテンシャルエネルギー

L = simplify(T1 + T2 - U1 - U2 - U3 - U4);
E = simplify(T1 + T2 + U1 + U2 + U3 + U4);

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
