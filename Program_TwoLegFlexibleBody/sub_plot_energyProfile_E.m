% fileName: sub_plot_energyProfile_E.m
% initDate:　2020/9/24
% Object:  エネルギーの割合の時間遷移図
% 修正1: 2021/2/1 y軸をJ → %に変更

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

E0 = 4500;
dtheta0 = 1.5;
filename = ['data/identical_energy_dtheta/fixedPoints_for_E0=', num2str(E0),'_dtheta0=',num2str(dtheta0),'.mat'];
load(filename)

%%
i_sol = 21;

% q_fix = fixedPoints(i_sol).q_ini;
% u_fix(1) = fixedPoints(i_sol).u_ini(1);
% u_fix(2) = fixedPoints(i_sol).u_ini(2);

q_fix = fixedPoint(i_sol).q_ini;
u_fix(1) = fixedPoint(i_sol).z_fix(2);
u_fix(2) = fixedPoint(i_sol).z_fix(3);

model.init
model.bound(q_fix, u_fix)

% model.plot(saveflag)
% model.anime(0.1, saveflag);
% model.stick(50, saveflag);

%%
% -----------------------------------------------------------------
qlabelset = {'$$x$$ [m]', '$$y$$ [m]', '$$\theta$$ [rad]', '$$\phi$$ [rad]','$$\dot{x}$$ [m/s]', '$$\dot{y}$$ [m/s]', '$$\dot\theta$$ [rad/s]', '$$\dot\phi$$ [rad/s]'};
% -----------------------------------------------------------------
tout_ = [];
qout_ = [];
teout_ = [];
qeout_ = [];

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
ylimset =[  0 6;...
            0.54 0.71;...
            -0.22 0.22;...
            -1.0 1.0;...
            14.7 15.1;...
            -1.6 1.6;...
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
    % xlim([0, 0.35]);
    ylim(ylimset(pp,:));
end

if saveflag == 1
    figname_fig = ['variable1_dtheta0=',num2str(dtheta0),'_i=',num2str(i_sol),'.fig'];
    figname_pdf = ['variable1_dtheta0=',num2str(dtheta0),'_i=',num2str(i_sol),'.pdf'];
    figname_png = ['variable1_dtheta0=',num2str(dtheta0),'_i=',num2str(i_sol),'.png'];
    saveas(gcf, figname_fig, 'fig')
    saveas(gcf, figname_png, 'png')
    saveas(gcf, figname_pdf, 'pdf')
end

%% 床反力のグラフ
figure
GRF = [];
GRF_hori = [];
GRF_vert = [];
for i_t = 1:length(model.tout)
    l1 = model.lout(i_t,1);
    g1 = -model.gout(i_t,1);
    l2 = model.lout(i_t,2);
    g2 = -model.gout(i_t,2);
    GRF(i_t,1) = model.kh*(model.l3-l1);
    GRF(i_t,2) = model.kf*(model.l3-l2);
    GRF_hori(i_t,1) = GRF(i_t,1)*sin(g1);
    GRF_vert(i_t,1) = GRF(i_t,1)*cos(g1);
    GRF_hori(i_t,2) = GRF(i_t,2)*sin(g2);
    GRF_vert(i_t,2) = GRF(i_t,2)*cos(g2);
end
hold on
plot(model.tout, GRF(:,1));
plot(model.tout, GRF(:,2));
plot(model.tout, GRF_hori(:,1));
plot(model.tout, GRF_hori(:,2));
plot(model.tout, GRF_vert(:,1), '--');
plot(model.tout, GRF_vert(:,2), '--');
xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
ylabel('GRF [N]', 'interpreter', 'latex', 'Fontsize', 14);
xlim([0, max(model.tout)]);
ylim([-700 2400])
legend({'$$F_{\rm h}$$','$$F_{\rm f}$$','$$F_{1\rm hori}$$','$$F_{2\rm hori}$$','$$F_{1\rm vert}$$', '$$F_{2\rm vert}$$'},'interpreter','latex', 'Location', 'best')

if saveflag == 1
    figname = ['GRFprofile_i=',num2str(i_sol)];
    saveas(gcf, figname, 'fig')
    saveas(gcf, figname, 'png')
    saveas(gcf, figname, 'pdf')
end

%% 脚角度のグラフ
figure
plot(model.tout, model.gout(:, 1));
hold on
plot(model.tout, model.gout(:, 2), '--r');
xlim([0, max(model.tout)]);
ylim([-0.8, 0.8]);
xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
ylabel('$$\gamma_{\rm h},\gamma_{\rm f}$$ [rad]', 'interpreter', 'latex', 'Fontsize', 14);
legend({'hind leg', 'fore leg'}, 'Location', 'best')

if saveflag == 1
    figname = ['gamma_i=',num2str(i_sol)];
    saveas(gcf, figname, 'fig')
    saveas(gcf, figname, 'png')
    saveas(gcf, figname, 'pdf')
end

%%
param = [model.m model.J model.kh model.kf model.kt model.xf_toe model.xh_toe model.gamma_h_td model.gamma_f_td model.L model.l3 model.l4 model.D model.g];

for i_t = 1:length(tout_)
    q = [qout_(i_t,1) qout_(i_t,2) qout_(i_t,3) qout_(i_t,4)];
    dq= [qout_(i_t,5) qout_(i_t,6) qout_(i_t,7) qout_(i_t,8)];
    if (model.lout(i_t,1)-model.l3)<0
        torque_GRF_hind_out(i_t,:) = torque_GRF_hind(q,dq,param);
    else
        torque_GRF_hind_out(i_t,:) = [0 0 0 0];
    end
    if (model.lout(i_t,2)-model.l3)<0
        torque_GRF_fore_out(i_t,:) = torque_GRF_fore(q,dq,param);
    else
        torque_GRF_fore_out(i_t,:) = [0 0 0 0];
    end
    torque_spring_out(i_t,:) = torque_spring(q,dq,param);
end
figure
plot(tout_, torque_GRF_hind_out(:,4))
hold on
plot(tout_, torque_GRF_fore_out(:,4))
plot(tout_, torque_spring_out(:,4))
xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
ylabel('Torque on $$\phi$$ [Nm]', 'interpreter', 'latex', 'Fontsize', 14);
xlim([0, tend]);
ylim([-210 210]);
legend({'fore','hind','spring'})
if saveflag == 1
    figname_fig = ['torque_dtheta0=',num2str(dtheta0),'_i=',num2str(i_sol),'.fig'];
    figname_png = ['torque_dtheta0=',num2str(dtheta0),'_i=',num2str(i_sol),'.png'];
    figname_pdf = ['torque_dtheta0=',num2str(dtheta0),'_i=',num2str(i_sol),'.pdf'];
    saveas(gcf, figname_fig, 'fig')
    saveas(gcf, figname_png, 'png')
    saveas(gcf, figname_pdf, 'pdf')
end

%% エネルギーのグラフ
figure
% Eout_ = [(model.Eout(:, 1)./model.Eout(1,9)).*100, (model.Eout(:, 2)./model.Eout(1,9)).*100, (model.Eout(:, 3)./model.Eout(1,9)).*100, (model.Eout(:, 4)./model.Eout(1,9)).*100, (model.Eout(:, 6)./model.Eout(1,9)).*100, (model.Eout(:, 7)./model.Eout(1,9)).*100, (model.Eout(:, 8)./model.Eout(1,9)).*100, (model.Eout(:, 5)./model.Eout(1,9)).*100];
totalE = model.Eout(1,9);
Eout_ = model.Eout*100/totalE;
Eout_(:,9) = [];
area(model.tout, Eout_)
colors = jet(8);

h = area(model.tout, Eout_);

for i = 1:length(h)
   h(i).FaceColor = colors(i,:);
end

xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
ylabel('Energy', 'interpreter', 'latex', 'Fontsize', 14);
legend({'trans:x','trans:y', 'rot:theta', 'rot:phi', 'kh','kf','torso','grav'},'location','best')
xlim([0, model.tout(end)])
ylim([90, 96])

if saveflag == 1
    figname_fig = ['energy_dtheta0=',num2str(dtheta0),'_i=',num2str(i_sol),'.fig'];
    figname_png = ['energy_dtheta0=',num2str(dtheta0),'_i=',num2str(i_sol),'.png'];
    figname_pdf = ['energy_dtheta0=',num2str(dtheta0),'_i=',num2str(i_sol),'.pdf'];
    saveas(gcf, figname_fig, 'fig')
    saveas(gcf, figname_png, 'png')
    saveas(gcf, figname_pdf, 'pdf')
end
