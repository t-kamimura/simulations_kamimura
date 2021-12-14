function err = bound_once(model,q_constants,u)
    % 初期値代入
    x0   = 0.0;
    y0   = q_constants(1);
    th0  = 0;
    dx0  = q_constants(2);
    dy0  = 0;
    dth0 = q_constants(3);

    q_ini = [x0 y0 th0 dx0 dy0 dth0];

    draw_current_states(model,q_ini,u);

    model.bound(q_ini, u)
    if model.phaseout(end) == 1
        % Apexに戻ってきていたら，一周したあとの状態変数誤差
        err(1) = model.q_err(1);
        err(2) = model.q_err(2);
        err(3) = model.q_err(3);
        err(4) = model.q_err(5);
    else
        % エラー起きたらとりあえず全てに１を入れておく
        err = [1 1 1 1];
    end
end % bound_once

function draw_current_states(model,q_ini,u)
    x0  = q_ini(1);
    y0  = q_ini(2);
    th0 = q_ini(3);
    head.x = x0 + model.L*cos(th0);
    head.y = y0 + model.L*sin(th0);
    hip.x  = x0 - model.L*cos(th0);
    hip.y  = y0 - model.L*sin(th0);

    gh = u(1);
    gf = u(2);
    toe_b.x = hip.x  + model.l3*sin(gh);
    toe_b.y = hip.y  - model.l3*cos(gh);
    toe_f.x = head.x + model.l4*sin(gf);
    toe_f.y = head.y - model.l4*cos(gf);

    cla
    line([head.x hip.x],[head.y, hip.y],'color','k')
    line([hip.x toe_b.x],[hip.y toe_b.y])
    line([head.x toe_f.x],[head.y toe_f.y])
    xlim([-0.4 0.4])
    ylim([-0.2 0.6])
    drawnow
end %draw_current_states