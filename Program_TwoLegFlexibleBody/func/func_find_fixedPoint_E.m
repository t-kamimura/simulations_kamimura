% １周期のバウンド歩行の周期解を見つける関数
%

% 結果
%   u_fix       : [gb, gf] 指定されたポアンカレ断面上の状態量zで周期解を達成するための入力
%   logData     : 固定点の各種状態量の変化のログ
%   exitflag    : Newton法の収束状況 　正なら成功　負なら失敗           1

function [z_fix, logDat, exitflag] = func_find_fixedPoint_E(model, z_ini, u_ini)

    % 今回，解を探す関数の定義
    % z_ini = [phi0 gb_ini gf_ini];     % 今回のループで求める周期解の探索部分
    % u_ini = [y0 dtheta0 E0];          % 今回のループで求める周期解の定数（固定）部分

    myNewtonFunc = @(z) func_poincreMapBound_E(model, z, u_ini);

    % Newton法実行
%     options = optimset('Algorithm','levenberg-marquardt','Display','iter'); %debug
    options = optimset('Algorithm','levenberg-marquardt','Display','none','UseParallel',true);
    [z_fix, fval, exitflag, output, jacobi] = fsolve(myNewtonFunc, z_ini, options);

    % logDatの初期化
    logDat.z_fix = z_fix;
    logDat.u_fix = u_ini;
    logDat.q_ini = [];

    logDat.fsolveResult.fval = fval;
    logDat.fsolveResult.exitflag = exitflag;
    logDat.fsolveResult.output = output;
    logDat.fsolveResult.jacobi = jacobi;

    logDat.trajectory.tout = [];
    logDat.trajectory.qout = [];

    logDat.event.teout = [];
    logDat.event.qeout = [];
    logDat.event.ieout = [];

    logDat.error.q_err = [];
    logDat.error.q_err_max = [];

    logDat.GRF = 0;
    logDat.p = 0;
    logDat.E = u_ini(3);

    % logDataを得るために一度バウンド実行
    % disp('make Logdata')
    if exitflag > 0

        % z_fix = [phi0 gb_ini gf_ini];     % 今回のループで求める周期解の探索部分
        % u_ini = [y0 dtheta0 E0];          % 今回のループで求める周期解の定数（固定）部分
        % 初期値代入
        x0 = 0.0;
        y0 = u_ini(1);
        theta0 = 0;
        phi0 = z_fix(1);
        dx0 = 0;
        dy0 = 0;
        dtheta0 = u_ini(2);
        dphi0 = 0;

        % エネルギーから初期速度を求める
        % M1 = 2 * model.m;
        M2 = 2 * model.m;
        M3 = 2 * model.J + 2 * model.m * model.L * (cos(phi0))^2;
        % M4 = 2 * model.J + 2 * model.m * model.L * (sin(phi0))^2;
        T = 0.5  * (M2*dy0^2 + M3*dtheta0^2);
        U = 2 * model.m * model.g* y0 + 0.5 * model.kt * phi0^2;

        dx0 = sqrt((u_ini(3) - T - U)/model.m);

        gb_ini = z_fix(2);
        gf_ini = z_fix(3);

        q_ini = [x0 y0 theta0 phi0 dx0 dy0 dtheta0 dphi0];
        tdAngle = [gb_ini gf_ini];

        model.init
        model.bound(q_ini, tdAngle)

        % fprintf('*')
%         model.plot(false) % debug


        % 誤差最大のものを抜き出し，本当に固定点になっているか確認
        maxError = max(abs(model.q_err));
        if maxError > 1e-5
            %たまに不動点でない点が見つかってしまう
            % logDat.error.zmax
            % disp('invalid fsolve! this is not fixed point...')
            fprintf('x')
            model.eveflg = 100;
        end

        if model.eveflg == 1
            % 最大床反力の計算
            GRF = model.kh * (model.l3 - min(model.lout(:,1)));

            % 力積の計算
            p = 0;
            for i_t = 2:length(model.tout)
                p = p + model.kh * (model.l3 - model.lout(i_t,1))*cos(model.gout(i_t,1))*(model.tout(i_t)-model.tout(i_t-1));
            end

            % データ保存
            logDat.q_ini = q_ini;

            logDat.trajectory.tout = model.tout;
            logDat.trajectory.qout = model.qout;

            logDat.event.teout = model.teout;
            logDat.event.qeout = model.qeout;
            logDat.event.ieout = model.ieout;

            logDat.error.q_err = model.q_err;
            logDat.error.q_err_max = model.q_err_max;

            logDat.GRF = GRF;
            logDat.p = p;
            logDat.E = model.Eout(1,9);
        else
            exitflag = -10; % エラー起きたらとりあえず　exitFlag = -10 入れておく
        end

    end % if exitflag

end % function
