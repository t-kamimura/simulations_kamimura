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
kappa = 0.2;
model = Twoleg(kappa);

q_ini = [0,0.694280807845082,0,-0.152859394693977,12.430002401450801,0,2.396278701777110,0]; % [x y theta phi dx dy dtheta dphi]
u_ini = [0.810162808644968,0.804419959308218];               % [gamma_b gamma_f]

%% 何歩も歩かせてみる
numTrials = 10;
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
model.anime(0.1, false);
% h = msgbox('Caluculation finished !');
