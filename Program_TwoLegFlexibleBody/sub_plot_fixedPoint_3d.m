% fileName: sub_plot_fixedPoint_3d.m
% initDate: 2021/05/21
% Object:   エネルギー一定で求めた周期解を3次元的にプロット

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

%% データの抽出
model = Twoleg;

E0 = 3500; % [J]

% y0set = 0.65:0.0025:0.68;
% dtheta0set = [-150:15:150]; % [deg/s]


y0set = 0.65:0.001:0.669;
dtheta0set = [-119:1:-104]; % [deg/s]

dtheta0set = deg2rad(dtheta0set);

for i_y = 1:length(y0set)
%     load(['data/identical_energy/wideYrange/fixedPoints_for_E0=', num2str(E0),'_y0=',num2str(y0set(i_y)), '.mat'])
    load(['data/identical_energy/smalldthetaRange/fixedPoints_for_E0=', num2str(E0),'_y0=',num2str(y0set(i_y)), '.mat'])
    if i_y == 1
        fixedPoint_integrated = fixedPoint;
    else
        fixedPoint_integrated = [fixedPoint_integrated,fixedPoint];
    end
    clearvars fixedPoint
end

%% 解の確認
n = 0;
for i = 1:length(fixedPoint_integrated)
    if abs(fixedPoint_integrated(i).E - 3500)<1e-3
        n = n + 1;
        y0 = fixedPoint_integrated(i).u_fix(1);
        dtheta0 = fixedPoint_integrated(i).u_fix(2);
        phi0 = fixedPoint_integrated(i).z_fix(1);
        q_ini = fixedPoint_integrated(i).q_ini;
        u_ini = [fixedPoint_integrated(i).z_fix(2), fixedPoint_integrated(i).z_fix(3)];
        model.init;
        model.bound(q_ini, u_ini);
        fixedPoints(n).fixedPoint = [y0, dtheta0, phi0];
        fixedPoints(n).u = u_ini;
        fixedPoints(n).tout = model.tout;
        fixedPoints(n).qout = model.qout;
        fixedPoints(n).eeout = model.eeout;
        fixedPoints(n).GRF = fixedPoint_integrated(i).GRF;
        fixedPoints(n).vel = model.qout(end,1)/model.tout(end);
        if fixedPoints(n).eeout(3) == 3
            % with DS
            if fixedPoints(n).fixedPoint(3) > 0
                fixedPoints(n).soltype(1) = 1;    % E
            else
                fixedPoints(n).soltype(1) = 2;    % G
            end
        elseif fixedPoints(n).eeout(3) == 1
            % with DS
            midtime = round(length(fixedPoints(n).tout)*0.5);
            if fixedPoints(n).fixedPoint(3) > 0
                % E始まり
                if fixedPoints(n).qout(midtime,4) > 0
                    fixedPoints(n).soltype(1) = 3; % EE
                else
                    fixedPoints(n).soltype(1) = 5; % EG
                end
            else
                % G始まり
                if fixedPoints(n).qout(midtime,4) > 0
                    fixedPoints(n).soltype(1) = 6; % GE
                else
                    fixedPoints(n).soltype(1) = 4; % GG
                end
            end
        else
            fixedPoints(n).soltype = 7;
        end
        if fixedPoints(n).eeout(2) == 2
            % Hind leg first
            fixedPoints(n).soltype(2) = 1;
        else
            % Fore leg first
            fixedPoints(n).soltype(2) = 2;
        end
    end % if solutionExit
end
filename = ['data/fixedPoints_rearranged_E0=', num2str(E0),'.mat'];
save(filename, 'fixedPoints');
% filename = ['data/identical_energy/fixedPoints_rearranged_E0=', num2str(E0),'.mat'];
% load(filename)
%% 3次元空間にプロット

% soltype
% 1: E
% 2: G
% 3: EE
% 4: GG
% 5: EG
% 6: GE
% おしゃれカラー
green   =[76,175,80]    ./255;

red     =[244,67,54]    ./255;
blue    =[33,150,243]   ./255;
Dred    =[136,14,79]    ./255; % ダークレッド
Dblue   =[26,35,126]    ./255; % ダークブルー
Lblue   =[64,196,255]   ./255;
Lred    =[255,171,0]    ./255;
grey    =[158,158,158]  ./255;

clr = [Dred;Dblue;red;blue;Lred;Lblue;grey];
markerset = ['o','d'];

n = length(fixedPoints);

