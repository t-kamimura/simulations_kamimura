% fileName: sub_gait_classification.m
% Object:  doublestanceの有無だけを判定

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

model = Twoleg;

load('main_fixedPoints_for_y0=0.62_dx0=13,D=0.06,kt=220.mat')

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



%% ------------------------------------------------------------------------------------------------------------------------------------------
% phiとpitchrate

figure 
hold on

for i = 1:length(fixedPoint)

    if logdata(i).eeout(3) == 1
    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'ro', 'LineWidth', 2)
    end
    

    if logdata(i).eeout(3) == 3
    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'bo', 'LineWidth', 2)
    end 

end

xlabel('$$\dot{\theta_0}$$[deg/s]','Interpreter','latex')
ylabel('\phi_0 [deg]')
%title('dx = 5.6(red:without,blue:with)')

if saveflag == true

        figname1 = ['gait_phi']
        saveas(gcf, figname1, 'png')
        disp('save finish!')
end


%gammaとpitchrate

figure 
hold on

for i = 1:length(fixedPoint)

    gamma_hind = rem(rad2deg(fixedPoint(i).u_fix(1)),360);
    gamma_fore = rem(rad2deg(fixedPoint(i).u_fix(2)),360);

    if abs(gamma_hind) > 180
    gamma_hind = mod(rad2deg(fixedPoint(i).u_fix(1)),360);
    end 

    if abs(gamma_fore) > 180
    gamma_fore = mod(rad2deg(fixedPoint(i).u_fix(2)),360);
    end

    if logdata(i).eeout(3) == 1

    plot(rad2deg(fixedPoint(i).q_constants(3)), gamma_hind, 'rd', 'LineWidth', 2)
    plot(rad2deg(fixedPoint(i).q_constants(3)), gamma_fore, 'ro', 'LineWidth', 2)

    end

    if logdata(i).eeout(3) == 3

    plot(rad2deg(fixedPoint(i).q_constants(3)), gamma_hind, 'bd', 'LineWidth', 2)
    plot(rad2deg(fixedPoint(i).q_constants(3)), gamma_fore, 'bo', 'LineWidth', 2)
    
    end

end

xlabel('$$\dot{\theta_0}$$[deg/s]','Interpreter','latex')
ylabel('\gamma [deg]')
% title('dx = 5.6(red:without,blue:with)')


if saveflag == true
        
        figname2 = ['gait_gamma']
        saveas(gcf, figname2, 'png')
        disp('save finish!')
    end

