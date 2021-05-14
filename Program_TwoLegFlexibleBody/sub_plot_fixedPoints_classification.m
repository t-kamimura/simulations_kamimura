% fileName: swarm_bodyclass.m
% initDate:　2021/2/26
% Object:  SWARM用　チーターと一致不一致

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
% addpath(pwd, 'data')
addpath(pwd, 'fig')

model = Twoleg;

dx0 = 15;
y0 = 0.66;
% load('main_fixedPoints_for_y0=0.62_dx0=13,D=0.06,kt=220.mat')
load(['fixedPoints_for_y0=',num2str(y0),'_dx0=',num2str(dx0),'.mat'])

for i = 1:length(fixedPoint)

    q_fix = fixedPoint(i).q_ini;
    u_fix(1) = fixedPoint(i).u_fix(1);
    u_fix(2) = fixedPoint(i).u_fix(2);

    [eigenValues, eivenVectors, jacobi] = calc_eigenvalue(model, q_fix, u_fix);

    diagonal = diag(eigenValues);
    logdata(i).eigenValue = diagonal;
    logdata(i).eivenVectors = eivenVectors;
    logdata(i).jacobi = jacobi;
    logdata(i).eeout = model.eeout;

end

%%---------------------------------------------------------------------------------------
%flight phaseでの体の状態を分類したい

figure
hold on

xlabel('$$\dot{\theta_0}$$[deg/s]', 'Interpreter', 'latex')
ylabel('\phi_0 [deg]')
%ylim([-60, 120]);
%title('dx=11,y=0.62,kt=220,D=0.06')

for i = 1:length(fixedPoint)

    i_middle = round(length(fixedPoint(i).trajectory.tout) / 2);

    %double leg flightが二回ある歩容
    if logdata(i).eeout(3) == 1

        %EE
        if fixedPoint(i).u_fix(3) > 0 && fixedPoint(i).trajectory.qout(i_middle, 4) > 0

            %後脚から着地
            if fixedPoint(i).q_constants(3) > 0
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')

                %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')

            end

            %GG
        elseif fixedPoint(i).u_fix(3) < 0 && fixedPoint(i).trajectory.qout(i_middle, 4) < 0

            %後脚から接地
            if fixedPoint(i).q_constants(3) > 0
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')

                %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')

            end

            %EG
        elseif (fixedPoint(i).u_fix(3)) > 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) < 0

            %後脚から接地
            if fixedPoint(i).q_constants(3) > 0
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')

                %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'd', 'markerfacecolor', 'r', 'markeredgecolor', 'r')

            end

            %GE
        elseif (fixedPoint(i).u_fix(3)) < 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) > 0

            if fixedPoint(i).q_constants(3) > 0
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'd', 'markerfacecolor', 'r', 'markeredgecolor', 'r')
                % plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12)

            elseif fixedPoint(i).q_constants(3) < 0
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')

            end

        end

        %double leg stanceがあるとき(double leg flightが一回だけ)
    elseif logdata(i).eeout(3) == 3

        %E
        if fixedPoint(i).u_fix(3) > 0

            %後脚から
            if fixedPoint(i).q_constants(3) > 0
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')

                %前脚から
            elseif fixedPoint(i).q_constants(3) < 0
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')

                %プロンク
            elseif fixedPoint(i).q_constants(3) == 0
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')

            end

            %G
        elseif fixedPoint(i).u_fix(3) < 0

            %後脚から
            if fixedPoint(i).q_constants(3) > 0
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')

                %前脚から
            elseif fixedPoint(i).q_constants(3) < 0
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')

                %プロンク
            elseif fixedPoint(i).q_constants(3) == 0
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')

            end

        end

    end

end

if saveflag == true

    figname = ['fig/fixedPoints_y0=',num2str(y0),'_dx0=',num2str(dx0),'.png'];
    saveas(gcf, figname)
    figname = ['fig/fixedPoints_y0=',num2str(y0),'_dx0=',num2str(dx0),'.fig'];
    saveas(gcf, figname)
    disp('save finish!')
end
