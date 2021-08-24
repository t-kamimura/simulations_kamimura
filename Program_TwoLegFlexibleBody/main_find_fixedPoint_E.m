% fileName: main_find_fixedPoint_E.m
% initDate: 20210517
% Object:  TwoLegFlexibleの固定点探索

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

% path追加
addpath(pwd, 'class')
addpath(pwd, 'symbolic')
addpath(pwd, 'eom')
addpath(pwd, 'event')
addpath(pwd, 'func')
addpath(pwd, 'data')
addpath(pwd, 'fig')

%% 定数の決定
model = Twoleg;

E0 = 4500; % [J]

y0set = 0.60:0.01:0.75;
% dtheta0set = -2:0.25:2;
dtheta0set = [-2.5 2.5];

phi0set = [-2:0.5:1]; % [rad]
% phi0set = 1; % [rad]

gammaset = -60:10:60; % [deg]
gammaset = deg2rad(gammaset);

u_fixset = [];

%% 探索
fprintf('[  0.0 %%] ');
% figure

n = 1;

for i_pitch = 1:length(dtheta0set)
    dtheta0 = dtheta0set(i_pitch);

    for i_y = 1:length(y0set)
        y0 = y0set(i_y);
        u_ini = [y0 dtheta0 E0]; % 今回のループで求める周期解の定数（固定）部分

        for i_phi = 1:length(phi0set)
            phi0 = phi0set(i_phi);

            for i_gb = 1:length(gammaset)
                gb_ini = gammaset(i_gb);

                for i_gf = 1:length(gammaset)
                    gf_ini = gammaset(i_gf);
                    z_ini = [phi0 gb_ini gf_ini]; % 今回のループで求める周期解の探索部分
                    [z_fix, logDat, exitflag] = func_find_fixedPoint_E(model, z_ini, u_ini);

                    if exitflag > 0

                        if n == 1
                            fprintf('*');
                            z_fixset = z_fix;
                            u_fixset = u_ini;
                            fixedPoint = logDat;
                            n = n + 1;
                        else
                            breakflag = false;

                            for i_sol = 1:length(z_fixset(:, 1))

                                if max(abs(z_fix - z_fixset(i_sol, :))) < 1e-3 && max(abs(u_ini - u_fixset(i_sol, :))) < 1e-3
                                    % すでに見つかっているのと同じ固定点
                                    breakflag = true;
                                    break
                                end

                            end

                            if breakflag == false
                                fprintf('*');
                                % データの保存
                                z_fixset = [z_fixset; z_fix];
                                u_fixset = [u_fixset; u_ini];
                                fixedPoint(n) = logDat;
                                n = n + 1;
                            else
                                fprintf('-')
                            end

                        end % if n==1

                    else
%                         fprintf('.');
                    end % if exitflag

                end % gf

            end % gb


        end % for phi0
        % 次のステップへ
        fprintf('\n')
        fprintf('[%5.1f %%] ', ((i_pitch - 1) * length(y0set) + i_y) / (length(y0set) * length(dtheta0set)) * 100);

    end % for y0

    % 保存
    filename = ['data/fixedPoints_for_E0=', num2str(E0), '_dtheta0=', num2str(dtheta0), '.mat'];
    save(filename, 'fixedPoint');
    clearvars fixedPoint
    n = 1;
end % for dtheta0


fprintf('\n')

%% 解の描画
% figure
% % u_ini = [y0 dtheta0 E0];    % 今回のループで求める周期解の定数（固定）部分
% % z_fix = [phi0 gb_ini gf_ini];   % 今回のループで求める周期解の探索部分
% clrs = 0.75 * parula(length(y0set));

% for i = 1:length(fixedPoint)

%     for i_y = 1:length(y0set)

%         if y0set(i_y) == fixedPoint(i).u_fix(1)
%             break
%         end

%     end

%     plot3(fixedPoint(i).u_fix(1), fixedPoint(i).u_fix(2), fixedPoint(i).z_fix(1), 'o', 'markerfacecolor', clrs(i_y, :), 'markeredgecolor', 'none');
%     hold on
% end

% xlabel("$$y^*$$ [m]", 'interpreter', 'latex')
% ylabel("$$\dot{\theta}^*$$ [rad/s]", 'interpreter', 'latex')
% zlabel("$$\phi^*$$ [rad]", 'interpreter', 'latex')

% try

%     if saveflag == true
%         figname0 = ['fig/fixedPoints_for_E0=', num2str(E0)];
%         figname1 = [figname0, '.fig'];
%         saveas(gcf, figname1, 'fig')
%         figname2 = [figname0, '.png'];
%         saveas(gcf, figname2, 'png')
%         disp('save finish!')
%     end

% catch
%     disp('some error(s) occurred in saving process')
% end

% %%
% for i_y = 1:length(y0set)
%     figure
%     for i = 1:length(fixedPoint)
%         if fixedPoint(i).u_fix(1) == y0set(i_y)
%             plot(fixedPoint(i).u_fix(2), fixedPoint(i).z_fix(1), 'o', 'markerfacecolor', 'b', 'markeredgecolor', 'none');
%             hold on
%         end
%     end
%     ylim([-1 1])
%     titlestr = ['y=',num2str(y0set(i_y))];
%     title(titlestr)
%     xlabel("$$\dot{\theta}^*$$ [rad/s]", 'interpreter', 'latex')
%     ylabel("$$\phi^*$$ [rad]", 'interpreter', 'latex')
%     if saveflag == true
%         figname0 = ['fig/fixedPoints_for_E0=', num2str(E0),'y0=',num2str(y0set(i_y))];
%         figname1 = [figname0, '.fig'];
%         saveas(gcf, figname1, 'fig')
%         figname2 = [figname0, '.png'];
%         saveas(gcf, figname2, 'png')
%         disp('save finish!')
%     end
% end

h = msgbox('Caluculation finished !');
