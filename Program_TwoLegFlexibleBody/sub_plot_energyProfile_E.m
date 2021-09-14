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
filename = ['data/identical_energy_dtheta/fixedPoints_withStability_E0=', num2str(E0),'.mat'];
load(filename)

%%
i_sol = 552;
% i_sol = 77;
% i_sol = 464;

q_fix = fixedPoints(i_sol).q_ini;
% u_fix(1) = rem(fixedPoints(i_sol).u_ini(1),2*pi);
% u_fix(2) = rem(fixedPoints(i_sol).u_ini(2),2*pi);
u_fix(1) = fixedPoints(i_sol).u_ini(1);
u_fix(2) = fixedPoints(i_sol).u_ini(2);

model.init
model.bound(q_fix, u_fix)

% model.plot(saveflag)
model.anime(0.1, saveflag);
% model.stick(50, saveflag);


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
    figname = ['variable1_i=',num2str(i_sol)];
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
% ylim(ylimset(pp,:);
legend({'fore','hind','spring'})


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
ylim([86, 95])


if saveflag == 1
    figname = ['Energy_timeprofile'];
    saveas(gcf, figname, 'fig')
    saveas(gcf, figname, 'png')
    % saveas(gcf, figname, 'pdf')
    %saveas(gcf, figname, 'epsc')
end
