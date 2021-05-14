% fileName: swarm_FTE.m
% initDate:　2021/2/6
% Object:  Swarm用FTE

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
% addpath(pwd, 'data')
addpath(pwd, 'fig')

model = Twoleg;

dx0 = 13;
y0 = 0.66;
% load('main_fixedPoints_for_y0=0.62_dx0=13,D=0.06,kt=220.mat')
load(['fixedPoints_for_y0=',num2str(y0),'_dx0=',num2str(dx0),'.mat'])


for i = 1: length(fixedPoint)

    q_fix = fixedPoint(i).q_ini;
    u_fix(1) = fixedPoint(i).u_fix(1);
    u_fix(2) = fixedPoint(i).u_fix(2);
    
    [eigenValues, eivenVectors, jacobi] = calc_eigenvalue(model, q_fix, u_fix);
    
    diagonal = diag(eigenValues);
    logdata(i).eigenValue = diagonal;
    logdata(i).eivenVectors = eivenVectors;
    logdata(i).jacobi = jacobi;
    logdata(i).eeout = model.eeout;
    logdata(i).energy = fixedPoint(i).GRF/(2 * model.m * model.g);
    
end


%% -----------------------------------------------------------------------
%  エネルギー計算

figure 
hold on

markerset = ['o', 'd', '^'];

% おしゃれカラー
colors.green   =[76,175,80]./255;
colors.red     =[244,67,54]./255;
colors.blue    =[33,150,243]./255;
colors.orange  =[255,87,34]./255;
colors.yellow  =[253,216,53]./255;
colors.Dred    =[136,14,79]./255; % ダークレッド
colors.Dblue   =[26,35,126]./255; % ダークブルー
colors.Lorange =[255,204,188]./255; % ライトオレンジ
colors.black =[16,16,16]./255;

large = 6;
small = 4;


for i = 1: length(fixedPoint)

    xh = q_fix(1) - model.L .* cos(q_fix(4)) .* cos(q_fix(3));
    yh = q_fix(2) - model.L .* cos(q_fix(4)) .* sin(q_fix(3));
    xf = q_fix(1) + model.L .* cos(q_fix(4)) .* cos(q_fix(3));
    yf = q_fix(2) + model.L .* cos(q_fix(4)) .* sin(q_fix(3));

    dxh = q_fix(5) + q_fix(7) .* model.L .* sin(q_fix(3)) .* cos(q_fix(4)) + q_fix(8) .* model.L .* cos(q_fix(3)) .* sin(q_fix(4));
    dyh = q_fix(6) - q_fix(7) .* model.L .* cos(q_fix(3)) .* cos(q_fix(4)) + q_fix(8) .* model.L .* sin(q_fix(3)) .* sin(q_fix(4));
    dxf = q_fix(5) - q_fix(7) .* model.L .* sin(q_fix(3)) .* cos(q_fix(4)) - q_fix(8) .* model.L .* cos(q_fix(3)) .* sin(q_fix(4));
    dyf = q_fix(6) + q_fix(7) .* model.L .* cos(q_fix(3)) .* cos(q_fix(4)) - q_fix(8) .* model.L .* sin(q_fix(3)) .* sin(q_fix(4));


    T1 = 0.5 * model.m * (dxh.^2 + dyh.^2) + 0.5 * model.m * (dxf.^2 + dyf.^2);
    T2 = model.J * (q_fix(7)^2 + q_fix(8)^2);
    T = T1 + T2;

    V1 = 2 * model.m * model.g * q_fix(2);
    % V2 = 0.5 * model.kh * (model.l3 - model.lout(:, 1)).^2;
    % V3 = 0.5 * model.kf * (model.l4 - model.lout(:, 2)).^2;
    V4 = 0.5 * model.kt * (2 * q_fix(4)).^2;
    % V = V1 + V2 + V3 + V4;
    V = V1 + V4;

    E_total = T + V;


    x_end = fixedPoint(i).trajectory.qout(end, 1);   
    t_end = fixedPoint(i).trajectory.tout(end);

    X_ave = x_end / t_end;                                      %平均速度

    fte = 2 * model.m * X_ave^2/(2 * E_total);                  %前進効率
    i_middle = round(length(fixedPoint(i).trajectory.tout)/2);

    if logdata(i).eeout(3) == 1
        % Double leg stanceがない

        if fixedPoint(i).u_fix(3) > 0 && fixedPoint(i).trajectory.qout(i_middle, 4) > 0
        % EE
        gaitMarker = markerset(2);
        markerColor = colors.yellow;
        markerSize = small;

        elseif fixedPoint(i).u_fix(3) < 0 && fixedPoint(i).trajectory.qout(i_middle, 4) < 0
            % GG
            gaitMarker = markerset(2);
            markerColor = colors.green;
            markerSize = small;

        elseif (fixedPoint(i).u_fix(3)) > 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) < 0
            % EG

            %後脚から接地
            if fixedPoint(i).q_constants(3) > 0
                % 後肢から接地
                gaitMarker = markerset(2);
                markerColor = colors.Dred;
                markerSize = small;

            elseif fixedPoint(i).q_constants(3) < 0
                % 前肢から接地（EfGh，チーターと一致）
                gaitMarker = markerset(1);
                markerColor = colors.red;
                markerSize = large;

            end

        elseif (fixedPoint(i).u_fix(3)) < 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) > 0
            % GE

            if fixedPoint(i).q_constants(3) > 0
                % 後肢から接地(GhEf，チーターと一致)
                gaitMarker = markerset(1);
                markerColor = colors.blue;
                markerSize = large;
            elseif fixedPoint(i).q_constants(3) < 0
                % 前肢から接地
                gaitMarker = markerset(2);
                markerColor = colors.Dblue;
                markerSize = small;

            end

        end

    elseif logdata(i).eeout(3) == 3
        % double leg stanceがある

        if fixedPoint(i).u_fix(3) > 0
            % E
            gaitMarker = markerset(3);
            markerColor = colors.yellow;
            markerSize = small;
        elseif fixedPoint(i).u_fix(3) < 0
            % G
            gaitMarker = markerset(2);
            markerColor = colors.green;
            markerSize = small;

        end

    end % if gaitClassfy

    plot(rad2deg(fixedPoint(i).q_constants(3)), fte, 'marker',gaitMarker, 'markerfacecolor',markerColor, 'markeredgecolor', 'none','markersize',markerSize)    
    hold on


end



xlabel('$$\dot{\theta_0}$$[deg/s]','Interpreter','latex')
ylabel('FTE')


if saveflag == true
        
    figname = ['fig/FTE_y0=',num2str(y0),'_dx0=',num2str(dx0),'.png'];
    saveas(gcf, figname)
    figname = ['fig/FTE_y0=',num2str(y0),'_dx0=',num2str(dx0),'.fig'];
    saveas(gcf, figname)
    disp('save finish!')
end



