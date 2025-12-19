% fileName: main_find_fixedPoint.m
% initDate: 20200722
% Object:  TwoLegFlexibleの固定点探索

clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaultAxesFontSize', 12);
set(0, 'defaultAxesFontName', 'times');
set(0, 'defaultTextFontSize', 16);
set(0, 'defaultTextFontName', 'times');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% path追加
addpath(genpath('class'))
addpath(pwd, 'func')
addpath(pwd, 'data')
addpath(pwd, 'fig')

%% 定数の決定
kappa = 0.8;
eps = 0.8;
model = Twoleg(kappa, eps);

q_ini = [0,0.594420968999931,0,0.163891349550317,12.722029880821570,0,4.483799075286497,0]; % [x y theta phi dx dy dtheta dphi]
u_ini = [0.836133858175499,0.831136120235923];               % [gamma_b gamma_f]

%% 何歩も歩かせてみる
numTrials = 50;
toutset = [];
qoutset = [];
loutset = [];
goutset = [];
ktoutset = [];
Eoutset = [];
tstart = 0;
for i = 1:numTrials
    fprintf('*');
    % fprintf('Trial %d \n', i);
    model.init(tstart)
    try
    model.bound(q_ini, u_ini);
    q_ini = model.qout(end, :);
    u_ini = u_ini; % 今回は固定
    tstart = model.tout(end);
    toutset = [toutset; model.tout];
    qoutset = [qoutset; model.qout];
    loutset = [loutset; model.lout];
    goutset = [goutset; model.gout];
    ktoutset = [ktoutset; model.ktout];
    Eoutset = [Eoutset; model.Eout];
    if model.eveflg ~= 1
        fprintf('.');
        break;
    end
    catch
        fprintf('.');
        break;
    end
end
fprintf('\n')

model.tout = toutset;
model.qout = qoutset;
model.lout = loutset;
model.gout = goutset;
model.ktout = ktoutset;
model.Eout = Eoutset;
model.plot(false);
% model.anime(0.1, false);
% h = msgbox('Caluculation finished !');
