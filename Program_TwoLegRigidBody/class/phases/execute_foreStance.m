function [terminalTime, terminalState, nextPhaseIndex, liftOffFlag] = execute_foreStance(model, tstart, q_ini, liftOffFlag)

    myEvent = @(t, q) events4(q, model); %イベント関数を定義．ゼロになる変数と方向を指定．
    myOde = @(t, q) f4(q, model); %odeで解く微分方程式を定義．
    options = odeset('RelTol', model.relval, 'AbsTol', model.absval, 'Events', myEvent, 'Refine', model.refine, 'Stats', 'off'); %ode45のオプションを設定．

    % ode45で微分方程式をとく
    clearvars t q te ie
    [tout, qout, te, qe, ie] = ode45(myOde, [tstart, model.tfinal], q_ini, options);

    % 次のフェーズを判定
    nextPhaseIndex = detectNextPhase(ie);
    
    % 結果を保存
    [terminalTime, terminalState] = accumulate(model, tout, qout, te, qe, ie);
    calc_touchDownPos(model, nextPhaseIndex);
    liftOffFlag = update_liftOffFlag(model, nextPhaseIndex, liftOffFlag);

end % execute_foreStance

function  nextPhaseIndex = detectNextPhase(ie)
    % どのイベントが起こったか？
    switch length(ie)
    case 0
        % disp('no event occured @phase4')
        nextPhaseIndex = 20;
    case 1
        if ie(1) == 1
            % disp('hind leg touch down @phase4')
            nextPhaseIndex = 3;
        elseif ie(1) == 2
            % disp('fore leg lift off @phase4')
            nextPhaseIndex = 1;
        elseif ie(1) == 3
            % disp('fall down @phase4')
            nextPhaseIndex = 30;
        else
            % disp('unknown error @phase4')
            nextPhaseIndex = 30;
        end

    case 2
        if ie(1) == 1 && ie(2) == 2
            % disp('hind leg touch down & fore leg lift off @phase4')
            nextPhaseIndex = 2;
        else
            % disp('fall down @phase4')
            nextPhaseIndex = 30;
        end

    case 3
        % disp('unknown error @phase4')
        nextPhaseIndex = 30;
    end
end % detectNextPhase

function [terminalTime, terminalState] = accumulate(model, tout, qout, te, qe, ie)

    nt = length(tout);
    
    model.tout = [model.tout; tout(2:nt)];
    model.qout = [model.qout; qout(2:nt, :)];

    theta = qout(2:nt, 3);
    xf = qout(2:nt, 1) + model.L * cos(theta);
    yf = qout(2:nt, 2) + model.L * sin(theta);

    Pf = model.xf_toe * ones(nt - 1, 1) - xf;
    Qf = 0 - yf;
    LBf = sqrt(Pf.^2 + Qf.^2);
    GBf = atan2(Pf, -Qf);

    model.lout = [model.lout; ones(nt - 1, 1) * model.lh, LBf];
    model.gout = [model.gout; ones(nt - 1, 1) * model.gamma_h_td, GBf];

    model.teout = [model.teout; te(1)];
    model.qeout = [model.qeout; qe(1, :)];
    model.ieout = [model.ieout; ie(1)];
    model.phaseout = [model.phaseout; ones(nt - 1, 1) * 3];

    terminalTime = tout(end);
    terminalState = qout(end,:);

end % accumulate

function calc_touchDownPos(model, nextPhaseIndex)
    if nextPhaseIndex == 2
        % 次はhind leg stance
        model.xh_toe = model.qout(end, 1) - model.L * cos(model.qout(end, 3)) + model.lout(end, 1) * sin(model.gout(end, 1));
    elseif nextPhaseIndex == 3
        % 次はDouble leg stance
        model.xh_toe = model.qout(end, 1) - model.L * cos(model.qout(end, 3)) + model.lout(end, 1) * sin(model.gout(end, 1));
    end
end % calc_touchDownPos

function liftOffFlag = update_liftOffFlag(model, nextPhaseIndex, liftOffFlag)
    if nextPhaseIndex == 1
        % fore lift off
        liftOffFlag.fore = true;
    elseif nextPhaseIndex == 2
        % fore lift off
        liftOffFlag.fore = true;
    end
end % update_liftOffFlag