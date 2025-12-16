% fileName: main_find_fixedPoint.m
% initDate: 20200722
% Object:  TwoLegFlexibleの固定点探索

clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaultAxesFontSize', 12);
set(0, 'defaultAxesFontName', 'times');
set(0, 'defaultTextFontSize', 16);
set(0, 'defaultTextFontName', 'times');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% path追加
addpath(genpath('class'))
addpath(pwd, 'func')
addpath(pwd, 'data')
addpath(pwd, 'fig')

%% 定数の決定
kappa = 0.5;
model = Twoleg(kappa);

dx0 = 12; % [m/s]
y0 = 0.7; % [m]

phi0set = 0; % [deg]
phi0set = deg2rad(phi0set);

dtheta0set = 50:25:100; % [deg/s]
dtheta0set = deg2rad(dtheta0set);

gammaset = 50:-10:0; % [deg]
gammaset = deg2rad(gammaset);

u_fixset = [];
n = 1;

%% 探索
fprintf('[  0.0 %%] ');
% figure
for i_phi = 1:length(phi0set)
    phi0 = phi0set(i_phi);
    for i_pitch = 1:length(dtheta0set)
        dtheta0 = dtheta0set(i_pitch);
        for i_gb = 1:length(gammaset)
            gb_ini = gammaset(i_gb);
            for i_gf = 1:length(gammaset)
                gf_ini = gammaset(i_gf);
                u_ini = [y0 phi0 dx0 dtheta0 gb_ini gf_ini];
                [u_fix, logDat, exitflag] = func_find_fixedPoint(u_ini, model);
                if exitflag == 1
                    if n == 1
                        % fprintf('%d', exitflag);
                        fprintf('*');
                        u_fixset = u_fix;
                        fixedPoint = logDat;
                        n = n + 1;
                    else
                        breakflag = false;
                        for i_sol = 1:length(u_fixset(:,1))
                            if abs(u_fix - u_fixset(i_sol, :)) < 1e-5
                                % すでに見つかっているのと同じ固定点
                                breakflag = true;
                                break
                            end
                        end
                        if breakflag == false
                            % fprintf('%d', exitflag);
                            fprintf('*');
                            % データの保存
                            u_fixset = [u_fixset; u_fix];
                            fixedPoint(n) = logDat;
                            n = n + 1;
                        else
                            fprintf('-')
                        end
                    end % if n==1
                elseif exitflag > 1
                    % fprintf('%d', exitflag);
                    fprintf('.');
                else
                    fprintf('.');
                end % if exitflag
            end % gf
        end % gb

        % 次のステップへ
        fprintf('\n')
        fprintf('[%5.1f %%] ', ((i_phi- 1) * length(dtheta0set) + i_pitch) / (length(phi0set) * length(dtheta0set)) * 100);

    end % dtheta0
end % phi0

fprintf('\n')

%% 保存
filename = ['data/fixedPoints_for_kappa=', num2str(model.kappa), '.mat'];
save(filename, 'fixedPoint');

% h = msgbox('Caluculation finished !');
