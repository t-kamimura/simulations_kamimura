% fileName: main_find_fixedPoint_E_interp.m
% initDate: 2021/9/8
% Object:  すでに見つかっている解を元に探索

clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaultAxesFontSize', 16);
set(0, 'defaultAxesFontName', 'times');
set(0, 'defaultTextFontSize', 16);
set(0, 'defaultTextFontName', 'times');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Construct a questdlg with three options
choice = questdlg('Do you want to save the result(s)?', ...
    'Saving opptions', ...
    'Yes', 'No', 'Yes');
% Handle response
saveflag = false;

switch choice
    case 'Yes'
        saveflag = true;
    case 'No'
        saveflag = false;
end

% path追加
addpath(pwd, 'class')
addpath(pwd, 'symbolic')
addpath(pwd, 'eom')
addpath(pwd, 'event')
addpath(pwd, 'func')
addpath(pwd, 'data')
addpath(pwd, 'fig')

%% 定数の決定
model = Twoleg;

E0 = 4500; % [J]

y0set = 0.75:-0.005:0.60;
dtheta0set = -1.25:0.125:1.25;


%% データの抜き出し
for i_dtheta = 1:length(dtheta0set)
    for i_y = 1:length(y0set)
        solset(i_y,i_dtheta).z_fix=[];
        solset(i_y,i_dtheta).u_fix = [];
        solset(i_y,i_dtheta).q_ini = [];
        solset(i_y,i_dtheta).fsolveResult.fval = [];
        solset(i_y,i_dtheta).fsolveResult.exitflag = [];
        solset(i_y,i_dtheta).fsolveResult.output = [];
        solset(i_y,i_dtheta).fsolveResult.jacobi = [];
        solset(i_y,i_dtheta).trajectory.tout = [];
        solset(i_y,i_dtheta).trajectory.qout = [];
        solset(i_y,i_dtheta).event.teout = [];
        solset(i_y,i_dtheta).event.qeout = [];
        solset(i_y,i_dtheta).event.ieout = [];
        solset(i_y,i_dtheta).event.eeout = [];
        solset(i_y,i_dtheta).error.q_err = [];
        solset(i_y,i_dtheta).error.q_err_max = [];
        solset(i_y,i_dtheta).GRF = [];
        solset(i_y,i_dtheta).p = [];
        solset(i_y,i_dtheta).E = [];
    end
end
for i_dtheta = 1:length(dtheta0set)
    try
        load(['data/identical_energy_dtheta/fixedPoints_for_E0=', num2str(E0),'_dtheta0=',num2str(dtheta0set(i_dtheta)), '.mat'])
        disp('loaded')
        for i_y = 1:length(y0set)
            for i_sol = 1:length(fixedPoint)
                % Branch1のみ抜き出し
                if abs(fixedPoint(i_sol).u_fix(1) - y0set(i_y))<1e-5 && fixedPoint(i_sol).z_fix(1)>0
                    if isempty(solset(i_y,i_dtheta).z_fix)
                        solset(i_y,i_dtheta) = fixedPoint(i_sol);
                    else
                        % 2重になっている場合は上の解だけ抜き出す
                        if solset(i_y,i_dtheta).z_fix(1) < fixedPoint(i_sol).z_fix(1)
                            solset(i_y,i_dtheta) = fixedPoint(i_sol);
                        end
                    end
                end
            end
        end
        clearvars fixedPoint
    catch
        disp('No data...skip')
    end
end

%% 探索
% figure

% まず，y方向に密にする
for i_dtheta = 1:length(dtheta0set)
    dtheta0 = dtheta0set(i_dtheta);
    if isempty(solset(1,i_dtheta).z_fix)
        % 元になる固定点がないのでskip
    else
        for i_y = 1:length(y0set)
            y0 = y0set(i_y);
            u_ini = [y0 dtheta0 E0];    % 今回のループで求める周期解の定数（固定）部分
            if isempty(solset(i_y,i_dtheta).z_fix)
                z_ini = solset(i_y-1,i_dtheta).z_fix; % 今回のループで求める周期解の探索部分
                [z_fix, logDat, exitflag] = func_find_fixedPoint_E(model, z_ini, u_ini);
                solset(i_y,i_dtheta) = logDat;
                fprintf('.')
            end
        end
        fprintf('\n')
    end
end

% 次に，dtheta方向に密にする
for i_y = 1:length(y0set)
    y0 = y0set(i_y);
    for i_dtheta = 1:length(dtheta0set)
        dtheta0 = dtheta0set(i_dtheta);
        u_ini = [y0 dtheta0 E0];    % 今回のループで求める周期解の定数（固定）部分
        if isempty(solset(i_y,i_dtheta).z_fix)
            z_ini = solset(i_y,i_dtheta-1).z_fix; % 今回のループで求める周期解の探索部分
            [z_fix, logDat, exitflag] = func_find_fixedPoint_E(model, z_ini, u_ini);
            solset(i_y,i_dtheta) = logDat;
            fprintf('_')
        end
    end
    fprintf('\n')
end
filename = ['data/fixedPoints_for_E0=', num2str(E0), '_interporated.mat'];
save(filename, 'solset');
clearvars fixedPoint

%% 解の描画

[X,Y] = meshgrid(y0set,dtheta0set);
for i_y = 1:length(y0set)
    for i_dtheta = 1:length(dtheta0set)
        if isempty(solset(i_y,i_dtheta).q_ini)
            phiset(i_dtheta,i_y) = NaN;
        else
            phiset(i_dtheta,i_y) = solset(i_y,i_dtheta).z_fix(1);
        end
    end
end

figure
surf(X,Y,phiset)
xlabel('$$y$$','Interpreter','latex')
ylabel('$$\dot{\theta}$$','Interpreter','latex')
zlabel('$$\phi$$','Interpreter','latex')

h = msgbox('Caluculation finished !');