h1 = figure;
for i = 1:n
%     plot3(fixedPoints(i).fixedPoint(1),fixedPoints(i).fixedPoint(2),fixedPoints(i).fixedPoint(3),'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
%     hold on
    if max(abs(fixedPoints(i).soltype - [5,2])) == 0 || max(abs(fixedPoints(i).soltype - [6,1])) == 0
        plot3(fixedPoints(i).fixedPoint(1),fixedPoints(i).fixedPoint(2),fixedPoints(i).fixedPoint(3),'marker','o','MarkerFaceColor',red,'MarkerEdgeColor','none')
        hold on
    else
        plot3(fixedPoints(i).fixedPoint(1),fixedPoints(i).fixedPoint(2),fixedPoints(i).fixedPoint(3),'marker','o','MarkerFaceColor',blue,'MarkerEdgeColor','none')
        hold on
    end
end
xlabel('$$y^*$$ [m]','interpreter','latex')
ylabel('$$\dot{\theta}^*$$ [rad/s]','interpreter','latex')
zlabel('$$\phi^*$$ [rad]','interpreter','latex')
xlim([y0set(1) y0set(end)])
ylim([dtheta0set(1) dtheta0set(end)])
zlim([-1 0.7])
grid on

if saveflag == true
    figname_png = ['fig/fixedPoints_E0=',num2str(E0),'.png'];
    figname_fig = ['fig/fixedPoints_E0=',num2str(E0),'.fig'];
    saveas(gcf, figname_png)
    saveas(gcf, figname_fig)
    disp('save finish!')
end

set(h1, 'DoubleBuffer', 'off');
angle = 45;
F = [];

for i = 1:720
    view(angle,15)
    angle = angle + 0.5;
    F = [F; getframe(h1)];
end

if saveflag == true
    videoobj = VideoWriter([date, 'solutions.mp4'], 'MPEG-4');
%     videoobj.FrameRate = FPS;
    fprintf('video saving...')
    open(videoobj);
    writeVideo(videoobj, F);
    close(videoobj);
    fprintf('complete!\n');
end % save
%% y-phi平面にプロット
for i_dtheta = 1:length(dtheta0set)
    h = figure;
    dtheta = dtheta0set(i_dtheta);
    for i=1:n
        if abs(dtheta - fixedPoints(i).fixedPoint(2)) < 1e-3
%             plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).fixedPoint(3),'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
%             hold on
            if max(abs(fixedPoints(i).soltype - [5,2])) == 0 || max(abs(fixedPoints(i).soltype - [6,1])) == 0
                plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).fixedPoint(3),'marker','o','MarkerFaceColor',red,'MarkerEdgeColor','none')
                hold on
            else
                plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).fixedPoint(3),'marker','o','MarkerFaceColor',blue,'MarkerEdgeColor','none')
                hold on
            end
        end
        
    end
    figtitle = ['$$\dot{\theta}=$$',num2str(dtheta)];
    title(figtitle,'interpreter','latex')
    xlabel('$$y^*$$ [m]','interpreter','latex')
    ylabel('$$\phi^*$$ [rad]','interpreter','latex')
    xlim([y0set(1) y0set(end)])
    ylim([-1 1.2])

    if saveflag == true
        figname_png = ['fig/fixedPoints_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.png'];
        figname_fig = ['fig/fixedPoints_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.fig'];
        saveas(h, figname_png)
        saveas(h, figname_fig)
        disp('save finish!')
        close(h)
    end
end

%% dtheta-phi平面にプロット
for i_y = 1:length(y0set)
    h = figure;
    y = y0set(i_y);
    for i=1:n
        if abs(y - fixedPoints(i).fixedPoint(1)) < 1e-3
%             plot(fixedPoints(i).fixedPoint(2),fixedPoints(i).fixedPoint(3),'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
%             hold on
            if max(abs(fixedPoints(i).soltype - [5,2])) == 0 || max(abs(fixedPoints(i).soltype - [6,1])) == 0
                plot(fixedPoints(i).fixedPoint(2),fixedPoints(i).fixedPoint(3),'marker','o','MarkerFaceColor',red,'MarkerEdgeColor','none')
                hold on
            else
                plot(fixedPoints(i).fixedPoint(2),fixedPoints(i).fixedPoint(3),'marker','o','MarkerFaceColor',blue,'MarkerEdgeColor','none')
                hold on
            end
        end
        
    end
    figtitle = ['$$y=$$',num2str(y)];
    title(figtitle,'interpreter','latex')
    xlabel('$$\dot{\theta}^*$$ [rad/s]','interpreter','latex')
    ylabel('$$\phi^*$$ [rad]','interpreter','latex')
    xlim([dtheta0set(1) dtheta0set(end)])
    ylim([-1 1.2])

    if saveflag == true
        figname_png = ['fig/fixedPoints_E0=',num2str(E0),'_y0=',num2str(y),'.png'];
        figname_fig = ['fig/fixedPoints_E0=',num2str(E0),'_y0=',num2str(y),'.fig'];
        saveas(h, figname_png)
        saveas(h, figname_fig)
        disp('save finish!')
        close(h)
    end
end