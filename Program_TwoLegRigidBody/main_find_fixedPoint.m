% fileName: main_find_fixedPoint.m
% initDate: 20200626
% Object:   Poulakakis (2006)の再現プログラム．ポアンカレ断面上の固定点を求める

clear
close all
add_subfolders();
default_settings(16,'times');
saveFlag = set_saveFlag('No');

%% 定数の決定
model = TwoLeg;

%% 定数の決定
dx0 = 1.0;
y0 = 0.35;

dtheta0set = 0:25:100; % [deg/s]
dtheta0set = deg2rad(dtheta0set);

gammaset = -50:10:50; % [deg]
gammaset = deg2rad(gammaset);

u_fixset = [];
n = 1;

%% 探索
fprintf('[  0.0 %%] ');
figure
fixedPoints = [];
for i_pitch = 1:length(dtheta0set)
    dtheta0 = dtheta0set(i_pitch);
    q_constants = [y0 dx0 dtheta0];

    for i_gb = 1:length(gammaset)
        gb_ini = gammaset(i_gb);

        for i_gf = 1:length(gammaset)
            gf_ini = gammaset(i_gf);
            u_ini = [gb_ini gf_ini];
            
            % 周期解の探索と保存
            logData = func_find_fixedPoint(model, q_constants, u_ini);
            fixedPoints = keep_logData(fixedPoints, logData);

        end % gf

        % 次のステップへ
        fprintf('\n')
        fprintf('[%5.1f %%]', ((i_pitch - 1) * length(gammaset) + i_gb) / (length(dtheta0set) * length(gammaset)) * 100);
        fprintf(' ');
    end % gb

end

fprintf('\n')

%% 保存
filename = ['data/fixedPoints_for_y0=', num2str(y0), '_dx0=', num2str(dx0), '.mat'];
save(filename, 'fixedPoints');


%%
figure
hold on

for i = 1:length(fixedPoints)
    plot(rad2deg(fixedPoints(i).q_constants(3)), rad2deg(fixedPoints(i).u_fix(1)), 'd', 'markerfacecolor', 'b', 'markeredgecolor', 'none');
    plot(rad2deg(fixedPoints(i).q_constants(3)), rad2deg(fixedPoints(i).u_fix(2)), 'o', 'markerfacecolor', 'none', 'markeredgecolor', 'r');
end

xlabel("pitch rate [deg/s]")
ylabel("touchdown angle [deg]")

if saveFlag == true
    figname0 = ['fig/fixedPoints_for_y0=', num2str(y0), '_dx0=', num2str(dx0)];
    save_my_figures(figname0);
end

h = msgbox('Caluculation finished !');
