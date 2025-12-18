% 1周期のバウンド歩行の周期解を見つける関数
function [z_fix, logDat, exitflag] = func_find_fixedPoint(z_ini, model)

    % 今回，解を探す関数の定義
    myNewtonFunc = @(u) func_poincreMapBound(u, model);

    % Newton法実行
    % options = optimset('Algorithm','levenberg-marquardt','Display','iter'); % debug
    pool = gcp('nocreate');
    if isempty(pool)
        options = optimset('Algorithm','levenberg-marquardt','Display','none'); % 並列なし
    else
        options = optimset('Algorithm','levenberg-marquardt','Display','none','UseParallel',true);
    end
    [z_fix, fval, exitflag, output, jacobi] = fsolve(myNewtonFunc, z_ini, options);
    
    % 初期値代入
    x0 = 0.0;
    y0 = z_fix(1);
    theta0 = 0;
    phi0 = z_fix(2);
    dx0 = z_fix(3);
    dy0 = 0;
    dtheta0 = z_fix(4);
    dphi0 = 0 ;

    gb_ini = z_fix(5);
    gf_ini = z_fix(6);

    q_ini = [x0 y0 theta0 phi0 dx0 dy0 dtheta0 dphi0];
    u_ini = [gb_ini gf_ini];


    % logDat.exitflag = exitflag; % debug

    logDat.omega0 = model.omega0;
    logDat.c = model.c;

    logDat.q_ini = q_ini;
    logDat.u_fix = u_ini;

    % model.init(0);
    % model.bound(q_ini, u_ini)

    % logDat.trajectory.tout = model.tout;
    % logDat.trajectory.qout = model.qout;

    % logDat.event.teout = model.teout;
    % logDat.event.qeout = model.qeout;
    % logDat.event.ieout = model.ieout;

    logDat.fsolveResult.fval = fval;
    logDat.fsolveResult.exitflag = exitflag;
    logDat.fsolveResult.output = output;
    logDat.fsolveResult.jacobi = jacobi;

    if exitflag == 1

        % 固定点の安定性解析
        [eigenValues, eivenVectors, jacobi] = calc_eigenvalue(model, q_ini, u_ini);
        maxEigen = max(abs(diag(eigenValues)));

        % 最大床反力の計算
        GRF = model.kh*(model.l3 - min(model.lout(:,1)));

        % 力積の計算
        p = 0;
        for i_t = 2:length(model.tout)
            p = p + model.kh*(model.l3 - model.lout(i_t,1))*cos(model.gout(i_t,1))*(model.tout(i_t)-model.tout(i_t-1));
        end

        if maxEigen < 1
            logDat.stability.isStable = true;
        else
            logDat.stability.isStable = false;
        end
        logDat.stability.jacobi = jacobi;
        logDat.stability.eigenVectors = eivenVectors;
        logDat.stability.eigenValues = eigenValues;
        logDat.stability.maxEigen = maxEigen;
        logDat.GRF = GRF;
        logDat.p = p;
    else
        logDat.stability.isStable = [];
        logDat.stability.jacobi = [];
        logDat.stability.eigenVectors = [];
        logDat.stability.eigenValues = [];
        logDat.stability.maxEigen = [];
        logDat.GRF = [];
        logDat.p = [];
    end % if exitflag

end % function
