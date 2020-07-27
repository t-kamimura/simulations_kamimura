% １周期のバウンド歩行を行う関数
%　　　ポアンカレ断面でシミュレーションを開始し，１周期運動させておわる．

function [z_new] = func_poincreMapBound(u, model, q_constants)
    
    % 初期値代入
    x0 = 0.0;
    y0 = q_constants(1);
    theta0 = 0;
    phi0 = q_constants(2);
    dx0 = q_constants(3);
    dy0 = 0;
    dtheta0 = q_constants(4);
    dphi0 = 0 ;

    gb_ini = u(1);
    gf_ini = u(2);

    q_ini = [x0 y0 theta0 phi0 dx0 dy0 dtheta0 dphi0];
    u_ini = [gb_ini gf_ini];
    

    head.x = x0 + model.L * cos(theta0) * cos(phi0) + model.D * cos(theta0 + phi0);
    head.y = y0 + model.L * cos(phi0) * sin(theta0) + model.D * sin(theta0 + phi0);
    hip.x = x0 - model.L * cos(theta0) * cos(phi0) - model.D * cos(theta0 - phi0);
    hip.y = y0 - model.L * cos(phi0) * sin(theta0) - model.D * sin(theta0 - phi0);

    toe_b.x = x0- model.L * cos(theta0) * cos(phi0) - model.D * cos(theta0 - phi0) + model.l3 * sin(gb_ini);
    toe_b.y = y0 - model.L * cos(phi0) * sin(theta0) - model.D * sin(theta0 - phi0) - model.l3 * cos(gb_ini);
    toe_f.x = x0 + model.L * cos(theta0) * cos(phi0) + model.D * cos(theta0 + phi0) + model.l4 * sin(gf_ini);
    toe_f.y = y0 + model.L * cos(phi0) * sin(theta0) + model.D * sin(theta0 + phi0) - model.l4 * cos(gf_ini);

    toe_b.x = hip.x + model.l3*sin(gb_ini);
    toe_b.y = hip.y - model.l3*cos(gb_ini);
    toe_f.x = head.x + model.l4*sin(gf_ini);
    toe_f.y = head.y - model.l4*cos(gf_ini);
    
    cla
    line([head.x hip.x],[head.y, hip.y],'color','k')
    line([hip.x toe_b.x],[hip.y toe_b.y])
    line([head.x toe_f.x],[head.y toe_f.y])
    xlim([-0.8 0.8])
    ylim([0.2 1.5])
    drawnow
    
    model.init
    try
        model.bound(q_ini, u_ini)
%         model.plot(false)   %debug
        %% 誤差確認
        if model.eveflg == 1
            % Apexに戻ってきていたら，一周したあとの状態変数誤差
            z_new(1) = model.q_err(1);
            z_new(2) = model.q_err(3);
            z_new(3) = model.q_err(4);
            z_new(4) = model.q_err(6);
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

