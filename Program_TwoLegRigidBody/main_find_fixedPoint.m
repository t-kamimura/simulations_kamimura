% fileName: main_find_fixedPoint.m
% initDate: 20200626
% Object:   Poulakakis (2006)の再現プログラム．ポアンカレ断面上の固定点を求める

clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaultAxesFontSize', 12);
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

%% 定数の決定
model = TwoLeg;

%% 定数の決定
dx0 = 1.0;
y0 = 0.35;

dtheta0set = [-500:25:500]; % [deg/s]
dtheta0set = deg2rad(dtheta0set);

gammaset = [-50:10:50]; % [deg]
% gammaset = 0; % [deg]
gammaset = deg2rad(gammaset);

u_fixset = [];
n = 1;

%% 探索
fprintf('[  0.0 %%] ');
figure
for i_pitch = 1:length(dtheta0set)
    dtheta0 = dtheta0set(i_pitch);
    q_constants = [y0 dx0 dtheta0];

    for i_gb = 1:length(gammaset)
        gb_ini = gammaset(i_gb);

        for i_gf = 1:length(gammaset)
            gf_ini = gammaset(i_gf);
            u_ini = [gb_ini gf_ini];
            [u_fix, logDat, exitflag] = func_find_fixedPoint(u_ini, model, q_constants);

            if exitflag > 0

                if n == 1
                    fprintf('*');
                    u_fixset = u_fix;
                    fixedPoint = logDat;
                    n = n + 1;
                else
                    breakflag = false;

                    for i_sol = 1:length(u_fixset(:,1))

                        if abs(u_fix(1) - u_fixset(i_sol, 1)) < 1e-3 && abs(u_fix(2) - u_fixset(i_sol, 2)) < 1e-3
                            breakflag = true;
                            break
                        end

                    end

                    if breakflag == false
                        fprintf('*');
                        % データの保存
                        u_fixset = [u_fixset; u_fix];
                        fixedPoint(n) = logDat;
                        n = n + 1;
                    else
                        fprintf('-')
                    end

                end % if n==1

            else
                fprintf('.');
            end % if exitflag

        end % gf

        % 次のステップへ
        fprintf('\n')
        fprintf('[%5.1f %%]', ((i_pitch - 1) * length(gammaset) + i_gb) / (length(dtheta0set) * length(gammaset)) * 100);
        fprintf(' ');
    end % gb

end

fprintf('\n')

% 保存
filename = ['data/fixedPoints_for_y0=', num2str(y0), '_dx0=', num2str(dx0), '.mat'];
save(filename, 'fixedPoint');

figure
hold on

for i = 1:length(fixedPoint)
    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(1)), 'd', 'markerfacecolor', 'b', 'markeredgecolor', 'none');
    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(2)), 'o', 'markerfacecolor', 'none', 'markeredgecolor', 'r');
end

xlabel("pitch rate [deg/s]")
ylabel("touchdown angle [deg]")

try

    if saveflag == true
        figname0 = ['fig/fixedPoints_for_y0=', num2str(y0), '_dx0=', num2str(dx0)];
        figname1 = [figname0,'.fig'];
        saveas(gcf, figname1, 'fig')
        figname2 = [figname0,'.png'];
        saveas(gcf, figname2, 'png')
        disp('save finish!')
    end

catch
    disp('some error(s) occurred in saving process')
end

h = msgbox('Caluculation finished !');
