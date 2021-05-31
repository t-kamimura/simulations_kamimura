%% 定数の決定
model = Twoleg;

E0 = 3500; % [J]

y0set = 0.65:0.001:0.68;

phi0set = [-30:15:30]; % [deg]
phi0set = deg2rad(phi0set);

dtheta0set = [-150:15:150]; % [deg/s]
dtheta0set = deg2rad(dtheta0set);

gammaset = [-50:10:50]; % [deg]
gammaset = deg2rad(gammaset);
