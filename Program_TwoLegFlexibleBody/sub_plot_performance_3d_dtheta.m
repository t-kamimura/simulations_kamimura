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

%% データの抽出
model = Twoleg;

% E0 = 4500;
% y0set = 0.60:0.0025:0.75;
% dtheta0set = -2:0.25:2;

E0 = 4500;
y0set = 0.60:0.01:0.75;
dtheta0set = -1.5; % [rad/s]

for i_theta = 1:length(dtheta0set)
    % load(['data/identical_energy_dtheta/fixedPoints_for_E0=', num2str(E0),'_dtheta0=',num2str(dtheta0set(i_theta)), '.mat'])
    filename = ['data/fixedPoints_for_ke=',num2str(model.ke),'_kg=',num2str(model.kg),'_E0=', num2str(E0), '_dtheta0=', num2str(dtheta0set(i_theta)), '.mat'];
    load(filename);
    if i_theta == 1
        fixedPoint_integrated = fixedPoint;
    else
        fixedPoint_integrated = [fixedPoint_integrated,fixedPoint];
    end
    clearvars fixedPoint
end

%% 解の確認
if calcflag == true
    n = 0;
    num = length(fixedPoint_integrated);
    symbols = {'/','-','\\','|'};
    fprintf('\n')
    fprintf('[  0.0 %%] ');
    for i = 1:length(fixedPoint_integrated)
        if abs(fixedPoint_integrated(i).E - E0) < 1e-3
            n = n + 1;
            y0 = fixedPoint_integrated(i).u_fix(1);
            dtheta0 = fixedPoint_integrated(i).u_fix(2);
            phi0 = fixedPoint_integrated(i).z_fix(1);
            q_ini = fixedPoint_integrated(i).q_ini;
            u_ini = [fixedPoint_integrated(i).z_fix(2), fixedPoint_integrated(i).z_fix(3)];
            model.init;
            model.bound(q_ini, u_ini);

            % 力積の計算(脚1,後肢)
            p1.abs = 0;
            p1.hori_plus = 0;
            p1.hori_minus = 0;
            p1.vert= 0;
            for i_t = 2:length(model.tout)
                delta_p = model.kh * 0.5*((model.l3 - model.lout(i_t,1))+(model.l3 - model.lout(i_t-1,1)))*(model.tout(i_t)-model.tout(i_t-1));
                p1.abs = p1.abs + delta_p;
                p1.vert = p1.vert + delta_p*cos(0.5*(model.gout(i_t,1)+model.gout(i_t-1,1)));
                if model.gout(i_t,1) > 0
                    p1.hori_minus = p1.hori_minus - delta_p*sin(0.5*(model.gout(i_t,1)+model.gout(i_t-1,1)));
                else
                    p1.hori_plus = p1.hori_plus - delta_p*sin(0.5*(model.gout(i_t,1)+model.gout(i_t-1,1)));
                end
            end
            % 力積の計算(脚2,前肢)
            p2.abs = 0;
            p2.hori_plus = 0;
            p2.hori_minus = 0;
            p2.vert= 0;
            for i_t = 2:length(model.tout)
                delta_p = model.kf * 0.5*((model.l3 - model.lout(i_t,2))+(model.l3 - model.lout(i_t-1,2)))*(model.tout(i_t)-model.tout(i_t-1));
                p2.abs = p2.abs + delta_p;
                p2.vert = p2.vert + delta_p*cos(0.5*(model.gout(i_t,2)+model.gout(i_t-1,2)));
                if model.gout(i_t,2) > 0
                    p2.hori_minus = p2.hori_minus - delta_p*sin(0.5*(model.gout(i_t,2)+model.gout(i_t-1,2)));
                else
                    p2.hori_plus = p2.hori_plus - delta_p*sin(0.5*(model.gout(i_t,2)+model.gout(i_t-1,2)));
                end
            end
            fixedPoints(n).fixedPoint = [y0, dtheta0, phi0];
            fixedPoints(n).u = u_ini;
            fixedPoints(n).tout = model.tout;
            fixedPoints(n).qout = model.qout;
            fixedPoints(n).eeout = model.eeout;
            fixedPoints(n).GRF = fixedPoint_integrated(i).GRF;
            fixedPoints(n).p1 = p1;
            fixedPoints(n).p2 = p2;
            fixedPoints(n).vel = model.qout(end,1)/model.tout(end);
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
%                         fixedPoints(n).soltype(1) = 5; % EG
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
%                         fixedPoints(n).soltype(1) = 6; % GE
                        if fixedPoints(n).eeout(2) == 2
                            % hind leg first
                            fixedPoints(n).soltype(1) = 6; % EG
                        else
                            fixedPoints(n).soltype(1) = 5; % EG
                        end
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
        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b')
        fprintf('[%6.2f %%] ',100*i/num)
        fprintf(cell2mat(symbols(1+rem(i,4))))
    end
    filename = ['data/identical_energy_dtheta/fixedPoints_rearranged_E0=', num2str(E0),'.mat'];
    save(filename, 'fixedPoints');
