% fileName: sub_calc_stabolity.m
% initDate: 2021/9/8
% Object:  すでに見つかっている解の安定性を求める

clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaultAxesFontSize', 16);
set(0, 'defaultAxesFontName', 'times');
set(0, 'defaultTextFontSize', 16);
set(0, 'defaultTextFontName', 'times');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Construct a questdlg with three options
% choice = questdlg('Do you want to save the result(s)?', ...
%     'Saving opptions', ...
%     'Yes', 'No', 'Yes');
% % Handle response
% saveflag = false;

% switch choice
%     case 'Yes'
%         saveflag = true;
%     case 'No'
%         saveflag = false;
% end

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

y0set = 0.75:-0.001:0.60;
dtheta0set = 0:0.025:1.25;

%% データの抜き出し

filename = ['data/fixedPoints_for_E0=', num2str(E0), '_interporated.mat'];
load(filename, 'solset');

% 安定性を求める
for i_dtheta = 1:length(dtheta0set)
    for i_y = 1:length(y0set)
        if isempty(solset(i_y,i_dtheta).q_ini)
            fprintf('.')
        else
            q_ini = solset(i_y,i_dtheta).q_ini;
            u_ini = [solset(i_y,i_dtheta).z_fix(2), solset(i_y,i_dtheta).z_fix(3)];
            model.init;
            model.bound(q_ini, u_ini);
            [eigenValues, eivenVectors, jacobi] = calc_eigenvalue(model, q_ini, u_ini);
            diagonal = diag(eigenValues);
            if (max(abs(diagonal)) - 1 ) < 1e-5
                solset(i_y,i_dtheta).isStable = true;
            else
                solset(i_y,i_dtheta).isStable = false;
            end

            solset(i_y,i_dtheta).eig.eigenValues = diagonal;
            solset(i_y,i_dtheta).eig.eivenVectors = eivenVectors;
            solset(i_y,i_dtheta).eig.jacobi = jacobi;

            % 解の種類を分類
            % Flightが2回あるものは，Flight->Fore stance->Flight->Hind stance->Flight
            if solset(i_y,i_dtheta).event.eeout(3) == 3
                % with DS
                if solset(i_y,i_dtheta).z_fix(1) > 0
                    solset(i_y,i_dtheta).soltype = 1;    % E
                else
                    solset(i_y,i_dtheta).soltype = 2;    % G
                end
            elseif solset(i_y,i_dtheta).event.eeout(3) == 1
                % without DS
                midtime = round(length(solset(i_y,i_dtheta).trajectory.tout)*0.5);
                if solset(i_y,i_dtheta).z_fix(1) > 0
                    % E始まり
                    if solset(i_y,i_dtheta).trajectory.qout(midtime,4) > 0
                        solset(i_y,i_dtheta).soltype = 3; % EE
                    else
                        if solset(i_y,i_dtheta).event.eeout(2) == 2
                            % hind leg first
                            solset(i_y,i_dtheta).soltype = 5; % GE
                        else
                            solset(i_y,i_dtheta).soltype = 6; % EG
                        end
                    end
                else
                    % G始まり
                    if solset(i_y,i_dtheta).trajectory.qout(midtime,4) > 0
                        if solset(i_y,i_dtheta).event.eeout(2) == 2
                            % hind leg first
                            solset(i_y,i_dtheta).soltype = 6; % GE
                        else
                            solset(i_y,i_dtheta).soltype = 5; % EG
                        end
                    else
                        solset(i_y,i_dtheta).soltype= 4; % GG
                    end
                end
            else
                solset(i_y,i_dtheta).soltype = 7;
            end % if soltype
            fprintf('*')
        end % if isempty
    end % for y
    fprintf('\n')
end % for dtheta

filename = ['data/fixedPoints_for_E0=', num2str(E0), '_interporated_withStability.mat'];
save(filename, 'solset','y0set','dtheta0set','-v7.3');

%% 解の描画
figure
clr = jet(6);
for i_y = 1:length(y0set)
    y0 = y0set(i_y);
    for i_dtheta = 1:length(dtheta0set)
        dtheta0 = dtheta0set(i_dtheta);
        if isempty(solset(i_y,i_dtheta).q_ini)
            fprintf('.')
        else
            if solset(i_y,i_dtheta).isStable == true
                plotsize = 6;
            else
                plotsize = 3;
            end
            plot3(y0,dtheta0,solset(i_y,i_dtheta).z_fix(1),'Marker','o','MarkerEdgeColor','none','MarkerFaceColor',clr(solset(i_y,i_dtheta).soltype,:),'MarkerSize',plotsize)
            hold on
        end
    end
end

xlabel('$$y$$','Interpreter','latex')
ylabel('$$\dot{\theta}$$','Interpreter','latex')
zlabel('$$\phi$$','Interpreter','latex')

h = msgbox('Caluculation finished !');
