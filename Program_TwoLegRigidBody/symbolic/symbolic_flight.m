% fileName: symbolic_flight.m
% initDate: 20200616
% Object:   2脚ロボットの運動方程式を導く(flight)

%% initial settings
clear
close all

%% 定義

% parameters
syms m J
syms lb lf lb0 lf0
syms g
param = [m J lb lf lb0 lf0];

% state variables
syms x y theta
q = [x y theta];
syms dx dy dtheta
dq = [dx dy dtheta];

syms xb_toe xf_toe

% Energy functions
syms T1 T2 U
syms L

% Energy
T1 = 0.5 * m * (dx^2 + dy^2);
T2 = 0.5 * J * dtheta^2;
U1 = m1 * g * y;
L = simplify(T1 + T2 - U);
E = simplify(T1 + T2 + U);

% Differentials
dLddq = jacobian(L, dq);
d_dLddq_dt = jacobian(dLddq, q) * dq.';
dLdq = jacobian(L, q);

M = jacobian(dLddq, dq); % Inertia matrix
M = simplify(M);

f_cg = dLdq.' - d_dLddq_dt; % Corioris & gravitational force
f_cg = simplify(f_cg);

% save as functions
matlabFunction(M, 'file', 'myMassMatrix_F', 'vars', {q, param});
matlabFunction(f_cg, 'file', 'myF_CoriGrav_F', 'vars', {q, dq, param});
matlabFunction(E, 'file', 'myTotalEnergy_F', 'vars', {q, dq, param});
