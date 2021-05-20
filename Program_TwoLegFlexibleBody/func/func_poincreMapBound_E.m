% １周期のバウンド歩行を行う関数
%　　　ポアンカレ断面でシミュレーションを開始し，１周期運動させておわる．

function [F_new] = func_poincreMapBound_E(model, z, u)

    % 初期値代入
    x0 = 0.0;
    y0 = u(1);
    theta0 = 0;
    phi0 = z(1);
    dx0 = 0;
    dy0 = 0;
    dtheta0 = u(2);
    dphi0 = 0;

    % エネルギーから初期速度を求める
    M2 = 2 * model.m;
    M3 = 2 * model.J + 2 * model.m * model.L^2 * (cos(phi0))^2;
    T = 0.5  * (M2*dy0^2 + M3*dtheta0^2);
    U = 2 * model.m * model.g * y0 + 0.5 * model.kt * (2*phi0)^2;

    dx0 = sqrt((u(3) - T - U)/model.m);

    gb_ini = z(2);
    gf_ini = z(3);

    q_ini = [x0 y0 theta0 phi0 dx0 dy0 dtheta0 dphi0];
    tdAngle = [gb_ini gf_ini];

    % x_joint = x0 - model.L * cos(phi0) * cos(theta0) + model.L * cos(theta0 - phi0);   %ジョイント部
    % y_joint = y0 - model.L * cos(phi0) * sin(theta0) + model.L * sin(theta0 - phi0);
    % head.x = x0 + model.L * cos(theta0) * cos(phi0) + model.D * cos(theta0 + phi0);
    % head.y = y0 + model.L * cos(phi0) * sin(theta0) + model.D * sin(theta0 + phi0);
    % hip.x = x0 - model.L * cos(theta0) * cos(phi0) - model.D * cos(theta0 - phi0);
    % hip.y = y0 - model.L * cos(phi0) * sin(theta0) - model.D * sin(theta0 - phi0);

    % toe_b.x = hip.x + model.l3*sin(gb_ini);
    % toe_b.y = hip.y - model.l3*cos(gb_ini);
    % toe_f.x = head.x + model.l4*sin(gf_ini);
    % toe_f.y = head.y - model.l4*cos(gf_ini);

    % cla
    % body1 = line([head.x, x_joint],[head.y, y_joint],'color','k');
    % body2 = line([x_joint, hip.x],[y_joint, hip.y],'color','k');
    % hindLeg = line([hip.x toe_b.x],[hip.y toe_b.y]);
    % foreLeg = line([head.x toe_f.x],[head.y toe_f.y]);
    % xlim([-0.8 0.8])
    % ylim([-0.2 1.5])
    % drawnow

    model.init
    try
        model.bound(q_ini, tdAngle)
        % model.Eout(1,9)
        % model.plot(false)   %debug
        %% 誤差確認
        if model.eveflg == 1
            % Apexに戻ってきていたら，一周したあとの状態変数誤差
            F_new(1) = model.q_err(1);
            F_new(2) = model.q_err(2);
            F_new(3) = model.q_err(3);
            F_new(4) = model.q_err(4);
            F_new(5) = model.q_err(6);
            F_new(6) = model.q_err(7);
        else
            % エラー起きたらとりあえず　全てに１を入れておく
            F_new = [1 1 1 1 1 1];
        end
    catch
        % エラー起きたらとりあえず　全てに１を入れておく
        F_new = [1 1 1 1 1 1];
    end

% return;
end

