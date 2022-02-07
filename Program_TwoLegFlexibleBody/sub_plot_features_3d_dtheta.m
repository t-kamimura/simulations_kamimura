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

E0 = 4500;
% y0set = 0.60:0.0025:0.75;
% dtheta0set = -2.5:0.0625:2.5;
y0set = 0.60:0.025:0.75;
dtheta0set = -1.5;

for i_theta = 1:length(dtheta0set)
%     load(['data/identical_energy_dtheta/fixedPoints_for_E0=', num2str(E0),'_dtheta0=',num2str(dtheta0set(i_theta)), '.mat'])
    filename = ['data/fixedPoints_for_kappa=',num2str(model.ke/model.kg),'_E0=', num2str(E0), '_dtheta0=', num2str(dtheta0set(i_theta)), '.mat'];
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
            % 力積の計算
            p = 0;
            for i_t = 2:length(model.tout)
                p = p + model.kh * (model.l3 - model.lout(i_t,1))*cos(model.gout(i_t,1))*(model.tout(i_t)-model.tout(i_t-1));
            end
            fixedPoints(n).fixedPoint = [y0, dtheta0, phi0];
            fixedPoints(n).u = u_ini;
            fixedPoints(n).tout = model.tout;
            fixedPoints(n).qout = model.qout;
            fixedPoints(n).eeout = model.eeout;
            fixedPoints(n).GRF = fixedPoint_integrated(i).GRF;
            fixedPoints(n).p = p;
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
    end
    filename = ['data/identical_energy_dtheta/fixedPoints_rearranged_E0=', num2str(E0),'.mat'];
    save(filename, 'fixedPoints');
else
    filename = ['data/identical_energy_dtheta/fixedPoints_rearranged_E0=', num2str(E0),'.mat'];
    load(filename)
    n = length(fixedPoints);
end
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

