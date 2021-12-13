% filename: execute_hindStance
% function: numerical integration of hind stance phase
% argument: time & state variables & model parameter

function [terminalTime, terminalState, nextPhaseIndex, liftOffFlag] = execute_hindStance(model, tstart, q_ini, liftOffFlag)

    myEvent = @(t, q) events2(q, model); %イベント関数を定義．ゼロになる変数と方向を指定．
    myOde = @(t, q) f2(q, model); %odeで解く微分方程式を定義．
    options = odeset('RelTol', model.relval, 'AbsTol', model.absval, 'Events', myEvent, 'Refine', model.refine, 'Stats', 'off'); %ode45のオプションを設定．

    % ode45で微分方程式をとく
    [tout, qout, te, qe, ie] = ode45(myOde, [tstart, model.tfinal], q_ini, options);

    % 次のフェーズを判定
    nextPhaseIndex = detectNextPhase(ie);
    
    % 結果を保存
    [terminalTime, terminalState] = accumulate(model, tout, qout, te, qe, ie);
    calc_touchDownPos(model, nextPhaseIndex);
    liftOffFlag = update_liftOffFlag(model, nextPhaseIndex, liftOffFlag);

end % execute_hindStance

function  nextPhaseIndex = detectNextPhase(ie)
    % どのイベントが起こったか？
    switch length(ie)
    case 0
        % disp('no event occured @hindStance')
        nextPhaseIndex = 20;
    case 1

        if ie(1) == 1
            % disp('fore leg touch down @hindStance')
            nextPhaseIndex = 3;
        elseif ie(1) == 2
            % disp('hind leg lift off @hindStance')
            nextPhaseIndex = 1;
        elseif ie(1) == 3
            % disp('fall down @hindStance')
            nextPhaseIndex = 30;
        else
            % disp('unknown error @hindStance')
            nextPhaseIndex = 30;
        end

    case 2

        if ie(1) == 1 && ie(2) == 2
            % disp('fore leg touch down & hind leg lift off@hindStance')
            nextPhaseIndex = 4;
        else
            % disp('fall down @hindStance')
            nextPhaseIndex = 30;
        end

    case 3
        % disp('unknown error@hindStance')
        nextPhaseIndex = 30;
    end
end %detectNextPhase

function [terminalTime, terminalState] = accumulate(model, tout, qout, te, qe, ie)

    nt = length(tout);
    
    model.tout = [model.tout; tout(2:nt)];
    model.qout = [model.qout; qout(2:nt, :)];

    theta = qout(2:nt, 3);
    xb = qout(2:nt, 1) - model.L * cos(theta);
    yb = qout(2:nt, 2) - model.L * sin(theta);

    Pb = model.xh_toe * ones(nt - 1, 1) - xb;
    Qb = 0 - yb;
    LBb = sqrt(Pb.^2 + Qb.^2);
    GBb = atan2(Pb, -Qb);
    
    model.lout = [model.lout; LBb, ones(nt - 1, 1) * model.lf];
    model.gout = [model.gout; GBb, ones(nt - 1, 1) * model.gamma_f_td];

    model.teout = [model.teout; te(1)];
    model.qeout = [model.qeout; qe(1, :)];
    model.ieout = [model.ieout; ie(1)];

    model.phaseout = [model.phaseout; ones(nt - 1, 1) * 2];

    terminalTime = tout(end);
    terminalState = qout(end,:);

end % accumulate

function calc_touchDownPos(model, nextPhaseIndex)
    if nextPhaseIndex == 3
        % 次はDouble leg stance
        model.xf_toe = model.qout(end, 1) + model.L * cos(model.qout(end, 3)) + model.lout(end, 2) * sin(model.gout(end, 2));
    elseif nextPhaseIndex == 4
        % 次はFore leg stance
        model.xf_toe = model.qout(end, 1) + model.L * cos(model.qout(end, 3)) + model.lout(end, 2) * sin(model.gout(end, 2));
    end
end % calc_touchDownPos

function liftOffFlag = update_liftOffFlag(model, nextPhaseIndex, liftOffFlag)
    if nextPhaseIndex == 1
        % 次はFlight
        liftOffFlag.hind = true;
    elseif nextPhaseIndex == 4
        % 次はFore leg stance
        liftOffFlag.hind = true;
    end
end % update_liftOffFlag