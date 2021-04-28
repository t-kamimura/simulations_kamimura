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
% addpath(pwd, 'data')
addpath(pwd, 'fig')

model = Twoleg;

load('fixedPoints_for_y0=0.66_dx0=13.mat')

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

t = 0:1e-2:2 * pi;
z = cos(t) + 1i * sin(t);
plot(z)
axis equal

% 全部プロットする場合
for i_sol = 1:length(fixedPoint)
    plot(real(logdata(i_sol).eigenValue), imag(logdata(i_sol).eigenValue), 'o')
end

% % 指定したものだけプロットする場合
% i_sol = 10;
% plot(real(logdata(i_sol).eigenValue), imag(logdata(i_sol).eigenValue), 'o')

xlabel("Re")
ylabel("Im")