else
    filename = ['data/identical_energy_dtheta/fixedPoints_rearranged_E0=', num2str(E0),'.mat'];
    load(filename)
    n = length(fixedPoints);
end
fprintf('\n');

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

h = figure;


dtheta = dtheta0set(1);


%% y-vel平面にプロット
subplot(2,2,1)
for i=1:n
    if abs(dtheta - fixedPoints(i).fixedPoint(2)) < 1e-3
        plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).vel,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
        hold on
        plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).vel,'marker','*','MarkerEdgeColor',clr(fixedPoints(i).soltype(1),:))
    end
end
figtitle = ['$$\dot{\theta}=',num2str(dtheta),',(k_e,k_g)=(',num2str(model.ke),',',num2str(model.kg),')$$'];
title(figtitle,'interpreter','latex')
xlabel('$$y^*$$ [m]','interpreter','latex')
ylabel('$$\bar{v}$$ [m/s]','interpreter','latex')
xlim([y0set(1) y0set(end)])
%     ylim([12.5 13.2])
ylim([14.5 15.2])

%% y-p平面にプロット
subplot(2,2,2)
for i=1:n
    if abs(dtheta - fixedPoints(i).fixedPoint(2)) < 1e-3
        plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).p1.abs,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
        hold on
        plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).p1.abs,'marker','+','MarkerEdgeColor',clr(fixedPoints(i).soltype(1),:))
    end
end
% figtitle = ['$$\dot{\theta}=',num2str(dtheta),',(k_e,k_g)=(',num2str(model.ke),',',num2str(model.kg),')$$'];
% title(figtitle,'interpreter','latex')
xlabel('$$y^*$$ [m]','interpreter','latex')
ylabel('$$p$$ [Ns]','interpreter','latex')
xlim([y0set(1) y0set(end)])
ylim([20 100])

%% y-p_vert平面にプロット
subplot(2,2,3)
for i=1:n
    if abs(dtheta - fixedPoints(i).fixedPoint(2)) < 1e-3
        plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).p1.vert,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
        hold on
        plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).p1.vert,'marker','+','MarkerEdgeColor',clr(fixedPoints(i).soltype(1),:))
    end
end
% figtitle = ['$$\dot{\theta}=',num2str(dtheta),',(k_e,k_g)=(',num2str(model.ke),',',num2str(model.kg),')$$'];
% title(figtitle,'interpreter','latex')
xlabel('$$y^*$$ [m]','interpreter','latex')
ylabel('$$p_y$$ [Ns]','interpreter','latex')
xlim([y0set(1) y0set(end)])
ylim([20 100])

%% y-p_hori平面にプロット
subplot(2,2,4)
for i=1:n
    if abs(dtheta - fixedPoints(i).fixedPoint(2)) < 1e-3
        plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).p1.hori_plus,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
        hold on
        plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).p1.hori_plus,'marker','+','MarkerEdgeColor',clr(fixedPoints(i).soltype(1),:))
        plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).p1.hori_minus,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
        plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).p1.hori_minus,'marker','+','MarkerEdgeColor',clr(fixedPoints(i).soltype(1),:))
    end
end
% figtitle = ['$$\dot{\theta}=',num2str(dtheta),',(k_e,k_g)=(',num2str(model.ke),',',num2str(model.kg),')$$'];
% title(figtitle,'interpreter','latex')
xlabel('$$y^*$$ [m]','interpreter','latex')
ylabel('$$p_{x}$$ [Ns]','interpreter','latex')
xlim([y0set(1) y0set(end)])
ylim([-20 20])


% subplot(2,2,4)
% for i=1:n
%     if abs(dtheta - fixedPoints(i).fixedPoint(2)) < 1e-3
%         plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).p2.hori_plus,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
%         hold on
%         plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).p2.hori_plus,'marker','+','MarkerEdgeColor',clr(fixedPoints(i).soltype(1),:))
%         plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).p2.hori_minus,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
%         plot(fixedPoints(i).fixedPoint(1),fixedPoints(i).p2.hori_minus,'marker','+','MarkerEdgeColor',clr(fixedPoints(i).soltype(1),:))
%     end
% end
% figtitle = ['$$\dot{\theta}=$$',num2str(dtheta)];
% title(figtitle,'interpreter','latex')
% xlabel('$$y^*$$ [m]','interpreter','latex')
% ylabel('$$p_{x2}$$ [Ns]','interpreter','latex')
% xlim([y0set(1) y0set(end)])
% ylim([-20 20])


if saveflag == true
    figname_png = ['fig/performance_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'(k_e,k_g)=(',num2str(model.ke),',',num2str(model.kg),'.png'];
    figname_pdf = ['fig/performance_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'(k_e,k_g)=(',num2str(model.ke),',',num2str(model.kg),'.pdf'];
    figname_fig = ['fig/performance_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'(k_e,k_g)=(',num2str(model.ke),',',num2str(model.kg),'.fig'];
    saveas(h, figname_png)
    saveas(h, figname_pdf)
    saveas(h, figname_fig)
    disp('save finish!')
    close(h)
end