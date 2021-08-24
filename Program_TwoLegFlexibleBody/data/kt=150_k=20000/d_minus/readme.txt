main_find_fixedPoint_E.mで計算

定数
% チーターParamの定義( 上村先生論文より)
        % 慣性モーメント [kg m^2]
        J = 0.53; %後胴体の慣性モーメント

        % 質量m [kg]
        m = 18.8;

        % ばね定数k_leg [N / m]
        kh = 20000; %後脚のバネ定数
        kf = 20000; %前脚のバネ定数
        kt = 150; %ジョイント部分バネ定数

        % 減衰定数 [Ns / m]
        c = 0;

        %  胴体の長さl[m](脚の付根から重心まで)
        L = 0.29;
%         D = 0.06; %脚の付け根までの長さ(GRF位置ではなく実測値)
        D = -0.02;  % 20210607マイナスにしてみる

        % 足のばねの自然帳l_0[m]
        l3 = 0.685; %後脚の長さ
        l4 = 0.685; %前脚の長さ

        % 重力加速度 [m/s^2]
        g = 9.8;


%% 定数の決定
model = Twoleg;

E0 = 3500; % [J]

y0set = 0.65:0.0025:0.68;

% phi0set = [-30:15:30]; % [deg]
% phi0set = deg2rad(phi0set);

% dtheta0set = [-119:1:-104]; % [deg/s]
% dtheta0set = deg2rad(dtheta0set);

phi0set = [-1:0.25:0.5]; % [rad]

dtheta0set = [-0.5:-0.25:-2.5]; % [rad/s]

gammaset = [-50:10:50]; % [deg]
gammaset = deg2rad(gammaset);

u_fixset = [];

