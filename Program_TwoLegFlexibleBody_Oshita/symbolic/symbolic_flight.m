% fileName: symbolic.m
% initDate: 20190719
% Object:   Flight phaseの運動方程式を導く

%% initial settings
clear
close all

%% definition

% parameters
syms m J kt xh yh xf yf dxh dyh dxf dyf
syms L l3 l4
syms g
param = [m J kt L l3 l4 g];% 定数のみ

% state variables
syms x y theta phi
q = [x y theta phi];
syms dx dy dtheta dphi
dq = [dx dy dtheta dphi];

% Energy functions
syms T1 T2 U1 U2 U3 U4
syms Lag

%それ以外のパラメータ
xh = x - L * cos(phi) * cos(theta);
yh = y - L * cos(phi) * sin(theta);
xf = x + L * cos(phi) * cos(theta);
yf = y + L * cos(phi) * sin(theta);
dxh = jacobian(xh, q) * dq.';
dyh = jacobian(yh, q) * dq.';
dxf = jacobian(xf, q) * dq.';
dyf = jacobian(yf, q) * dq.';
% dxh = dx + (dtheta)^2 * L * sin(theta) * cos(phi) + (dphi)^2 * L * sin(phi) * cos(theta);
% dyh = dy - (dtheta)^2 * L * cos(phi) * cos(theta) + (dphi)^2 * L * sin(phi) * sin(theta);
% dxf = dx - (dtheta)^2 * L * cos(phi) * sin(theta) - (dphi)^2 * L * sin(phi) * cos(theta);
% dyf = dy + (dtheta)^2 * L * cos(phi) * cos(theta) - (dphi)^2 * L * sin(theta) * sin(phi);


% Energy
T1 = 0; % 並進の運動エネルギー
T2 = 0; % 回転の運動エネルギー
U1 = 0; % 重力のポテンシャルエネルギー
U2 = 0; % 後足バネのポテンシャルエネルギー
U3 = 0; % 前足バネのポテンシャルエネルギー
U4 = 0; % 体幹バネのポテンシャルエネルギー

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
matlabFunction(M, 'file', 'myMassMatrixflight', 'vars', {q, param});
matlabFunction(f_cg, 'file', 'myF_CoriGrav_Flight', 'vars', {q, dq, param});
matlabFunction(E, 'file', 'myTotalEnergxflight', 'vars', {q, dq, param});
