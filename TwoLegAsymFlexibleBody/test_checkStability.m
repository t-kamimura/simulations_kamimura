% fileName: test_checkStability.m
% initDate:　2020/8/5
% Object: 固有値計算のプログラムを確認

clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaultAxesFontSize', 12);
set(0, 'defaultAxesFontName', 'times');
set(0, 'defaultTextFontSize', 16);
set(0, 'defaultTextFontName', 'times');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% path追加
addpath(pwd, 'class')
addpath(pwd, 'symbolic')
addpath(pwd, 'eom')
addpath(pwd, 'event')
addpath(pwd, 'func')
addpath(pwd, 'data')
addpath(pwd, 'fig')

model = Twoleg;

load('fixedPoints_for_y0=0.68_dx0=5.mat')

i_sol = 12;

q_fix = fixedPoint(i_sol).q_ini;
u_fix(1) = fixedPoint(i_sol).u_fix(1);
u_fix(2) = fixedPoint(i_sol).u_fix(2);

% 摂動がない場合の計算
model.init
model.bound(q_fix, u_fix)
model.plot(false)
figure
plot(model.tout,model.Eout(:,7))

% zend(1) = model.qout(end, 2); % y
% zend(2) = model.qout(end, 3); % theta
% zend(3) = model.qout(end, 4); % phi
% zend(4) = model.qout(end, 5); % dx
% zend(5) = model.qout(end, 7); % dtheta
% zend(6) = model.qout(end, 8); % dphi
% model.q_err_max
%     
% x_fix = q_fix(1);
% y_fix = q_fix(2);
% theta_fix = q_fix(3);
% phi_fix = q_fix(4);
% dx_fix = q_fix(5);
% dy_fix = q_fix(6);
% dtheta_fix = q_fix(7);
% dphi_fix = q_fix(8);
% 
% z_fix = [y_fix theta_fix phi_fix dx_fix dtheta_fix dphi_fix];
% 
% dz = 1e-6;
% jacobi = zeros(6, 6);
% 
% for i_z = 1:6
% %     figure
% %     hold on
%     % 摂動を足す場合の計算
%     z_fix_plus = z_fix;
%     z_fix_plus(i_z) = z_fix_plus(i_z) + dz;
%     q_fix_plus = [x_fix, z_fix_plus(1), z_fix_plus(2), z_fix_plus(3), z_fix_plus(4), dy_fix, z_fix_plus(5) z_fix_plus(6)];
%     model.init;
%     model.bound(q_fix_plus, u_fix);
%     zend_plus(1) = model.qout(end, 2); % y
%     zend_plus(2) = model.qout(end, 3); % theta
%     zend_plus(3) = model.qout(end, 4); % phi
%     zend_plus(4) = model.qout(end, 5); % dx
%     zend_plus(5) = model.qout(end, 7); % dtheta
%     zend_plus(6) = model.qout(end, 8); % dphi
% %     plot(model.tout,model.qout(:,8),'r')
% 
%     % 摂動を引く場合の計算
%     z_fix_minus = z_fix;
%     z_fix_minus(i_z) = z_fix_minus(i_z) - dz;
%     q_fix_minus = [x_fix, z_fix_minus(1), z_fix_minus(2), z_fix_minus(3), z_fix_minus(4), dy_fix, z_fix_minus(5) z_fix_minus(6)];
%     model.init;
%     model.bound(q_fix_minus, u_fix);
%     zend_minus(1) = model.qout(end, 2); % y
%     zend_minus(2) = model.qout(end, 3); % theta
%     zend_minus(3) = model.qout(end, 4); % phi
%     zend_minus(4) = model.qout(end, 5); % dx
%     zend_minus(5) = model.qout(end, 7); % dtheta
%     zend_minus(6) = model.qout(end, 8); % dphi
% %     plot(model.tout,model.qout(:,8),'b')
% 
%     % 中央差分でヤコビアンを近似
%     zend_plus - zend_minus
%     jacobi(:, i_z) = 0.5 * (zend_plus - zend_minus)' / dz;
% %     zend_plus - zend
% %     jacobi(:, i_z) = (zend_plus - zend)' / dz;
% %     zend - zend_minus
% %     jacobi(:, i_z) = (zend - zend_minus)' / dz;
% end
% 
% [eivenVectors, eigenValues] = eig(jacobi);
    
    
[eigenValues, eivenVectors, jacobi] = calc_eigenvalue(model, q_fix, u_fix);

figure
plot(diag(eigenValues),'o')
hold on
t = 0:1e-2:2*pi;
z = cos(t)+i*sin(t);
plot(z)
axis equal