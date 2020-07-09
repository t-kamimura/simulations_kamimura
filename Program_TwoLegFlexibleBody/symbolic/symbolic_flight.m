% fileName: symbolic.m
% initDate: 20190719
% Object:   Flight phaseの運動方程式を導く

%% initial settings
clear
close all

%% definition

% parameters
syms m J kt xh yh xf xf
syms l l0
syms g
% param = [ m J kt xh yh xf xf l l0 g]
param = [m J kt l l0 g]% 定数のみ

% state variables
syms x y theta phi
q = [x y theta phi];
syms dx dy dtheta dphi
dq = [dx dy dtheta dphi];

% Energy functions
syms T1 T2 U1 U2 U3 U4
syms L

%それ以外のパラメータ
xh = x - l * cos(phi) * cos(theta);
yh = y - l * cos(phi) * sin(theta);
xf = x + l * cos(phi) * cos(theta);
xf = y + l * cos(phi) * sin(theta);
dxh = jacobian(xh, q) * dq.';
dyh = jacobian(yh, q) * dq.';
dxf = jacobian(xf, q) * dq.';
dxf = jacobian(xf, q) * dq.';

% Energy
T1 = 0.5 * m * (dxh^2 + dyh^2) + 0.5 * m * (dxf^2 + dxf^2); % 並進の運動エネルギー
T2 = J * (dtheta^2 + dphi^2); % TODO: 回転の運動エネルギー
U1 = 2 * m * g * y; % 重力のポテンシャルエネルギー
U2 = 0; % 後足バネのポテンシャルエネルギー
U3 = 0; % 前足バネのポテンシャルエネルギー
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
matlabFunction(M, 'file', 'myMassMatrixflight', 'vars', {q, param});
matlabFunction(f_cg, 'file', 'myF_CoriGrav_Flight', 'vars', {q, dq, param});
matlabFunction(E, 'file', 'myTotalEnergxflight', 'vars', {q, dq, param});
