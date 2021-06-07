% fileName: sub_plot_energyProfile.m
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

E0 = 3500;
filename = ['data/identical_energy_dtheta/fixedPoints_rearranged_E0=', num2str(E0),'.mat'];
load(filename)

%%
i = 182;

q_fix = fixedPoints(i).q_ini;
u_fix(1) = rem(fixedPoints(i).u_ini(1),2*pi);
u_fix(2) = rem(fixedPoints(i).u_ini(2),2*pi);

model.init
model.bound(q_fix, u_fix)

model.plot(saveflag)
model.anime(0.1, saveflag);

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
