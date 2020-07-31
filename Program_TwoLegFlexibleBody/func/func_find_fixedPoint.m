% １周期のバウンド歩行の周期解を見つける関数
%

% 結果
%   u_fix       : [gb, gf] 指定されたポアンカレ断面上の状態量zで周期解を達成するための入力
%   logData     : 固定点の各種状態量の変化のログ
%   exitflag    : Newton法の収束状況 　正なら成功　負なら失敗           1

function [u_fix, logDat, exitflag] = func_find_fixedPoint(u_ini, model, q_constants)

    % 今回，解を探す関数の定義
    % 入力uを計算することになる
    myNewtonFunc = @(u) func_poincreMapBound(u, model, q_constants);

    % Newton法実行
%     options = optimset('Algorithm','levenberg-marquardt','Display','iter'); %debug
    options = optimset('Algorithm','levenberg-marquardt','Display','none');
    [u_fix, fval, exitflag, output, jacobi] = fsolve(myNewtonFunc, u_ini, options);

    % logDatの初期化
    logDat.q_constants = q_constants;
    logDat.q_ini = [];
    logDat.u_fix = u_fix;

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

    % logDataを得るために一度バウンド実行
    % disp('make Logdata')
    if exitflag > 0
        % 初期値代入
        x0 = 0.0;
        y0 = q_constants(1);
        theta0 = 0;
        phi0 = u_fix(3);
        dx0 = q_constants(2);
        dy0 = 0;
        dtheta0 = q_constants(3);
        dphi0 = 0;

        gb_ini = u_fix(1);
        gf_ini = u_fix(2);

        q_ini = [x0 y0 theta0 phi0 dx0 dy0 dtheta0 dphi0];
        u_ini = [gb_ini gf_ini];

        model.init
        model.bound(q_ini, u_ini)

        fprintf('*')
%         model.plot(false) % debug


        % 誤差最大のものを抜き出し，本当に固定点になっているか確認
        maxError = max(abs(model.q_err));
        if maxError > 1e-5
            %たまに不動点でない点が見つかってしまう
            % logDat.error.zmax
            disp('invalid fsolve! this is not fixed point...')
            model.eveflg = 100;
            

        end

        if model.eveflg == 1
            % 最大床反力の計算
            GRF = model.kh*(model.l3 - min(model.lout(:,1)));

            % 力積の計算
            p = 0;
            for i_t = 2:length(model.tout)
                p = p + model.kh*(model.l3 - model.lout(i_t,1))*cos(model.gout(i_t,1))*(model.tout(i_t)-model.tout(i_t-1));
            end

            % データ保存
            logDat.q_ini = q_ini;

            logDat.trajectory.tout = model.tout;
            logDat.trajectory.qout = model.qout;


            logDat.event.teout = model.teout;
            logDat.event.qeout = model.qeout;
            logDat.event.ieout = model.ieout;

            logDat.GRF = GRF;
            logDat.p = p;
        else
            exitflag = -10; % エラー起きたらとりあえず　exitFlag = -10 入れておく
        end

    end % if exitflag

end % function
