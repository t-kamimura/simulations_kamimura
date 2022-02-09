% fileName: sub_plot_fixedPoint_3d_kekg.m
% initDate: 2022/02/07
% Object:   ばね定数を変化させて探した解をプロット

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

% Construct a questdlg with three options
choice = questdlg('Do you already have integrated data?', ...
    'Saving opptions', ...
    'Yes', 'No', 'No');
% Handle response
calcflag = false;

switch choice
    case 'Yes'
        calcflag = false;
    case 'No'
        calcflag = true;
end

% path追加
addpath(pwd, 'class')
addpath(pwd, 'symbolic')
addpath(pwd, 'eom')
addpath(pwd, 'event')
addpath(pwd, 'func')
addpath(pwd, 'data')
addpath(pwd, 'fig')

%% 定数の設定
model = Twoleg;

E0 = 4500; % [J]

y0set = 0.60:0.01:0.75;
dtheta0 = -1.5; % [rad/s]

%% データの抽出
if calcflag == true
    filename = ['data/fixedPoints_for_ke=',num2str(model.ke),'_kg=',num2str(model.kg),'_E0=', num2str(E0), '_dtheta0=', num2str(dtheta0), '.mat'];
    load(filename);
%     fixedPoint = fixedPoint_;
%     clearvars fixedPoint_

    n = 0;
    num = length(fixedPoint);
    symbols = {'/','-','\\','|'};
    fprintf('\n')
    fprintf('[  0.0 %%] ');

    for i = 1:length(fixedPoint)

        if abs(fixedPoint(i).E - E0)<1e-3
            n = n + 1;
            y0 = fixedPoint(i).u_fix(1);
            dtheta0 = fixedPoint(i).u_fix(2);
            phi0 = fixedPoint(i).z_fix(1);
            q_ini = fixedPoint(i).q_ini;
            u_ini = [fixedPoint(i).z_fix(2), fixedPoint(i).z_fix(3)];
            model.init;
            model.bound(q_ini, u_ini);
            [eigenValues, eivenVectors, jacobi] = calc_eigenvalue(model, q_ini, u_ini);
            diagonal = diag(eigenValues);
            fixedPoints(n).fixedPoint = [y0, dtheta0, phi0];
            fixedPoints(n).q_ini = q_ini;
            fixedPoints(n).u_ini = u_ini;
            fixedPoints(n).tout = model.tout;
            fixedPoints(n).qout = model.qout;
            fixedPoints(n).eeout = model.eeout;
            fixedPoints(n).GRF = fixedPoint(i).GRF;
            fixedPoints(n).vel = model.qout(end,1)/model.tout(end);
            if (max(abs(diagonal)) - 1 ) < 1e-5
                fixedPoints(n).isStable = true;
            else
                fixedPoints(n).isStable = false;
            end
            fixedPoints(n).eig.eigenValues = diagonal;
            fixedPoints(n).eig.eivenVectors = eivenVectors;
            fixedPoints(n).eig.jacobi = jacobi;

            if fixedPoints(n).eeout(3) == 3
                % with DS
                if fixedPoints(n).fixedPoint(3) > 0
                    fixedPoints(n).soltype(1) = 1;    % E
                else
                    fixedPoints(n).soltype(1) = 2;    % G
                end
            elseif fixedPoints(n).eeout(3) == 1
                % without DS
                midtime = round(length(fixedPoints(n).tout)*0.5);
                if fixedPoints(n).fixedPoint(3) > 0
                    % E始まり
                    if fixedPoints(n).qout(midtime,4) > 0
                        fixedPoints(n).soltype(1) = 3; % EE
                    else
                        % fixedPoints(n).soltype(1) = 5; % EG
                        if fixedPoints(n).eeout(2) == 2
                            % hind leg first
                            fixedPoints(n).soltype(1) = 5; % EG
                        else
                            fixedPoints(n).soltype(1) = 6; % EG
                        end
                    end
                else
                    % G始まり
                    if fixedPoints(n).qout(midtime,4) > 0
                        % fixedPoints(n).soltype(1) = 6; % GE
                        if fixedPoints(n).eeout(2) == 2
                            % hind leg first
                            fixedPoints(n).soltype(1) = 6; % GE
                        else
                            fixedPoints(n).soltype(1) = 5; % EG
                        end
                    else
                        fixedPoints(n).soltype(1) = 4; % GG
                    end
                end
            else
                fixedPoints(n).soltype = 7;
            end % if soltype

            if fixedPoints(n).eeout(2) == 2
                % Hind leg first
                fixedPoints(n).soltype(2) = 1;
            else
                % Fore leg first
                fixedPoints(n).soltype(2) = 2;
            end
        end % if solutionEnergy

        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b')
        fprintf('\n[%6.2f %%] ',100*i/num)
        fprintf(cell2mat(symbols(1+rem(i,4))))
    end
    filename = ['data/fixedPoints_withStability_ke=',num2str(model.ke),'_kg=',num2str(model.kg),'_E0=', num2str(E0),'.mat'];
    save(filename, 'fixedPoints');
