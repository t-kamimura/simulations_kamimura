% fileName: sub_Energy.m
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

dx0 = 13;
y0 = 0.66;
% load('main_fixedPoints_for_y0=0.62_dx0=13,D=0.06,kt=220.mat')
load(['fixedPoints_for_y0=',num2str(y0),'_dx0=',num2str(dx0),'.mat'])

i = 63;

q_fix = fixedPoint(i).q_ini;
u_fix(1) = fixedPoint(i).u_fix(1);
u_fix(2) = fixedPoint(i).u_fix(2);

q_ini = [q_fix(1) q_fix(2) q_fix(3) q_fix(4) q_fix(5) q_fix(6) q_fix(7) q_fix(8)];
u_ini = [u_fix(1) u_fix(2)];

model.init
model.bound(q_ini, u_ini)

model.plot(saveflag)
model.anime(0.1, false);

% エネルギーのグラフ
figure
Eout_ = [(model.Eout(:, 1)./model.Eout(1,9)).*100, (model.Eout(:, 2)./model.Eout(1,9)).*100, (model.Eout(:, 3)./model.Eout(1,9)).*100, (model.Eout(:, 4)./model.Eout(1,9)).*100, (model.Eout(:, 6)./model.Eout(1,9)).*100, (model.Eout(:, 7)./model.Eout(1,9)).*100, (model.Eout(:, 8)./model.Eout(1,9)).*100, (model.Eout(:, 5)./model.Eout(1,9)).*100];
area(model.tout, Eout_)
colors = jet(8);

h = area(model.tout, Eout_);

for i = 1:length(h)
   h(i).FaceColor = colors(i,:);
end

xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
ylabel('Energy', 'interpreter', 'latex', 'Fontsize', 14);
legend({'trans:x','trans:y', 'rot:theta', 'rot:phi', 'kh','kf','torso', 'grav'},'location','best')
xlim([0, model.tout(end)])
ylim([80, 100])


if saveflag == 1
    figname = ['Energy_timeprofile'];
    %saveas(gcf, figname, 'fig')
    %saveas(gcf, figname, 'png')
    saveas(gcf, figname, 'pdf')
    %saveas(gcf, figname, 'epsc')
end
