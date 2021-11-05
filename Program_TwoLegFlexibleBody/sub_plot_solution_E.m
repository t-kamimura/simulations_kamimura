% fileName: sub_plot_solution.m
% initDate:　2021/11/01
% Object:  指定したdthetaの解を描画

clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaultAxesFontSize', 12);
set(0, 'defaultAxesFontName', 'times');
set(0, 'defaultTextFontSize', 16);
set(0, 'defaultTextFontName', 'times');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Construct a questdlg with three options
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

%saveflag = false;

% path追加
addpath(pwd, 'class')
addpath(pwd, 'symbolic')
addpath(pwd, 'eom')
addpath(pwd, 'event')
addpath(pwd, 'func')
addpath(pwd, 'data')
addpath(pwd, 'fig')


model = Twoleg;

%%
dtheta0 = -1.5;

E0 = 4500;
filename = ['data/identical_energy_dtheta/fixedPoints_for_E0=4500_dtheta0=', num2str(dtheta0),'.mat'];
load(filename)

%%
i_sol = 19;

q_fix = fixedPoint(i_sol).q_ini;
u_fix(1) = rem(fixedPoint(i_sol).z_fix(2),2*pi);
u_fix(2) = rem(fixedPoint(i_sol).z_fix(3),2*pi);

model.init
model.bound(q_fix, u_fix)

% model.plot(saveflag)
% model.anime(0.1, saveflag);

%% 状態量のグラフ
% -----------------------------------------------------------------
qlabelset = {'$$x$$ [m]', '$$y$$ [m]', '$$\theta$$ [rad]', '$$\phi$$ [rad]'...
    '$$\dot{x}$$ [m/s]', '$$\dot{y}$$ [m/s]', '$$\dot\theta$$ [rad/s]', '$$\dot\phi$$ [rad/s]'};
% -----------------------------------------------------------------
% 座標変換
qout_(:, 1) = model.qout(:, 1);
qout_(:, 2) = model.qout(:, 2);
qout_(:, 3) = model.qout(:, 3);
qout_(:, 4) = model.qout(:, 4);
qout_(:, 5) = model.qout(:, 5);
qout_(:, 6) = model.qout(:, 6);
qout_(:, 7) = model.qout(:, 7);
qout_(:, 8) = model.qout(:, 8);

tend = model.tout(end);
tout_ = model.tout;
teout_ = model.teout;
qeout_ = model.qeout;

figure('outerposition', [50, 200, 1200, 500])
ylimset =[  0 6.1;...
            0.55 0.7;...
            -0.25 0.25;...
            -0.6 0.6;...
            14.7 15.1;...
            -1.5 1.5;...
            -6 6;...
            -12 12];
for pp = 1:8
    subplot(2, 4, pp)
    plot(tout_, qout_(:, pp),'LineWidth',1);
    hold on
    for i = 1:length(teout_)
        line([teout_(i),teout_(i)],[min(qout_(:,pp)) max(qout_(:,pp))],'color','k','LineStyle',':')
    end
    xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
    ylabel(qlabelset{pp}, 'interpreter', 'latex', 'Fontsize', 14);
    xlim([0, tend]);
    ylim(ylimset(pp,:));
end

if saveflag == 1
    figname = ['stateVariables_E0=',num2str(E0),'_dtheta0=',num2str(dtheta0),'_i=',num2str(i_sol),'.fig'];
    saveas(gcf, figname, 'fig')
    figname = ['stateVariables_E0=',num2str(E0),'_dtheta0=',num2str(dtheta0),'_i=',num2str(i_sol),'.png'];
    saveas(gcf, figname, 'png')
    figname = ['stateVariables_E0=',num2str(E0),'_dtheta0=',num2str(dtheta0),'_i=',num2str(i_sol),'.pdf'];
    saveas(gcf, figname, 'pdf')
end

% %% エネルギーのグラフ
% figure
% % Eout_ = [(model.Eout(:, 1)./model.Eout(1,9)).*100, (model.Eout(:, 2)./model.Eout(1,9)).*100, (model.Eout(:, 3)./model.Eout(1,9)).*100, (model.Eout(:, 4)./model.Eout(1,9)).*100, (model.Eout(:, 6)./model.Eout(1,9)).*100, (model.Eout(:, 7)./model.Eout(1,9)).*100, (model.Eout(:, 8)./model.Eout(1,9)).*100, (model.Eout(:, 5)./model.Eout(1,9)).*100];
% totalE = model.Eout(1,9);
% Eout_ = model.Eout*100/totalE;
% Eout_(:,9) = [];
% area(model.tout, Eout_)
% colors = jet(8);
% 
% h = area(model.tout, Eout_);
% 
% for i = 1:length(h)
%    h(i).FaceColor = colors(i,:);
% end
% 
% xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
% ylabel('Energy', 'interpreter', 'latex', 'Fontsize', 14);
% legend({'trans:x','trans:y', 'rot:theta', 'rot:phi', 'kh','kf','torso','grav'},'location','best')
% xlim([0, model.tout(end)])
% ylim([86, 95])
% 
% 
% if saveflag == 1
%     figname = ['Energy_timeprofile'];
%     saveas(gcf, figname, 'fig')
%     saveas(gcf, figname, 'png')
%     % saveas(gcf, figname, 'pdf')
%     %saveas(gcf, figname, 'epsc')
% end