else
    filename = ['data/fixedPoints_withStability_ke=',num2str(model.ke),'_kg=',num2str(model.kg),'_E0=', num2str(E0),'.mat'];
    load(filename)
    n = length(fixedPoints);
end
fprintf('\n');


% soltype
% 1: E
% 2: G
% 3: EE
% 4: GG
% 5: EG
% 6: GE

% おしゃれカラー
green = [ 76,175, 80] ./ 255;
red   = [244, 67, 54] ./ 255;
blue  = [ 33,150,243] ./ 255;
Dred  = [136, 14, 79] ./ 255; % ダークレッド
Dblue = [ 26, 35,126] ./ 255; % ダークブルー
Lblue = [ 64,196,255] ./ 255;
Lred  = [255,171,  0] ./ 255;
grey  = [158,158,158] ./ 255;

clr = [Dred;Dblue;red;blue;Lred;Lblue;grey];
markerset = ['o','o'];
n = length(fixedPoints);

%% y-phi平面にプロット
h = figure;
for i=1:n
    if abs(dtheta0 - fixedPoints(i).fixedPoint(2)) < 1e-3
        plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).fixedPoint(3),'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
        hold on
        plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).fixedPoint(3),'marker','+','MarkerEdgeColor',clr(fixedPoints(i).soltype(1),:))

        % 安定な解を大きく描く場合
        if fixedPoints(i).isStable == true
            edgeClr = 'k';
            size = 5;
        else
            edgeClr = 'none';
            size = 3;
        end
    end

end
figtitle = ['$$\dot{\theta}=$$',num2str(dtheta0), '[rad/s]'];
title(figtitle,'interpreter','latex')

xlabel('$$y^*$$ [m]','interpreter','latex')
ylabel('$$\phi^*$$ [rad]','interpreter','latex')
xlim([y0set(1) y0set(end)])
ylim([0 1])

if saveflag == true
    figname_png = ['fig/fixedPoints_E0=',num2str(E0),'_dtheta0=',num2str(dtheta0),'.png'];
    figname_fig = ['fig/fixedPoints_E0=',num2str(E0),'_dtheta0=',num2str(dtheta0),'.fig'];
    figname_pdf = ['fig/fixedPoints_E0=',num2str(E0),'_dtheta0=',num2str(dtheta0),'.pdf'];
    saveas(h, figname_png)
    saveas(h, figname_fig)
    saveas(h, figname_pdf)
    disp('save finish!')
    close(h)
end

% %% dtheta-phi平面にプロット
% for i_y = 1:length(y0set)
%     h = figure;
%     y = y0set(i_y);
%     for i=1:n
%         if abs(y - fixedPoints(i).fixedPoint(1)) < 1e-3
% %             plot(fixedPoints(i).fixedPoint(2),fixedPoints(i).fixedPoint(3),'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
% %             hold on
%
%             % 安定な解を大きく描く場合
%             if fixedPoints(i).isStable == true
%                 edgeClr = 'k';
%                 size = 5;
%             else
%                 edgeClr = 'none';
%                 size = 3;
%             end
%             plot(fixedPoints(i).fixedPoint(2),fixedPoints(i).fixedPoint(3),'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor',edgeClr, 'MarkerSize',size)
%             hold on
%
% %             if max(abs(fixedPoints(i).soltype - [5,2])) == 0 || max(abs(fixedPoints(i).soltype - [6,1])) == 0
% %                 plot(fixedPoints(i).fixedPoint(2),fixedPoints(i).fixedPoint(3),'marker','o','MarkerFaceColor',red,'MarkerEdgeColor','none')
% %                 hold on
% %             else
% %                 plot(fixedPoints(i).fixedPoint(2),fixedPoints(i).fixedPoint(3),'marker','o','MarkerFaceColor',blue,'MarkerEdgeColor','none')
% %                 hold on
% %             end
%         end
%
%     end
%     figtitle = ['$$y=$$',num2str(y)];
%     title(figtitle,'interpreter','latex')
%     xlabel('$$\dot{\theta}^*$$ [rad/s]','interpreter','latex')
%     ylabel('$$\phi^*$$ [rad]','interpreter','latex')
%     xlim([dtheta0set(1) dtheta0set(end)])
%     ylim([-1 1.2])
%     grid on
%
%     if saveflag == true
%         figname_png = ['fig/fixedPoints_E0=',num2str(E0),'_y0=',num2str(y),'.png'];
%         figname_fig = ['fig/fixedPoints_E0=',num2str(E0),'_y0=',num2str(y),'.fig'];
%         saveas(h, figname_png)
%         saveas(h, figname_fig)
%         disp('save finish!')
%         close(h)
%     end
% end