% %% y-dtheta-delta_y
% figure
% for i = 1:n
%     delta_y = max([fixedPoint_integrated(i).trajectory.qout(:,2)]) - min([fixedPoint_integrated(i).trajectory.qout(:,2)]);
%     plot3(fixedPoints(i).fixedPoint(1),fixedPoints(i).fixedPoint(2),delta_y,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
%     hold on
% end
% xlabel('$$y^*$$ [m]','interpreter','latex')
% ylabel('$$\dot{\theta}^*$$ [rad/s]','interpreter','latex')
% zlabel('$$\delta_y$$ [m]','interpreter','latex')
% 
% if saveflag == true
%     figname_png = ['fig/delta_y_E0=',num2str(E0),'.png'];
%     figname_fig = ['fig/delta_y_E0=',num2str(E0),'.fig'];
%     saveas(gcf, figname_png)
%     saveas(gcf, figname_fig)
%     disp('save finish!')
% end
% 
% %% y-theta-delta_theta
% figure
% for i = 1:n
%     delta_theta = max([fixedPoint_integrated(i).trajectory.qout(:,3)]) - min([fixedPoint_integrated(i).trajectory.qout(:,3)]);
%     plot3(fixedPoints(i).fixedPoint(1),fixedPoints(i).fixedPoint(2),delta_theta,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
%     hold on
% end
% xlabel('$$y^*$$ [m]','interpreter','latex')
% ylabel('$$\dot{\theta}^*$$ [rad/s]','interpreter','latex')
% zlabel('$$\delta_\theta$$ [rad]','interpreter','latex')
% 
% if saveflag == true
%     figname_png = ['fig/delta_theta_E0=',num2str(E0),'.png'];
%     figname_fig = ['fig/delta_theta_E0=',num2str(E0),'.fig'];
%     saveas(gcf, figname_png)
%     saveas(gcf, figname_fig)
%     disp('save finish!')
% end
% 
% %% y-dtheta-maxPhi
% figure
% for i = 1:n
%     maxPhi = max([fixedPoint_integrated(i).trajectory.qout(:,4)]);
%     plot3(fixedPoints(i).fixedPoint(1),fixedPoints(i).fixedPoint(2),maxPhi,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
%     hold on
% end
% xlabel('$$y^*$$ [m]','interpreter','latex')
% ylabel('$$\dot{\theta}^*$$ [rad/s]','interpreter','latex')
% zlabel('$$\max\phi$$ [rad]','interpreter','latex')
% 
% if saveflag == true
%     figname_png = ['fig/maxPhi_E0=',num2str(E0),'.png'];
%     figname_fig = ['fig/maxPhi_E0=',num2str(E0),'.fig'];
%     figname_pdf = ['fig/maxPhi_E0=',num2str(E0),'.pdf'];
%     saveas(gcf, figname_png)
%     saveas(gcf, figname_fig)
%     saveas(gcf, figname_pdf)
%     disp('save finish!')
% end
% 
% %% y-dtheta-minPhi
% figure
% for i = 1:n
%     minPhi = min([fixedPoint_integrated(i).trajectory.qout(:,4)]);
%     plot3(fixedPoints(i).fixedPoint(1),fixedPoints(i).fixedPoint(2),minPhi,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
%     hold on
% end
% xlabel('$$y^*$$ [m]','interpreter','latex')
% ylabel('$$\dot{\theta}^*$$ [rad/s]','interpreter','latex')
% zlabel('$$\min\phi$$ [rad]','interpreter','latex')
% 
% if saveflag == true
%     figname_png = ['fig/minPhi_E0=',num2str(E0),'.png'];
%     figname_fig = ['fig/minPhi_E0=',num2str(E0),'.fig'];
%     figname_pdf = ['fig/minPhi_E0=',num2str(E0),'.pdf'];
%     saveas(gcf, figname_png)
%     saveas(gcf, figname_fig)
%     saveas(gcf, figname_pdf)
%     disp('save finish!')
% end
% 
% %% y-dtheta-meamPhi
% figure
% for i = 1:n
%     meanPhi = mean([fixedPoint_integrated(i).trajectory.qout(:,4)]);
%     plot3(fixedPoints(i).fixedPoint(1),fixedPoints(i).fixedPoint(2),meanPhi,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
%     hold on
% end
% xlabel('$$y^*$$ [m]','interpreter','latex')
% ylabel('$$\dot{\theta}^*$$ [rad/s]','interpreter','latex')
% zlabel('$$\bar{\phi}$$ [rad]','interpreter','latex')
% 
% if saveflag == true
%     figname_png = ['fig/minPhi_E0=',num2str(E0),'.png'];
%     figname_fig = ['fig/minPhi_E0=',num2str(E0),'.fig'];
%     figname_pdf = ['fig/minPhi_E0=',num2str(E0),'.pdf'];
%     saveas(gcf, figname_png)
%     saveas(gcf, figname_fig)
%     saveas(gcf, figname_pdf)
%     disp('save finish!')
% end
% 
% %% y-dtheta-deltaPhi
% figure
% for i = 1:n
%     meanPhi = mean([fixedPoint_integrated(i).trajectory.qout(:,4)]);
%     minPhi = min([fixedPoint_integrated(i).trajectory.qout(:,4)]);
%     maxPhi = max([fixedPoint_integrated(i).trajectory.qout(:,4)]);
%     dphi = maxPhi - minPhi;
%     plot3(fixedPoints(i).fixedPoint(1),fixedPoints(i).fixedPoint(2),dphi,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
%     hold on
% end
% xlabel('$$y^*$$ [m]','interpreter','latex')
% ylabel('$$\dot{\theta}^*$$ [rad/s]','interpreter','latex')
% zlabel('$$\delta_\phi$$ [rad]','interpreter','latex')
% 
% if saveflag == true
%     figname_png = ['fig/minPhi_E0=',num2str(E0),'.png'];
%     figname_fig = ['fig/minPhi_E0=',num2str(E0),'.fig'];
%     figname_pdf = ['fig/minPhi_E0=',num2str(E0),'.pdf'];
%     saveas(gcf, figname_png)
%     saveas(gcf, figname_fig)
%     saveas(gcf, figname_pdf)
%     disp('save finish!')
% end

%% y-delta_y平面にプロット
% dtheta0set = [-1.5 1.5];
dtheta0set = -1.5;
for i_dtheta = 1:length(dtheta0set)
    h = figure;
    dtheta = dtheta0set(i_dtheta);
    for i=1:n
        if abs(dtheta - fixedPoints(i).fixedPoint(2)) < 1e-3
            delta_y = max([fixedPoint_integrated(i).trajectory.qout(:,2)]) - min([fixedPoint_integrated(i).trajectory.qout(:,2)]);
            plot(fixedPoints(i).fixedPoint(1),delta_y,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
            hold on
            plot(fixedPoints(i).fixedPoint(1),delta_y,'marker','+','MarkerEdgeColor',clr(fixedPoints(i).soltype(1),:))
        end
    end
    figtitle = ['$$\dot{\theta}=$$',num2str(dtheta)];
    title(figtitle,'interpreter','latex')
    xlabel('$$y^*$$ [m]','interpreter','latex')
    ylabel('$$\delta y$$ [m]','interpreter','latex')
    xlim([y0set(1) y0set(end)])
%     ylim([1400 2400])
    ylim([0 0.3])

    if saveflag == true
        figname_png = ['fig/delta_y_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.png'];
        figname_pdf = ['fig/delta_y_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.pdf'];
        figname_fig = ['fig/delta_y_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.fig'];
        saveas(h, figname_png)
        saveas(h, figname_pdf)
        saveas(h, figname_fig)
        disp('save finish!')
        close(h)
    end
end

%% y-delta_theta平面にプロット
% dtheta0set = [-1.5 1.5];
dtheta0set = -1.5;
for i_dtheta = 1:length(dtheta0set)
    h = figure;
    dtheta = dtheta0set(i_dtheta);
    for i=1:n
        if abs(dtheta - fixedPoints(i).fixedPoint(2)) < 1e-3
            delta_theta = max([fixedPoint_integrated(i).trajectory.qout(:,3)]) - min([fixedPoint_integrated(i).trajectory.qout(:,3)]);
            plot(fixedPoints(i).fixedPoint(1),delta_theta,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
            hold on
            plot(fixedPoints(i).fixedPoint(1),delta_theta,'marker','+','MarkerEdgeColor',clr(fixedPoints(i).soltype(1),:))
        end
    end
    figtitle = ['$$\dot{\theta}=$$',num2str(dtheta)];
    title(figtitle,'interpreter','latex')
    xlabel('$$y^*$$ [m]','interpreter','latex')
    ylabel('$$\delta\theta$$ [rad]','interpreter','latex')
    xlim([y0set(1) y0set(end)])
    ylim([0 0.6])
    if saveflag == true
        figname_png = ['fig/delta_theta_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.png'];
        figname_pdf = ['fig/delta_theta_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.pdf'];
        figname_fig = ['fig/delta_theta_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.fig'];
        saveas(h, figname_png)
        saveas(h, figname_pdf)
        saveas(h, figname_fig)
        disp('save finish!')
        close(h)
    end
end

% %% y-minPhi平面にプロット
% dtheta0set = [-1.5 1.5];
% for i_dtheta = 1:length(dtheta0set)
%     h = figure;
%     dtheta = dtheta0set(i_dtheta);
%     for i=1:n
%         if abs(dtheta - fixedPoints(i).fixedPoint(2)) < 1e-3
%             minPhi = min([fixedPoint_integrated(i).trajectory.qout(:,4)]);
%             plot(fixedPoints(i).fixedPoint(1),minPhi,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
%             hold on
%             plot(fixedPoints(i).fixedPoint(1),minPhi,'marker','+','MarkerEdgeColor',clr(fixedPoints(i).soltype(1),:))
%         end
%     end
%     figtitle = ['$$\dot{\theta}=$$',num2str(dtheta)];
%     title(figtitle,'interpreter','latex')
%     xlabel('$$y^*$$ [m]','interpreter','latex')
%     ylabel('$$\min\phi$$ [rad]','interpreter','latex')
%     xlim([y0set(1) y0set(end)])
%     ylim([-1.3 0.1])
% 
%     if saveflag == true
%         figname_png = ['fig/minPhi_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.png'];
%         figname_pdf = ['fig/minPhi_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.pdf'];
%         figname_fig = ['fig/minPhi_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.fig'];
%         saveas(h, figname_png)
%         saveas(h, figname_pdf)
%         saveas(h, figname_fig)
%         disp('save finish!')
%         close(h)
%     end
% end
% 
% %% y-maxPhi平面にプロット
% dtheta0set = [-1.5 1.5];
% for i_dtheta = 1:length(dtheta0set)
%     h = figure;
%     dtheta = dtheta0set(i_dtheta);
%     for i=1:n
%         if abs(dtheta - fixedPoints(i).fixedPoint(2)) < 1e-3
%             maxPhi = max([fixedPoint_integrated(i).trajectory.qout(:,4)]);
%             plot(fixedPoints(i).fixedPoint(1),maxPhi,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
%             hold on
%             plot(fixedPoints(i).fixedPoint(1),maxPhi,'marker','+','MarkerEdgeColor',clr(fixedPoints(i).soltype(1),:))
%         end
%     end
%     figtitle = ['$$\dot{\theta}=$$',num2str(dtheta)];
%     title(figtitle,'interpreter','latex')
%     xlabel('$$y^*$$ [m]','interpreter','latex')
%     ylabel('$$\max\phi$$ [rad]','interpreter','latex')
%     xlim([y0set(1) y0set(end)])
%     ylim([0 1.3])
% 
%     if saveflag == true
%         figname_png = ['fig/maxPhi_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.png'];
%         figname_pdf = ['fig/maxPhi_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.pdf'];
%         figname_fig = ['fig/maxPhi_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.fig'];
%         saveas(h, figname_png)
%         saveas(h, figname_pdf)
%         saveas(h, figname_fig)
%         disp('save finish!')
%         close(h)
%     end
% end
% 
% %% y-meanPhi平面にプロット
% dtheta0set = [-1.5 1.5];
% for i_dtheta = 1:length(dtheta0set)
%     h = figure;
%     dtheta = dtheta0set(i_dtheta);
%     for i=1:n
%         if abs(dtheta - fixedPoints(i).fixedPoint(2)) < 1e-3
%             meanPhi = mean([fixedPoint_integrated(i).trajectory.qout(:,4)]);
%             plot(fixedPoints(i).fixedPoint(1),meanPhi,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
%             hold on
%             plot(fixedPoints(i).fixedPoint(1),meanPhi,'marker','+','MarkerEdgeColor',clr(fixedPoints(i).soltype(1),:))
%         end
%     end
%     figtitle = ['$$\dot{\theta}=$$',num2str(dtheta),' [rad]'];
%     title(figtitle,'interpreter','latex')
%     xlabel('$$y^*$$ [m]','interpreter','latex')
%     ylabel('$$\bar{\phi}$$ [rad]','interpreter','latex')
%     xlim([y0set(1) y0set(end)])
%     ylim([-.2 .4])
% 
%     if saveflag == true
%         figname_png = ['fig/meanPhi_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.png'];
%         figname_pdf = ['fig/meanPhi_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.pdf'];
%         figname_fig = ['fig/meanPhi_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.fig'];
%         saveas(h, figname_png)
%         saveas(h, figname_pdf)
%         saveas(h, figname_fig)
%         disp('save finish!')
%         close(h)
%     end
% end

%% y-deltaPhi平面にプロット
% dtheta0set = [-1.5 1.5];
dtheta0set = -1.5;
for i_dtheta = 1:length(dtheta0set)
    h = figure;
    dtheta = dtheta0set(i_dtheta);
    for i=1:n
        if abs(dtheta - fixedPoints(i).fixedPoint(2)) < 1e-3
            dPhi = max([fixedPoint_integrated(i).trajectory.qout(:,4)]) - min([fixedPoint_integrated(i).trajectory.qout(:,4)]);
            plot(fixedPoints(i).fixedPoint(1),dPhi,'marker',markerset(fixedPoints(i).soltype(2)),'MarkerFaceColor',clr(fixedPoints(i).soltype(1),:),'MarkerEdgeColor','none')
            hold on
            plot(fixedPoints(i).fixedPoint(1),dPhi,'marker','+','MarkerEdgeColor',clr(fixedPoints(i).soltype(1),:))
        end
    end
    figtitle = ['$$\dot{\theta}=$$',num2str(dtheta),' [rad]'];
    title(figtitle,'interpreter','latex')
    xlabel('$$y^*$$ [m]','interpreter','latex')
    ylabel('$$\delta_{\phi}$$ [rad]','interpreter','latex')
    xlim([y0set(1) y0set(end)])
    ylim([-0.1 2.7])

    if saveflag == true
        figname_png = ['fig/deltaPhi_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.png'];
        figname_pdf = ['fig/deltaPhi_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.pdf'];
        figname_fig = ['fig/deltaPhi_E0=',num2str(E0),'_dtheta0=',num2str(dtheta),'.fig'];
        saveas(h, figname_png)
        saveas(h, figname_pdf)
        saveas(h, figname_fig)
        disp('save finish!')
        close(h)
    end
end