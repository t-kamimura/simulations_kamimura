clear
close all
addpath(pwd, 'eom')

param.kt = 100;
param.ke = 80;
param.kg = 120;
param.J = 0.53;
param.omega0 = sqrt(2*param.kt/param.J);
kappa = 0.4;
param.omega = param.omega0/kappa;

A = (param.ke - param.kg)*0.5;

tset = 0:1e-2:0.5;
ktset1 = nan(length(tset));
ktset2 = nan(length(tset));
for i = 1:length(tset)
    ktset1(i) = set_kt(tset(i),param);
    ktset2(i) = param.kt + A*sin(param.omega*tset(i));
end

figure
plot(tset,ktset1)
hold on
plot(tset,ktset2)
xlabel("time")
ylabel("k_t")