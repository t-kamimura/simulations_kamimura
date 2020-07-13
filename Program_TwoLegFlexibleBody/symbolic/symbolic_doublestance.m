% fileName: symbolic.m
% initDate: 20190719
% Object:   double stance phaseの運動方程式を導く

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
param = [m J kh kf kt xf_toe xh_toe gamma_h_td gamma_f_td L l3 l4 D g]

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
dxh = jacobian(xh, dq) * dq.';
dyh = jacobian(yh, dq) * dq.';
dxf = jacobian(xf, dq) * dq.';
dyf = jacobian(yf, dq) * dq.';
% dxh = dx + dtheta^2 * L * sin(theta) * cos(phi) + dphi^2 * L * sin(phi) * cos(theta); 
% dyh = dy - dtheta^2 * L * cos(phi) * cos(theta) + dphi^2 * L * sin(phi) * sin(theta);
% dxf = dx - dtheta^2 * L * cos(phi) * sin(theta) - dphi^2 * L * sin(phi) * cos(theta);
% dyf = dy + dtheta^2 * L * cos(phi) * cos(theta) - dphi^2 * L * sin(theta) * sin(phi);

Xh = xh - D * cos(theta - phi);    % hip position
Yh = yh - D * sin(theta - phi);    % hip position
delta_xh = xh_toe - Xh;
lb = sqrt(Yh^2 + delta_xh^2);
xh_toe = Xh + lb * sin(gamma_h_td);

Xf = xf + D * cos(theta + phi);
Yf = yf + D * sin(theta + phi);
delta_xf = xf_toe - Xf;
%gamma_f_td = arctan(delta_xf/Yf);
lf = sqrt(Yf^2 + delta_xf^2);
xf_toe = Xf + lf * sin(gamma_f_td);

% Energy
T1 = 0.5 * m * (dxh^2 + dyh^2) + 0.5 * m * (dxf^2 +dyf^2); % 並進の運動エネルギー
T2 = J * (dtheta^2 + dphi^2); % 回転の運動エネルギー
U1 = 2 * m * g * y; % 重力のポテンシャルエネルギー
U2 = 0.5 * kh * (l3 - lb)^2; % 後足バネのポテンシャルエネルギー
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
matlabFunction(M, 'file', 'myMassMatrix_Doublestance', 'vars', {q, param});
matlabFunction(f_cg, 'file', 'myF_CoriGrav_Doublestance', 'vars', {q, dq, param});
matlabFunction(E, 'file', 'myTotalEnergy_Doublestance', 'vars', {q, dq, param});
