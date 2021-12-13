function [terminalTime, terminalState, nextPhaseIndex, liftOffFlag] = execute_doubleStance(model, tstart, q_ini, liftOffFlag)

    % ode45で微分方程式を解く準備
    myEvent = @(t, q) events3(q, model); % イベント関数を定義．ゼロになる変数と方向を指定．
    myOde = @(t, q) f3(q, model); % odeで解く微分方程式を定義．
    options = odeset('RelTol', model.relval, 'AbsTol', model.absval, 'Events', myEvent, 'Refine', model.refine, 'Stats', 'off'); %ode45のオプションを設定．

    % ode45で微分方程式をとく
    [tout, qout, te, qe, ie] = ode45(myOde, [tstart, model.tfinal], q_ini, options);
    
    % 結果を保存
    [terminalTime, terminalState] = accumulate(model, tout, qout, te, qe, ie);
    nextPhaseIndex = detectNextPhase(ie);
    liftOffFlag = update_liftOffFlag(nextPhaseIndex, liftOffFlag);

end % execute_doubleStance

function  nextPhaseIndex = detectNextPhase(ie)
    % どのイベントが起こったか？
    switch length(ie)
    case 0
        % disp('no event occured @phase3')
        nextPhaseIndex = 20;
    case 1

        if ie(1) == 1
            % disp('hind leg lift off @phase3')
            nextPhaseIndex = 4;
        elseif ie(1) == 2
            % disp('fore leg lift off @phase3')
            nextPhaseIndex = 2;
        elseif ie(1) == 3
            % disp('fall down @phase3')
            nextPhaseIndex = 30;
        else
            % disp('unknown error @phase3')
            nextPhaseIndex = 30;
        end

    case 2

        if ie(1) == 1 && ie(2) == 2
            % disp('fore & hind leg lift off @phase3')
            nextPhaseIndex = 1;
        else
            % disp('fall down @phase3')
            nextPhaseIndex = 30;
        end

    case 3
        % disp('unkown error@phase3')
        nextPhaseIndex = 30;
    end 
end % detectNextPhase

function [terminalTime, terminalState] = accumulate(model, tout, qout, te, qe, ie)

    nt = length(tout);
    
    model.tout = [model.tout; tout(2:nt)];
    model.qout = [model.qout; qout(2:nt, :)];

    theta = qout(2:nt, 3);
    xb = qout(2:nt, 1) - model.L * cos(theta);
    yb = qout(2:nt, 2) - model.L * sin(theta);
    xf = qout(2:nt, 1) + model.L * cos(theta);
    yf = qout(2:nt, 2) + model.L * sin(theta);

    Pb = model.xh_toe * ones(nt - 1, 1) - xb;
    Qb = 0 - yb;
    LBb = sqrt(Pb.^2 + Qb.^2);
    GBb = atan2(Pb, -Qb);
    Pf = model.xf_toe * ones(nt - 1, 1) - xf;
    Qf = 0 - yf;
    LBf = sqrt(Pf.^2 + Qf.^2);
    GBf = atan2(Pf, -Qf);

    model.lout = [model.lout; LBb, LBf];
    model.gout = [model.gout; GBb, GBf];

    model.teout = [model.teout; te(1)];
    model.qeout = [model.qeout; qe(1, :)];
    model.ieout = [model.ieout; ie(1)];

    model.phaseout = [model.phaseout; ones(nt - 1, 1) * 4];

    terminalTime = tout(end);
    terminalState = qout(end,:);
end % accumulate

function liftOffFlag = update_liftOffFlag(nextPhaseIndex, liftOffFlag)
    if nextPhaseIndex == 1
        % 次はFlight
        liftOffFlag.hind = true;
        liftOffFlag.fore = true;
    elseif nextPhaseIndex == 2
        % 次はHind leg stance
        liftOffFlag.fore = true;
    elseif nextPhaseIndex == 4
        % 次はFore leg stance
        liftOffFlag.hind = true;
    end
end % update_liftOffFlag