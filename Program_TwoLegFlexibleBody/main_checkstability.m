% fileName: main_test.m
% initDate:　2020/8/4
% Object:main_checkstability

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

i_ = 5
% for i_ = 1 : length(fixedPoint)

 q_fix = fixedPoint(i_).q_ini;
 u_fix(1) = fixedPoint(i_).u_fix(1);
 u_fix(2) = fixedPoint(i_).u_fix(2);
   
 [eigenValues, eivenVectors, jacobi] = calc_eigenvalue(model, q_fix, u_fix);
 
 logdata(i_).eigenValue = eigenValues
 
 logdata(i_).eivenVectors = eivenVectors
 
 logdata(i_).jacobi = jacobi

 diagonal(:,i_)  = diag(eigenValues);

 logdata(i_).diagonal = diagonal;
 
% end


%グラフをプロット

figure 
hold on

t=0:10:360;
% x=cosd(t);y=i*sind(t);
% figure(1)
z=cosd(t) + i * sind(t);
plot(z)
axis square


i_ = 1
% for i_ = 1: length(fixedPoint)
plot(diagonal(:,i_),'o')

% figure
% cx = 1; cy = 1; % 中心
% r = 0.5;           % 半径
% plot(r*sin(t)+cx,r*cos(t)+cy)
% axis([-2,2,-2,2])
% axis square
% end

xlabel ("Real")
ylabel ("Imaginary")