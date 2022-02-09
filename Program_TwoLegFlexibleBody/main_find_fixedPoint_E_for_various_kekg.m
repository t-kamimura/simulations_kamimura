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
keset = [100,200];
kgset = [100,25];
n = 1;
for ie = 1:length(keset)
    ke = keset(ie);
    for ig = 1:length(kgset)
        kg = kgset(ig);
%         if ke==100 && kg==100
%         else
            model(n) = Twoleg;
            model(n).ke = ke;
            model(n).kg = kg;
            n = n+1;
%         end
    end
end

E0 = 4500; % [J]

y0set = 0.60:0.01:0.75;
dtheta0set = -1.5; % [rad/s]

phi0set = -2:0.25:1; % [rad]

gammaset = -60:10:60; % [deg]
gammaset = deg2rad(gammaset);

%% 探索
% fprintf('[  0.0 %%] ');
% figure

n = 1;

%%
% load('data\identical_energy_dtheta\fixedPoints_for_E0=4500_dtheta0=-1.5.mat')
% for i_k = 1:length(model)
%     filename = ['data/fixedPoints_for_ke=',num2str(model(i_k).ke),'_kg=',num2str(model(i_k).kg),'_E0=', num2str(E0), '_dtheta0=', num2str(dtheta0), '.mat'];
%     if isfile(filename)==false
%         for i = 1:length(fixedPoint)
%             z_ini = fixedPoint(i).z_fix;
%             u_ini = fixedPoint(i).u_fix;
%             [z_fix, logDat, exitflag] = func_find_fixedPoint_E(model(i_k), z_ini, u_ini);
% 
%             if exitflag > 0
% 
%                 if n == 1
%                     fprintf('*');
%                     z_fixset = z_fix;
%                     u_fixset = u_ini;
%                     fixedPoint_ = logDat;
%                     n = n + 1;
%                 else
%                     breakflag = false;
% 
%                     for i_sol = 1:length(z_fixset(:, 1))
% 
%                         if max(abs(z_fix - z_fixset(i_sol, :))) < 1e-3 && max(abs(u_ini - u_fixset(i_sol, :))) < 1e-3
%                             % すでに見つかっているのと同じ固定点
%                             breakflag = true;
%                             break
%                         end
% 
%                     end
% 
%                     if breakflag == false
%                         fprintf('*');
%                         % データの保存
%                         z_fixset = [z_fixset; z_fix];
%                         u_fixset = [u_fixset; u_ini];
%                         fixedPoint_(n) = logDat;
%                         n = n + 1;
%                     else
%                         fprintf('-')
%                     end
% 
%                 end % if n==1
% 
%             else
%                 fprintf('.');
%             end % if exitflag
%         end % for i
%         % 保存
%         save(filename, 'fixedPoint_');
%         clearvars fixedPoint_ z_fixset u_fixset
%         n = 1;
%         fprintf('\n')
%     else
%         disp('file already exist...')
%     end % isfile
% end
%%
for i_k = 1:length(model)
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
                        [z_fix, logDat, exitflag] = func_find_fixedPoint_E(model(i_k), z_ini, u_ini);

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
        filename = ['data/fixedPoints_for_ke=',num2str(model(i_k).ke),'_kg=',num2str(model(i_k).kg),'_E0=', num2str(E0), '_dtheta0=', num2str(dtheta0), '.mat'];
        save(filename, 'fixedPoint');
        clearvars fixedPoint z_fixset u_fixset
        n = 1;
    end % for dtheta0
end

fprintf('\n')

%% 解の描画


h = msgbox('Caluculation finished !');
