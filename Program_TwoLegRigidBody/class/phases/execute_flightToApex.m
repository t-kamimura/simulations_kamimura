function [terminalTime, terminalState, nextPhaseIndex] = execute_flightToApex(model, tstart, q_ini)

    % ode45で微分方程式を解く準備
    myEvent = @(t, q) events5(q, model); % イベント関数を定義．ゼロになる変数と方向を指定．
    myOde = @(t, q) f1(q, model); % odeで解く微分方程式を定義．
    options = odeset('RelTol', model.relval, 'AbsTol', model.absval, 'Events', myEvent, 'Refine', model.refine, 'Stats', 'off'); %ode45のオプションを設定．

    % ode45で微分方程式を解く
    [tout, qout, te, qe, ie] = ode45(myOde, [tstart model.tfinal], q_ini, options);

    % 結果を保存
    [terminalTime, terminalState] = accumulate(model, tout, qout, te, qe, ie);
    nextPhaseIndex = detectNextPhase(ie);

end % execute_flight

function nextPhaseIndex = detectNextPhase(ie)
    
    % どのイベントが起こったか？
    switch length(ie)
    case 0
        % どのイベントも発生していない
        % disp('no event occured @flight')
        nextPhaseIndex = 20;
    case 1
        % 単一のイベントが発生
        if ie(1) == 1
            % disp('Apex @flight')
            nextPhaseIndex = 1;
        elseif ie(1) == 2
            % disp('hind leg touch down @flight')
            nextPhaseIndex = 2;
        elseif ie(1) == 3
            % disp('fore leg touch down @flight')
            nextPhaseIndex = 4;
        elseif ie(1) == 4
            % disp('fall down @flight')
            nextPhaseIndex = 30;
        else
            % disp('unknown error @flight')
            nextPhaseIndex = 30;
        end

    case 2
        % 同時に2個のイベントが発生
        if ie(1) == 1 && ie(2) == 2
            % disp('apex & hind leg touch down @flight')
            nextPhaseIndex = 2;
        elseif ie(1) == 1 && ie(2) == 3
            % disp('apex & fore leg touch down @flight')
            nextPhaseIndex = 4;
        elseif ie(1) == 2 && ie(2) == 3
            % disp('hind & fore leg touch down @flight')
            nextPhaseIndex = 3;
        else
            % disp('fall down @flight')
            nextPhaseIndex = 30;
        end

    case 3
        % disp('unknown error @flight')
        nextPhaseIndex = 30;
    end

end % detectNextPhase

function [terminalTime, terminalState] = accumulate(model, tout, qout, te, qe, ie)

    nt = length(tout);

    model.tout = [model.tout; tout(2:nt)];
    model.qout = [model.qout; qout(2:nt, :)];

    model.lout = [model.lout; ones(nt - 1, 1) * model.l3, ones(nt - 1, 1) * model.l4];
    model.gout = [model.gout; ones(nt - 1, 1) * model.gamma_h_td(1), ones(nt - 1, 1) * model.gamma_f_td(1)];

    model.teout = [model.teout; te(1)];
    model.qeout = [model.qeout; qe(1, :)];
    model.ieout = [model.ieout; ie(1)];

    model.phaseout = [model.phaseout; ones(nt - 1, 1) * 1];

    terminalTime = tout(end);
    terminalState = qout(end,:);

end
