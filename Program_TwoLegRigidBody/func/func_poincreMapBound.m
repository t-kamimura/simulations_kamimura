% １周期のバウンド歩行を行う関数
%　　　ポアンカレ断面でシミュレーションを開始し，１周期運動させておわる．

function [z_new] = func_poincreMapBound(u, model, q_constants)
    
    % 初期値代入
    x0 = 0.0;
    y0 = q_constants(1);
    theta0 = 0;
    dx0 = q_constants(2);
    dy0 = 0;
    dtheta0 = q_constants(3);

    gb_ini = u(1);
    gf_ini = u(2);

    q_ini = [x0 y0 theta0 dx0 dy0 dtheta0];
    u_ini = [gb_ini gf_ini];
    
    head.x = x0 + model.L*cos(theta0);
    head.y = y0 + model.L*sin(theta0);
    hip.x = x0 - model.L*cos(theta0);
    hip.y = y0 - model.L*sin(theta0);

    toe_b.x = hip.x + model.l3*sin(gb_ini);
    toe_b.y = hip.y - model.l3*cos(gb_ini);
    toe_f.x = head.x + model.l4*sin(gf_ini);
    toe_f.y = head.y - model.l4*cos(gf_ini);
    
    cla
    line([head.x hip.x],[head.y, hip.y],'color','k')
    line([hip.x toe_b.x],[hip.y toe_b.y])
    line([head.x toe_f.x],[head.y toe_f.y])
    xlim([-0.4 0.4])
    ylim([-0.2 0.6])
    drawnow
    
    model.init
    try
        model.bound(q_ini, u_ini)
%         model.plot(false)   %debug
        %% 誤差確認
        if model.eveflg == 1
            % Apexに戻ってきていたら，一周したあとの状態変数誤差
            z_new(1) = model.q_err(1);
            z_new(2) = model.q_err(2);
            z_new(3) = model.q_err(3);
            z_new(4) = model.q_err(5);
        else
            % エラー起きたらとりあえず　全てに１を入れておく
            z_new = [1 1 1 1];
        end
    catch
        % エラー起きたらとりあえず　全てに１を入れておく
        z_new = [1 1 1 1];
    end

% return;
end

