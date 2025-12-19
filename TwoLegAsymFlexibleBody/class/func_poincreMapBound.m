% 1周期のバウンド歩行を行う関数
% ポアンカレ断面でシミュレーションを開始し，1周期だけ運動させておわる．

function [z_new] = func_poincreMapBound(z, model)

    % 初期値代入
    x0 = 0.0;
    y0 = z(1);
    theta0 = 0;
    phi0 = z(2);
    dx0 = z(3);
    dy0 = 0;
    dtheta0 = z(4);
    dphi0 = 0;

    gb_ini = z(5);
    gf_ini = z(6);

    q_ini = [x0 y0 theta0 phi0 dx0 dy0 dtheta0 dphi0];
    u_ini = [gb_ini gf_ini];

    model.kappa = z(7);

    % % 描画用

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
    % hindLeg = line([hip.x toe_b.x],[hip.y toe_b.y],'color','r');
    % foreLeg = line([head.x toe_f.x],[head.y toe_f.y],'color','b');
    % xlim([-0.8 0.8])
    % ylim([-0.2 1.5])
    % drawnow
    
    model.init(0);
    try
        model.bound(q_ini, u_ini);
        % 誤差確認
        if model.eveflg == 1
            % Apexに戻ってきていたら，一周したあとの状態変数誤差
            z_new(1) = model.q_err(1);
            z_new(2) = model.q_err(2);
            z_new(3) = model.q_err(3);
            z_new(4) = model.q_err(4);
            z_new(5) = model.q_err(6);
            z_new(6) = model.q_err(7);
            z_new(7) = sin(model.omega*model.tout(end)); % kappaの制約条件．ちょうどｎ周期で戻ってくるようにする
        else
            % エラー起きたらとりあえず　全てに１を入れておく
            z_new = ones(1,7);
        end
    catch
        % エラー起きたらとりあえず　全てに１を入れておく
        % disp("Error in func_poincreMapBound")
        z_new = ones(1,7);
    end

end

