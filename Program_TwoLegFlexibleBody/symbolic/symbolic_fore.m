% fileName: symbolic.m
% initDate: 20190719
% Object:   fore stance phaseの運動方程式を導く

%% initial settings
clear
close all

%% definition

% parameters
syms m J
syms kh kf kt
syms xf_toe % xf_toe :足先位置
syms l l0
syms g
param = [m J kh kf xf_toe gamma_h_td gamma_f_td l l0 g]

% state variables
syms x y theta
q = [x y theta];
syms dx dy dtheta
dq = [dx dy dtheta];

% Energy functions
syms T1 T2 U1 U2 U3 U4
syms L

%それ以外のパラメータ定義
Xf = x + l * cos(theta); % shoulder position
Yf = y + l * sin(theta); % shoulder position
delta_xf = xf_toe - Xf;
lf = sqrt(Yf^2 + delta_xf^2);

% Energy
T1 = 0.5 * m * (dx^2 + dy^2); % 並進の運動エネルギー
T2 = 0.5 * J * m * l^2 * dtheta^2; % 回転の運動エネルギー
U1 = m * g * y; % 重力のポテンシャルエネルギー
U2 = 0; % 後足バネのポテンシャルエネルギー
U3 = 0.5 * kf * (l0 - lf)^2; % 前足バネのポテンシャルエネルギー
U4 = 0.5 * kt * phi^2; % 体幹バネのポテンシャルエネルギー

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
matlabFunction(M, 'file', 'myMassMatrix_Fore', 'vars', {q, param});
matlabFunction(f_cg, 'file', 'myF_CoriGrav_Fore', 'vars', {q, dq, param});
matlabFunction(E, 'file', 'myTotalEnergy_Fore', 'vars', {q, dq, param});