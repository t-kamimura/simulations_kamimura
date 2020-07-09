% fileName: symbolic.m
% initDate: 20190719
% Object:   Flight phaseの運動方程式を導く

%% initial settings
clear
close all

%% definition

% parameters
syms  m J kt x_h y_h x_f y_f 
syms l l0
syms g
param = [ m J kt x_h y_h x_f y_f l l0 g]

% state variables
syms x y theta phi
q = [x y theta phi];
syms dx dy dtheta dphi
dq = [dx dy dtheta dphi];

% Energy functions
syms T1 T2 U1 U2 U3 U4
syms L

%それ以外のパラメータ
x_h = x - l * cos(phi) * cos(theta);
y_h = y - l * cos(phi) * sin(theta);
x_f = x + l * cos(phi) * cos(theta);
y_f = y + l * cos(phi) * sin(theta);
dx_h = jacobian(x_h,q) * dq.';
dy_h = jacobian(y_h,q) * dq.';
dx_f = jacobian(x_f,q) * dq.';
dy_f = jacobian(x_f,q) * dq.';

% Energy
T1 = 0.5 * m * (dx_h^2 + dy_h^2) + 0.5 * m * (dx_f^2 +dy_f^2 ); % 並進の運動エネルギー
T2 = J * (dtheta^2 + dphi^2); % TODO: 回転の運動エネルギー
U1 = 2 * m * g * y; % 重力のポテンシャルエネルギー
U2 = 0; % 後足バネのポテンシャルエネルギー
U3 = 0; % 前足バネのポテンシャルエネルギー
U4 = 0.5 * kt * (2*phi)^2;  % 体幹バネのポテンシャルエネルギー

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
matlabFunction(M, 'file', 'myMassMatrix_Flight', 'vars', {q, param});
matlabFunction(f_cg, 'file', 'myF_CoriGrav_Flight', 'vars', {q, dq, param});
matlabFunction(E, 'file', 'myTotalEnergy_Flight', 'vars', {q, dq, param});
