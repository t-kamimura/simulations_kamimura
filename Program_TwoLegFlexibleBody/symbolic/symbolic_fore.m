% fileName: symbolic.m
% initDate: 20190719
% Object:   fore stance phaseの運動方程式を導く

%% initial settings
clear
close all

%% definition

% parameters
syms m J kt xh yh xf yf dxh dyh dxf dyf
syms kf kt
syms xf_toe gamma_h_td gamma_f_td% xf_toe :足先位置
syms L l4 D
syms g
param = [m J kf kt xf_toe gamma_f_td L l4 D g]

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
% dxh = dx + dtheta^2 * L * sin(theta) * cos(phi) + dphi^2 * L * sin(phi) * cos(theta); 
% dyh = dy - dtheta^2 * L * cos(phi) * cos(theta) + dphi^2 * L * sin(phi) * sin(theta);
% dxf = dx - dtheta^2 * L * cos(phi) * sin(theta) - dphi^2 * L * sin(phi) * cos(theta);
% dyf = dy + dtheta^2 * L * cos(phi) * cos(theta) - dphi^2 * L * sin(theta) * sin(phi);


Xf = xf + D * cos(theta + phi); % shoulder position
Yf = yf + D * sin(theta + phi); % shoulder position
delta_xf = xf_toe - Xf;
lf = sqrt(Yf^2 + delta_xf^2);
xf_toe = Xf + lf * sin(gamma_f_td);

% Energy
T1 = 0.5 * m * (dxh^2 + dyh^2) + 0.5 * m * (dxf^2 +dyf^2); % 並進の運動エネルギー
T2 = J * (dtheta^2 + dphi^2); % 回転の運動エネルギー
U1 = 2 * m * g * y; % 重力のポテンシャルエネルギー
U2 = 0; % 後足バネのポテンシャルエネルギー
U3 = 0.5 * kf * (l4 - lf)^2; % 前足バネのポテンシャルエネルギー
U4 = 0.5 * kt * (2 * phi)^2; % 体幹バネのポテンシャルエネルギー

Lag = simplify(T1 + T2 - U1 - U2 - U3 - U4);
E = simplify(T1 + T2 + U1 + U2 + U3 + U4);

% Differentials
dLddq = jacobian(Lag, dq);
d_dLddq_dt = jacobian(dLddq, q) * dq.';
dLdq = jacobian(Lag, q);

M = jacobian(dLddq, dq); % Inertia matrix
M = simplify(M);

f_cg = d_dLddq_dt - dLdq.'; % Corioris & gravitational force
f_cg = simplify(f_cg);

% save as functions
matlabFunction(M, 'file', 'myMassMatrix_Fore', 'vars', {q, param});
matlabFunction(f_cg, 'file', 'myF_CoriGrav_Fore', 'vars', {q, dq, param});
matlabFunction(E, 'file', 'myTotalEnergy_Fore', 'vars', {q, dq, param});
