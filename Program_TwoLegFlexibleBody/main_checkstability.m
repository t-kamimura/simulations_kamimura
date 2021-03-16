% fileName: main_checkstability.m
% initDate:　2020/8/4
% Object: 固有値の軌道をグラフ化

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

for i_sol = 1:length(fixedPoint)

    q_fix = fixedPoint(i_sol).q_ini;
    u_fix(1) = fixedPoint(i_sol).u_fix(1);
    u_fix(2) = fixedPoint(i_sol).u_fix(2);

    [eigenValues, eivenVectors, jacobi] = calc_eigenvalue(model, q_fix, u_fix);

    diagonal = diag(eigenValues);
    logdata(i_sol).eigenValue = diagonal;
    logdata(i_sol).eivenVectors = eivenVectors;
    logdata(i_sol).jacobi = jacobi;

end


%グラフをプロット
figure
hold on


%単位円
 t = 0:1e-2:2 * pi;
 z = cos(t) + i * sin(t);
 plot(z)
 axis equal

 
 %全部まとめてプロットする場合
% for i_sol = 1:length(fixedPoint)
%    plot(real(logdata(i_sol).eigenValue), imag(logdata(i_sol).eigenValue), 'o')
% end


% 指定したものだけプロットする場合
 i_sol = 59;
 
 plot(real(logdata(i_sol).eigenValue), imag(logdata(i_sol).eigenValue), 'o')

 xlabel("Real")
 ylabel("Imaginary")
 

if saveflag == true
        
    figname = ['stability'];
    %saveas(gcf, figname, 'png')
    saveas(gcf, figname, 'pdf')
    disp('save finish!')
end


%% -----------------------------------------------------------------------------------------------------------------------------------------
%安定と不安定をグラフ化
% phiとpitchrate

% figure 
% hold on

% xlabel('$$\dot{\theta_0}$$[deg/s]','Interpreter','latex')
% ylabel('\phi_0 [deg]')
% title('red:stable,blue:unstable')

% for i_sol = 1:length(fixedPoint)

%     if max( abs(logdata(i_sol).eigenValue) - 1 ) < 1e-5
%     plot(rad2deg(fixedPoint(i_sol).q_constants(3)), rad2deg(fixedPoint(i_sol).u_fix(3)), 'ro', 'LineWidth', 2)
%     end 
    
%     if max( abs(logdata(i_sol).eigenValue) - 1 ) > 1e-5
%     plot(rad2deg(fixedPoint(i_sol).q_constants(3)), rad2deg(fixedPoint(i_sol).u_fix(3)), 'bo', 'LineWidth', 2)
%     end

% end


% if saveflag == true

%     figname1 = ['stability_phi']
%     saveas(gcf, figname1, 'png')
%     disp('save finish!')
% end




% % gammaとpitchrate

% figure 
% hold on

% xlabel('$$\dot{\theta_0}$$[deg/s]','Interpreter','latex')
% ylabel('\gamma [deg]')
% title('red:stable,blue:unstable')

% for i_sol = 1:length(fixedPoint)

%     gamma_hind = rem(rad2deg(fixedPoint(i_sol).u_fix(1)),360);
%     gamma_fore = rem(rad2deg(fixedPoint(i_sol).u_fix(2)),360);


%     if abs(gamma_hind) > 180
%     gamma_hind = mod(rad2deg(fixedPoint(i_sol).u_fix(1)),360);
%     end

%     if abs(gamma_fore) > 180
%     gamma_fore = mod(rad2deg(fixedPoint(i_sol).u_fix(2)),360);
%     end

%     if max( abs(logdata(i_sol).eigenValue) - 1 ) < 1e-5
%     plot(rad2deg(fixedPoint(i_sol).q_constants(3)), gamma_hind, 'rd')
%     plot(rad2deg(fixedPoint(i_sol).q_constants(3)), gamma_fore, 'ro')
%     end 
    
%     if max( abs(logdata(i_sol).eigenValue) - 1 ) > 1e-5
%     plot(rad2deg(fixedPoint(i_sol).q_constants(3)), gamma_hind, 'bd')
%     plot(rad2deg(fixedPoint(i_sol).q_constants(3)), gamma_fore, 'bo')
%     end

% end

%if saveflag == true
        
%   figname2 = ['stability_gamma']
%   saveas(gcf, figname2, 'png')
%   disp('save finish!')
%end



