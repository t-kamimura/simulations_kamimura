function logData = make_log(model, q_constants, u_fix, fsolveResult)

    logData = init_logData(q_constants,u_fix,fsolveResult);

    if fsolveResult.exitFlag > 0
        % 誤差最大のものを抜き出し，本当に固定点になっているか確認
        err = bound_once(model, q_constants, u_fix);
        maxError = max(abs(err));

        if maxError > 1e-5
            %たまに不動点でない点が見つかってしまう
            fprintf('x');
        end
        
        if model.phaseout(end) == 1
            % 床反力の計算
            % データ保存
            logData.trajectory.tout = model.tout;
            logData.trajectory.qout = model.qout;
            logData.event.teout = model.teout;
            logData.event.qeout = model.qeout;
            logData.event.ieout = model.ieout;
            logData.maxError = maxError;
            logData.GRF = model.GRF;
            logData.p = model.p;
        else
            logData.fsolveResult.exitFlag = -10; % エラー起きたらとりあえず exitFlag = -10 入れておく
        end

    end % if exitflag
    
end

function logData = init_logData(q_constants,u_fix,fsolveResult)
    % logDataの初期化
    logData.q_constants = q_constants;
    logData.u_fix = u_fix;
    logData.fsolveResult = fsolveResult;
    logData.trajectory.tout = [];
    logData.trajectory.qout = [];
    logData.event.teout = [];
    logData.event.qeout = [];
    logData.event.ieout = [];
    logData.maxError = [];
    logData.GRF = 0;
    logData.p = 0;
end