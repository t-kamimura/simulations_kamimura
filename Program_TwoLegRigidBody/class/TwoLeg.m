% 2脚モデルのクラス
% initial condition を与えると，「.bound」でバウンド歩容をしてくれます
% 便利な描画機能付き！

classdef TwoLeg < handle
    % プロパティは全てアクセス権限がpublicです．

    properties (SetAccess = public)
        % robotParamの定義(Poulakais2013より)
        m = 20.865; % 質量 [kg]
        J = 1.3;    % 胴体の慣性モーメント [kg m^2]
        kh = 7040;  % 後脚のバネ定数 [N/m]
        kf = 7040;  % 前脚のバネ定数 [N/m]
        L = 0.552/2;% 胴体の長さL[m](脚の付根から重心まで)
        l3 = 0.323; % 後脚の長さ[m]
        l4 = 0.323; % 前脚の長さ[m]
        g = 9.8;    % 重力加速度 [m/s^2]

        % 状態変数など
        q_ini = zeros(1, 6);
        gamma_h_td = 0;
        gamma_f_td = 0;
        lh = 0;
        lf = 0;
        xh_toe = 0;
        xf_toe = 0;
        E = 0;
        GRF = 0;
        p = 0;

        % 計算に必要なものたち
        % 時系列履歴
        tout = [];
        qout = [];
        lout = [];
        gout = [];
        Eout = [];
        phaseout = [];
        % イベント発生時履歴
        teout = [];
        qeout = [];
        ieout = [];

        q_err = [];
        q_err_max = 0;
        
        mileage = 0;
        v = 0;
        
        % ODE param
        % ode45のリトライ回数？？
        refine = 4;
        % 相対誤差
        relval = 1e-6; %(この値でないと同時接地を見抜けない)
        % 絶対誤差
        absval = 1e-6;
        % シミュレーション最大時間(ｓ)
        tfinal = 10;
    end

    methods

        function bound(self, q_initial, u_inital)

            % 初期値設定
            [tstart_, q_ini_, phaseIndex, liftOffFlag] = initialize_state(self, q_initial, u_inital);

            for i_phase = 1:6
                if liftOffFlag.fore == true && liftOffFlag.hind == true
                    % 前後肢がそれぞれ接地期を経た後，Apexに戻ったらポアンカレ断面
                    break
                end

                if phaseIndex > 9
                    % eveflgが大きい値をとったとき，ちゃんとイベント起こっていない．これ以上計算しても無駄なのでやめる．
                    % disp('fall down')
                    break
                end

                switch phaseIndex
                    case 1
                        % disp('flight')
                        [tstart_, q_ini_, phaseIndex] = execute_flight(self, tstart_, q_ini_);
                    case 2
                        % disp('hind stance')
                        [tstart_, q_ini_, phaseIndex, liftOffFlag] = execute_hindStance(self, tstart_, q_ini_, liftOffFlag);
                    case 3
                        % disp('double stance')
                        [tstart_, q_ini_, phaseIndex, liftOffFlag] = execute_doubleStance(self, tstart_, q_ini_, liftOffFlag);
                    case 4
                        % disp('fore stance')
                        [tstart_, q_ini_, phaseIndex, liftOffFlag] = execute_foreStance(self, tstart_, q_ini_, liftOffFlag);
                end % phaseIndex

            end % i_phase

            % Double Leg Flight (until apex height)
            if phaseIndex == 1
                % disp('flight')
                [~, ~, phaseIndex] = execute_flightToApex(self, tstart_, q_ini_);
            else
                % disp('not entered to 2nd flight')
                % disp(['phaseIndex = ', num2str(self.eveflg)])
            end

            % 最終処理
            calc_error(self,phaseIndex);
            calc_Energy(self);
            calc_GRF(self);
            
        end % bound

        function plot(self, saveFlag)

            % 状態量のグラフ
            plot_stateVariables(self.tout, self.qout, saveFlag);

            % 脚長と角度のグラフ
            plot_legStates(self.tout, self.lout, self.gout, saveFlag);

            % エネルギー
            plot_energy(self.tout, self.Eout, saveFlag);

        end % plot

        function anime(self, speed, saveFlag)
            movieOptions.FPS = 30;
            movieOptions.speed = speed;
            movieOptions.saveFlag = saveFlag;
            dt = speed / movieOptions.FPS; % [ms]

            % 時間を等間隔に修正
            teq = [self.tout(1) : dt : self.tout(end)]';
            trajectoryEq.qout = interp1(self.tout, self.qout, teq);
            trajectoryEq.lout = interp1(self.tout, self.lout, teq);
            trajectoryEq.gout = interp1(self.tout, self.gout, teq);

            %% 描画する各点を計算
            pointPos = calc_plotPoints(self,trajectoryEq);

            %% 動画を描写
            make_movie(teq, pointPos, movieOptions);

        end % anime

    end % methods

end
