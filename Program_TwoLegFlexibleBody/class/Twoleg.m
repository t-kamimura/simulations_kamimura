classdef Twoleg < handle
    % 2脚モデルのクラス
    % initial condition を与えると，「.bound」でバウンド歩容をしてくれます
    % 便利な描画機能付き！

    % プロパティは全てアクセス権限がpublicです．

    %=====================================================================%
    % Methods
    %=====================================================================%
    % init
    % データ格納変数を全てクリアしてくれます．boundする前に必ず行うこと
    %=====================================================================%
    % bound
    % バウンドしてくれます．
    %=====================================================================%
    % plot
    % データをプロットする
    %=====================================================================%
    % anime
    % 動きのアニメーションを作る．
    %=====================================================================%

    properties (SetAccess = public)
        % チーターParamの定義( 上村先生論文より)
        % 慣性モーメント [kg m^2]
        J = 0.53; %後胴体の慣性モーメント

        % 質量m [kg]
        m = 18.8;

        % ばね定数k_leg [N / m]
%         kh = 20000; %後脚のバネ定数
%         kf = 20000; %前脚のバネ定数
%         kt = 150; %ジョイント部分バネ定数
        kh = 15000; %後脚のバネ定数
        kf = 15000; %前脚のバネ定数
        kt = 100; %ジョイント部分バネ定数

        % 減衰定数 [Ns / m]
        c = 0;

        %  胴体の長さl[m](脚の付根から重心まで)
        L = 0.29;
        D = 0.06; %脚の付け根までの長さ(GRF位置ではなく実測値)
%         D = -0.06;  % 20210607マイナスにしてみる

        % 足のばねの自然帳l_0[m]
        l3 = 0.685; %後脚の長さ
        l4 = 0.685; %前脚の長さ

        % 重力加速度 [m/s^2]
        g = 9.8;

        % 状態変数など
        q_ini = zeros(1, 8);
        gamma_h_td = 0;
        gamma_f_td = 0;
        lh = 0;
        lf = 0;
        xh_toe = 0;
        xf_toe = 0;
        E = 0;

        % 計算に必要なものたち
        eveflg = 1;

        tout = [];
        qout = [];
        lout = [];
        gout = [];


        teout = [];
        qeout = [];
        ieout = [];
        eeout = [];
        eveflgout = [];

        Hipout = [];
        Toeout = [];
        q_err = [];
        q_err_max = 0;
        mileage = 0;
        v = 0;
        tstart = 0;
        Eout = [];

        % ODE param
        % ode45　のリトライ回数？？
        refine = 4;
        % 相対誤差
        relval = 1e-12;
        % 絶対誤差
        absval = 1e-12;
        % シミュレーション最大時間(ｓ)
        tfinal = 10;
    end

    methods

        function init(self)
            self.eveflg = 1;

            self.tout = [];
            self.qout = [];
            self.gout = [];
            self.lout = [];


            self.teout = [];
            self.qeout = [];
            self.ieout = [];
            self.eeout = [];
            self.eveflgout = [];

            self.Hipout = [];
            self.Toeout = [];
            self.tstart = 0;
        end % init

        function bound(self, q_initial, u_inital)
            %disp('Bound Start')

            self.q_ini = q_initial;
            self.gamma_h_td = u_inital(1);
            self.gamma_f_td = u_inital(2);

            qe = self.q_ini;
            self.lh = self.l3;
            self.lf = self.l4;

            % 初期値おかしかったとき
            y_ini = q_initial(2);
            if y_ini < 0
                self.eveflg = 22;
            end

            liftOffFlag.hind = false;
            liftOffFlag.fore = false;

            for i_phase = 1:6

                if liftOffFlag.fore == true && liftOffFlag.hind == true
                    break
                end

                if self.eveflg > 9
                    % eveflgが大きい値をとったとき，ちゃんとイベント起こっていない．これ以上計算しても無駄なのでやめる．
                    % disp('fall down')
                    break
                end

                % eveflgの値によって，スイッチする
                %  1 Double leg Flight
                %  2 Hind   leg Stance
                %  3 Double leg Stance
                %  4 Fore   leg Stance

                % ode45は微分方程式のソルバー
                % [T, Q, TE, QE, IE] = ode45(odefun,tspan,q0,options)
                % odefun  微分方程式の右辺を計算する．dq=f(t,q)の形の微分方程式．
                % tspan   積分区間[t0,tf]を指定するベクトル．
                % q0      初期条件のベクトル
                % options 関数odesetで作られるオプション．
                % T       時刻の列ベクトル
                % Q       解の配列．Yの各行は，Tの対応する行に返される時刻での解．
                % TE      イベントが発生した時刻
                % QE      イベント時刻での解
                % IE      ゼロになるイベント関数のインデックス

                switch self.eveflg

                    case 1% Double Leg Flight

                        eve1 = @(t, q) events1(q, self); %イベント関数を定義．ゼロになる変数と方向を指定．
                        ode1 = @(t, q) f1(q, self); %odeで解く微分方程式を定義．
                        options1 = odeset('RelTol', self.relval, 'AbsTol', self.absval, 'Events', eve1, 'Refine', self.refine, 'Stats', 'off'); %ode45のオプションを設定．

                        % ode45で微分方程式をとく
                        clearvars t q te ie
                        [t, q, te, qe, ie] = ode45(ode1, [self.tstart self.tfinal], qe(1, :), options1);

                        % 結果を保存とeveflg書き換え．
                        self = Accumulate01(t, q, te, qe, ie, self);

                        % 次のステップに渡す初期値を作る．時間と接地した脚先の位置．
                        self.tstart = t(end);

                        if self.eveflg == 2
                            % 次はhind leg stance
                            self.xh_toe = self.qout(end, 1) - self.L * cos(self.qout(end, 4)) * cos(self.qout(end,3))  - self.D * cos(self.qout(end, 3) - self.qout(end, 4)) + self.lout(end, 1) * sin(self.gout(end, 1));
                        elseif  self.eveflg == 3
                            % 次はDouble leg stance
                            self.xh_toe = self.qout(end, 1) - self.L * cos(self.qout(end, 4)) * cos(self.qout(end,3))  - self.D * cos(self.qout(end, 3) - self.qout(end, 4)) + self.lout(end, 1) * sin(self.gout(end, 1)); %hind

                            self.xf_toe = self.qout(end, 1) + self.L * cos(self.qout(end, 4)) * cos(self.qout(end, 3)) + self.D * cos(self.qout(end, 3) + self.qout(end, 4)) + self.lout(end, 2) * sin(self.gout(end, 2)); % fore
                        elseif self.eveflg == 4
                            % 次はFore leg stance
                            self.xf_toe = self.qout(end, 1) + self.L * cos(self.qout(end, 4)) * cos(self.qout(end, 3)) + self.D * cos(self.qout(end, 3) + self.qout(end, 4)) + self.lout(end, 2) * sin(self.gout(end, 2));
                        end


                    case 2 % Hind leg stance
                        eve2 = @(t, q) events2(q, self); %イベント関数を定義．ゼロになる変数と方向を指定．
                        ode2 = @(t, q) f2(q, self); %odeで解く微分方程式を定義．
                        options2 = odeset('RelTol', self.relval, 'AbsTol', self.absval, 'Events', eve2, 'Refine', self.refine, 'Stats', 'off'); %ode45のオプションを設定．

                        % ode45で微分方程式をとく
                        clearvars t q te ie
                        [t, y, te, qe, ie] = ode45(ode2, [self.tstart, self.tfinal], qe(1, :), options2);

                        % 結果を保存とeveflg書き換え．
                        self = Accumulate02(t, y, te, qe, ie, self);

                        % 次のステップに渡す初期値を作る．時間と接地した脚先の位置．
                        self.tstart = t(end);

                        if self.eveflg == 1
                            %次はFlight
                            liftOffFlag.hind = true;
                        elseif self.eveflg == 3
                            % 次はDouble leg stance
                            self.xf_toe = self.qout(end, 1) + self.L * cos(self.qout(end, 4)) * cos(self.qout(end, 3)) + self.D * cos(self.qout(end, 3) + self.qout(end, 4)) + self.lout(end, 2) * sin(self.gout(end, 2));
                        elseif self.eveflg == 4
                            % 次はFore leg stance
                            self.xf_toe = self.qout(end, 1) + self.L * cos(self.qout(end, 4)) * cos(self.qout(end, 3)) + self.D * cos(self.qout(end, 3) + self.qout(end, 4)) + self.lout(end, 2) * sin(self.gout(end, 2));
                            liftOffFlag.hind = true;
                        end

                    case 3 % Double leg stance
                        eve3 = @(t, q) events3(q, self); %イベント関数を定義．ゼロになる変数と方向を指定．
                        ode3 = @(t, q) f3(q, self); %odeで解く微分方程式を定義．
                        options3 = odeset('RelTol', self.relval, 'AbsTol', self.absval, 'Events', eve3, 'Refine', self.refine, 'Stats', 'off'); %ode45のオプションを設定．
                        % ode45で微分方程式をとく
                        clearvars t q te ie
                        [t, q, te, qe, ie] = ode45(ode3, [self.tstart, self.tfinal], qe(1, :), options3);
                        % 結果を保存とeveflg書き換え．
                        self = Accumulate03(t, q, te, qe, ie, self);
                        self.tstart = t(end);

                        if self.eveflg == 1
                            % 次はFlight
                            liftOffFlag.hind = true;
                            liftOffFlag.fore = true;
                        elseif self.eveflg == 2
                            % 次はHind leg stance
                            liftOffFlag.fore = true;
                        elseif self.eveflg == 4
                            % 次はFore leg stance
                            liftOffFlag.hind = true;
                        end

                    case 4% Fore leg stance
                        eve4 = @(t, q) events4(q, self); %イベント関数を定義．ゼロになる変数と方向を指定．
                        ode4 = @(t, q) f4(q, self); %odeで解く微分方程式を定義．
                        options4 = odeset('RelTol', self.relval, 'AbsTol', self.absval, 'Events', eve4, 'Refine', self.refine, 'Stats', 'off'); %ode45のオプションを設定．
                        % ode45で微分方程式をとく
                        clearvars t q te ie
                        [t, q, te, qe, ie] = ode45(ode4, [self.tstart, self.tfinal], qe(1, :), options4);
                        % 結果を保存とeveflg書き換え．
                        [self] = Accumulate04(t, q, te, qe, ie, self);
                        %次のステップに渡す初期値を作る．時間と設置した脚先の位置．
                        self.tstart = t(end);

                        if self.eveflg == 1
                            % 次はFlight
                            liftOffFlag.fore = true;
                        elseif self.eveflg == 2
                            % 次はhind leg stance
                            self.xh_toe = self.qout(end, 1) - self.L * cos(self.qout(end, 4)) * cos(self.qout(end,3))  - self.D * cos(self.qout(end, 3) - self.qout(end, 4)) + self.lout(end, 1) * sin(self.gout(end, 1));
                            liftOffFlag.fore = true;
                        elseif self.eveflg == 3
                            % 次はDouble leg stance
                            self.xh_toe = self.qout(end, 1) - self.L * cos(self.qout(end, 4)) * cos(self.qout(end,3))  - self.D * cos(self.qout(end, 3) - self.qout(end, 4)) + self.lout(end, 1) * sin(self.gout(end, 1));
                        end

                end % eveflag

            end % phases

            % Double Leg Flight (until apex height)
            if self.eveflg == 1
                eve5 = @(t, q) events5(q, self); %イベント関数を定義．ゼロになる変数と方向を指定
                %     ode5;  %odeで解く微分方程式はode1でよい．
                options5 = odeset('RelTol', self.relval, 'AbsTol', self.absval, 'Events', eve5, 'Refine', self.refine, 'Stats', 'off'); %ode45のオプションを設定．
                % ode45で微分方程式をとく
                clearvars t q te ie
                [t, q, te, qe, ie] = ode45(ode1, [self.tstart, self.tfinal], qe(1, :), options5);
                % 結果を保存とeveflg書き換え．
                [self] = Accumulate05(t, q, te, qe, ie, self);
            else
                % disp('not entered to flight @phase5')
                % disp(['eveflg = ', num2str(self.eveflg)])
            end

            % 最終処理　apex heightに戻ってきたか否かでやることが変わる
            if self.eveflg == 1
                % reached apex height
                % disp('reached apex height')
                % 誤差の計算
                x0 = self.q_ini(1);
                y0 = self.q_ini(2);
                th0 = self.q_ini(3);
                ph0 = self.q_ini(4);
                dx0 = self.q_ini(5);
                dy0 = self.q_ini(6);
                dth0 = self.q_ini(7);
                dph0 = self.q_ini(8);
                x = self.qout(end, 1);
                y = self.qout(end, 2);
                th = self.qout(end, 3);
                ph = self.qout(end, 4);
                dx = self.qout(end, 5);
                dy = self.qout(end, 6);
                dth = self.qout(end, 7);
                dph = self.qout(end, 8);

                self.mileage = x - x0;
                self.q_err(1) = y - y0;
                self.q_err(2) = th - th0;
                self.q_err(3) = ph - ph0;
                self.q_err(4) = dx - dx0;
                self.q_err(5) = dy - dy0;
                self.q_err(6) = dth - dth0;
                self.q_err(7) = dph - dph0;
                self.q_err_max = max(self.q_err);

                % エネルギーの計算
                self.Eout = calc_Energy(self);
                % T1 = 0.5 * self.m * (dx^2 + dy^2);
                % T2 = 0.5 * self.J * dth^2;
                % V = self.m * self.g * y;
                % self.E = T1 + T2 + V;

            else
                % disp('gone away')
                % 誤差の計算
                x0 = self.q_ini(1);
                y0 = self.q_ini(2);
                th0 = self.q_ini(3);
                ph0 = self.q_ini(4);
                dx0 = self.q_ini(5);
                dy0 = self.q_ini(6);
                dth0 = self.q_ini(7);
                dph0 = self.q_ini(8);
                x = self.qout(end, 1);
                y = self.qout(end, 2);
                th = self.qout(end, 3);
                ph = self.qout(end, 4);
                dx = self.qout(end, 5);
                dy = self.qout(end, 6);
                dth = self.qout(end, 7);
                dph = self.qout(end, 8);
                % x0 = self.q_ini(1);
                % y0 = self.q_ini(2);
                % th0 = self.q_ini(3);
                % dx0 = self.q_ini(4);
                % dy0 = self.q_ini(5);
                % dth0 = self.q_ini(6);
                % x = self.qout(end, 1);
                % y = self.qout(end, 2);
                % th = self.qout(end, 3);
                % dx = self.qout(end, 4);
                % dy = self.qout(end, 5);
                % dth = self.qout(end, 6);

                self.mileage = x - x0;
                self.q_err(1) = y - y0;
                self.q_err(2) = th - th0;
                self.q_err(3) = ph - ph0;
                self.q_err(4) = dx - dx0;
                self.q_err(5) = dy - dy0;
                self.q_err(6) = dth - dth0;
                self.q_err(7) = dph - dph0;
                self.q_err_max = max(self.q_err);
                % self.mileage = x - x0;
                % self.q_err(1) = y - y0;
                % self.q_err(2) = th - th0;
                % self.q_err(3) = dx - dx0;
                % self.q_err(4) = dy - dy0;
                % self.q_err(5) = dth - dth0;
                % self.q_err_max = max(self.q_err);
                % エネルギーの計算
                self.Eout = calc_Energy(self);
                % T1 = 0.5 * self.m * (dx^2 + dy^2);
                % T2 = 0.5 * self.J * dth^2;
                % V = self.m * self.g * y;
                % self.E = T1 + T2 + V;
            end

        end % bound

        function plot(self, saveflag)

            % -----------------------------------------------------------------
            qlabelset = {'$$x$$ [m]', '$$y$$ [m]', '$$\theta$$ [rad]', '$$\phi$$ [rad]'...
                '$$\dot{x}$$ [m/s]', '$$\dot{y}$$ [m/s]', '$$\dot\theta$$ [rad/s]', '$$\dot\phi$$ [rad/s]'};
            % -----------------------------------------------------------------
            % 座標変換
            qout_(:, 1) = self.qout(:, 1);
            qout_(:, 2) = self.qout(:, 2);
            qout_(:, 3) = self.qout(:, 3); %degに変換
            qout_(:, 4) = self.qout(:, 4);
%             qout_(:, 3) = self.qout(:, 3) * 180 / pi; %degに変換
%             qout_(:, 4) = self.qout(:, 4) * 180 / pi;
            qout_(:, 5) = self.qout(:, 5);
            qout_(:, 6) = self.qout(:, 6);
%             qout_(:, 7) = self.qout(:, 7) * 180 / pi; %degに変換;
%             qout_(:, 8) = self.qout(:, 8) * 180 / pi;
            qout_(:, 7) = self.qout(:, 7); %degに変換;
            qout_(:, 8) = self.qout(:, 8);

            tend = self.tout(end);
            tout_ = self.tout;
            teout_ = self.teout;
            qeout_ = self.qeout;

            %% 状態量のグラフ
            %figure
            figure('outerposition', [50, 200, 1200, 500])
            ylimset =[  0 6;...
                        0.55 0.7;...
                        -0.16 0.16;...
                        -1.0 1.0;...
                        14.7 15.0;...
                        -1.6 1.6;...
                        -6 6;...
                        -12 12];
            for pp = 1:8
                subplot(2, 4, pp)
                plot(tout_, qout_(:, pp),'LineWidth',1);
                hold on
                for i = 1:length(teout_)
                    line([teout_(i),teout_(i)],[min(qout_(:,pp)) max(qout_(:,pp))],'color','k','LineStyle',':')
                end
                xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
                ylabel(qlabelset{pp}, 'interpreter', 'latex', 'Fontsize', 14);
                xlim([0, tend]);
                % xlim([0, 0.35]);
                ylim(ylimset(pp,:));
            end

            if saveflag == 1
                figname = [date, 'variable1'];
                saveas(gcf, figname, 'fig')
                saveas(gcf, figname, 'png')
                saveas(gcf, figname, 'pdf')
            end

            %% 状態量を位相平面に
            figure('outerposition', [50, 200, 800, 600])

            for pp = 1:4
                subplot(2, 2, pp)
                plot(qout_(:, pp), qout_(:, pp + 4),'LineWidth',1);
                hold on
                for i = 1:length(teout_)-1
                    plot(qeout_(i,pp),qeout_(i,pp+4),'o','MarkerSize',4,'Markerfacecolor','b','markerEdgeColor','none')
                end
                xlabel(qlabelset{pp}, 'interpreter', 'latex', 'Fontsize', 14);
                ylabel(qlabelset{pp+4}, 'interpreter', 'latex', 'Fontsize', 14);
                % xlim([0, tend]);
            end

            if saveflag == 1
                figname = [date, 'variable_phasePlane'];
                saveas(gcf, figname, 'fig')
                saveas(gcf, figname, 'png')
                saveas(gcf, figname, 'pdf')
            end

            %% 状態変数以外
            % 脚長さのグラフ
            figure
            plot(tout_, self.lout(:, 1));
            hold on
            plot(tout_, self.lout(:, 2), '--');
            xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
            ylabel('$$l_{\rm h},l_{\rm f}$$ [m]', 'interpreter', 'latex', 'Fontsize', 14);
            xlim([0, max(tout_)]);
            ylim([min(self.lout(:, 1)) - 0.01, max(self.lout(:, 1))]);
            % ylim([min(self.lout(:, 1)) - 0.01, 0.37]);
            legend({'hind leg', 'fore leg'}, 'Location', 'best')

            if saveflag == 1
                figname = [date, 'variable2'];
                saveas(gcf, figname, 'fig')
                saveas(gcf, figname, 'png')
                saveas(gcf, figname, 'pdf')
            end

            % 脚角度のグラフ
            figure
            plot(tout_, self.gout(:, 1));
            hold on
            plot(tout_, self.gout(:, 2), '--r');
            xlim([0, max(tout_)]);
            xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
            ylabel('$$\gamma_{\rm h},\gamma_{\rm f}$$ [rad]', 'interpreter', 'latex', 'Fontsize', 14);
            legend({'hind leg', 'fore leg'}, 'Location', 'best')

            if saveflag == 1
                figname = [date, 'variable3'];
                saveas(gcf, figname, 'fig')
                saveas(gcf, figname, 'png')
                saveas(gcf, figname, 'pdf')
            end

            % エネルギーのグラフ
            figure
            Eout_ = [self.Eout(:, 1), self.Eout(:, 2), self.Eout(:, 3), self.Eout(:, 4), self.Eout(:, 5), self.Eout(:,6), self.Eout(:,7), self.Eout(:,8)];
            area(tout_, Eout_)
            xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
            ylabel('Energy', 'interpreter', 'latex', 'Fontsize', 14);
            legend({'trans(x)', 'trans(y)', 'rot($$\theta$$)','trans($$\phi$$)', 'grav.', 'hind leg', 'fore leg', 'torso'},'Interpreter','latex','Location','best')
            xlim([0, self.tout(end)])
%             ylim([0, max(self.Eout(:, 9))])

            if saveflag == 1
                figname = [date, 'variable4'];
                saveas(gcf, figname, 'fig')
                saveas(gcf, figname, 'png')
                saveas(gcf, figname, 'pdf')
            end

        end % plot

        function anime(self, speed, rec)
            FPS = 30;
            dt = speed / FPS; % [ms]
            % 時間を等間隔に修正
            tstart = self.tout(1);
            tfinal = self.tout(end);
            tspan = tfinal - tstart;
            teq = [tstart:dt:tfinal]';
            t_mid = 1e3 * 0.5 * (tfinal + tstart);
            qout_ = resample(self.qout, self.tout, 1 / dt); % signal processingの関数
            lout_ = resample(self.lout, self.tout, 1 / dt);
            gout_ = resample(self.gout, self.tout, 1 / dt);

            x_max = 2 * max(qout_(:, 1));

            x_ground_st = -0.2;
            y_ground_st = 0;
            x_ground_fn = x_max;
            y_ground_fn = 0;
            anim_num = length(qout_(:, 1));

            %% 描画する各点を計算
            for i = 1:anim_num
                x = qout_(i, 1);   %質量中心
                y = qout_(i, 2);
                th = qout_(i, 3);
                ph = qout_(i, 4);

                x_joint(i) = x - self.L * cos(ph) * cos(th) + self.L * cos(th - ph);   %ジョイント部
                y_joint(i) = y - self.L * cos(ph) * sin(th) + self.L * sin(th - ph);

                x_hip(i) = x - self.L * cos(th) * cos(ph) - self.L * cos(th - ph);  %胴体
                y_hip(i) = y - self.L * cos(ph) * sin(th) - self.L * sin(th - ph);
                x_head(i) = x + self.L * cos(th) * cos(ph) + self.L * cos(th + ph);
                y_head(i) = y + self.L * cos(ph) * sin(th) + self.L * sin(th + ph);

                x_hipjoint(i) = x - self.L * cos(th) * cos(ph) - self.D * cos(th - ph);    %関節
                y_hipjoint(i) = y - self.L * cos(ph) * sin(th) - self.D * sin(th - ph);
                x_headjoint(i) = x + self.L * cos(th) * cos(ph) + self.D * cos(th + ph);
                y_headjoint(i) = y + self.L * cos(ph) * sin(th) + self.D * sin(th + ph);

                x_foot_b(i) = x_hipjoint(i) + lout_(i, 1) * sin(gout_(i, 1));     %脚先
                y_foot_b(i) = y_hipjoint(i) - lout_(i, 1) * cos(gout_(i, 1));
                x_foot_f(i) = x_headjoint(i) + lout_(i, 2) * sin(gout_(i, 2));
                y_foot_f(i) = y_headjoint(i) - lout_(i, 2) * cos(gout_(i, 2));

            end

            set(gca, 'position', [0.10, 0.15, 0.8, 0.7])

            %% 動画を描写

            h1 = figure;
            % h1.InnerPosition = [100, 50, 600, 600];
            set(h1, 'DoubleBuffer', 'off');

            axis equal
%             xlim([-0.5 max(x_head) + 0.2])
            xlim([x_joint(1) - 1, x_joint(1)+ 1])
            ylim([-0.2 1.3])
            body1 = line([x_hip(1), x_joint(1)], [y_hip(1), y_joint(1)], 'color', 'k', 'LineWidth', 3);
            body2 = line([x_joint(1), x_head(1)], [y_joint(1), y_head(1)], 'color', 'k', 'LineWidth', 3);
            hindLeg = line([x_hipjoint(1), x_foot_b(1)], [y_hipjoint(1), y_foot_b(1)], 'color', 'r', 'LineWidth', 3);
            foreLeg = line([x_headjoint(1), x_foot_f(1)], [y_headjoint(1), y_foot_f(1)], 'color', 'b', 'LineWidth', 3);
            line([-0.5 max(x_head) + 0.2], [0, 0], 'color', 'k', 'LineWidth', 1);

            %もともと
            % body1 = line([x_hip(1), qout_(1, 1)], [y_hip(1), qout_(1, 2)], 'color', 'k', 'LineWidth', 3);
            % body2 = line([qout_(1, 1), x_head(1)], [qout_(1, 2), y_head(1)], 'color', 'k', 'LineWidth', 3);
            % hindLeg = line([x_hipjoint(1), x_foot_b(1)], [y_hipjoint(1), y_foot_b(1)], 'color', 'r', 'LineWidth', 3);
            % foreLeg = line([x_headjoint(1), x_foot_f(1)], [y_headjoint(1), y_foot_f(1)], 'color', 'b', 'LineWidth', 3);
            % line([-0.5 max(x_head) + 0.2], [0, 0], 'color', 'k', 'LineWidth', 1);


            %体バラしてみたかった
            % body1 = line([x_hip(1), x_hipjoint(1)], [y_hip(1), y_hipjoint(1)], 'color', 'k', 'LineWidth', 3);
            % body2 = line([x_hipjoint(1), qout_(1, 1)], [y_hipjoint(1), qout_(1, 2)], 'color', 'k', 'LineWidth', 3);
            % body3 = line([qout_(1, 1), x_headjoint(1)], [qout_(1, 2), y_headjoint(1)], 'color', 'k', 'LineWidth', 3);
            % body4 = line([x_headjoint(1), x_head(1)], [y_headjoint(1), y_head(1)], 'color', 'k', 'LineWidth', 3);
            % hindLeg = line([x_hipjoint(1), x_foot_b(1)], [y_hipjoint(1), y_foot_b(1)], 'color', 'r', 'LineWidth', 3);
            % foreLeg = line([x_headjoint(1), x_foot_f(1)], [y_headjoint(1), y_foot_f(1)], 'color', 'b', 'LineWidth', 3);
            % line([-0.5 max(x_head) + 0.2], [0, 0], 'color', 'k', 'LineWidth', 1);

            strng = [num2str(0, '%.2f'), ' s'];
            t = text(0, -0.1, strng, 'color', 'k', 'fontsize', 16);
%             strng2 = ['x', num2str(speed, '%.2f')];
%             t2 = text(max(x_head) - 0.1, -0.1, strng2, 'color', 'k', 'fontsize', 16);
            % xlim([-0.5 max(x_head) + 0.2])
            % ylim([-0.2 1.3])
            % body = line([x_hip(1), x_head(1)], [y_hip(1), y_head(1)], 'color', 'k', 'LineWidth', 3);
            % hindLeg = line([x_hip(1), x_foot_b(1)], [y_hip(1), y_foot_b(1)], 'color', 'r', 'LineWidth', 3);
            % foreLeg = line([x_head(1), x_foot_f(1)], [y_head(1), y_foot_f(1)], 'color', 'b', 'LineWidth', 3);
            % line([-0.5 max(x_head) + 0.2], [0, 0], 'color', 'k', 'LineWidth', 1);

            F = [];

            for i_t = 10:1:anim_num - 10
                body1.XData = [x_hip(i_t), x_joint(i_t)];
                body1.YData = [y_hip(i_t), y_joint(i_t)];
                body2.XData = [x_joint(i_t), x_head(i_t)];
                body2.YData = [y_joint(i_t), y_head(i_t)];
                hindLeg.XData = [x_hipjoint(i_t), x_foot_b(i_t)];
                hindLeg.YData = [y_hipjoint(i_t), y_foot_b(i_t)];
                foreLeg.XData = [x_headjoint(i_t), x_foot_f(i_t)];
                foreLeg.YData = [y_headjoint(i_t), y_foot_f(i_t)];
                strng = [num2str(teq(i_t), '%.3f'), ' s'];
                t.Position = [x_joint(i_t) -0.1 0];
                t.String = strng;

                xlim([x_joint(i_t) - 1, x_joint(i_t)+ 1])
                drawnow

                if rec == true
                    F = [F; getframe(h1)];
                end

            end
            % for i_t = 10:1:anim_num - 10
            %     body.XData = [x_hip(i_t), x_head(i_t)];
            %     body.YData = [y_hip(i_t), y_head(i_t)];
            %     hindLeg.XData = [x_hip(i_t), x_foot_b(i_t)];
            %     hindLeg.YData = [y_hip(i_t), y_foot_b(i_t)];
            %     foreLeg.XData = [x_head(i_t), x_foot_f(i_t)];
            %     foreLeg.YData = [y_head(i_t), y_foot_f(i_t)];
            %     strng = [num2str(teq(i_t), '%.3f'), ' s'];
            %     t.String = strng;
            %     drawnow

            %     if rec == true
            %         F = [F; getframe(h1)];
            %     end

            % end

            if rec == true
                videoobj = VideoWriter([date, 'movie.mp4'], 'MPEG-4');
                videoobj.FrameRate = FPS;
                fprintf('video saving...')
                open(videoobj);
                writeVideo(videoobj, F);
                close(videoobj);
                fprintf('complete!\n');
            end % save

        end % anime
        
        function stick(self, skip_num, saveflag)
            
            % % 時間を等間隔に修正
            % tstart = self.tout(1);
            % tfinal = self.tout(end);
            % tspan = tfinal - tstart;
            % teq = [tstart:dt:tfinal]';
            % t_mid = 1e3 * 0.5 * (tfinal + tstart);
            % qout_ = resample(self.qout, self.tout, 1 / dt); % signal processingの関数
            % lout_ = resample(self.lout, self.tout, 1 / dt);
            % gout_ = resample(self.gout, self.tout, 1 / dt);
            % 時間を等間隔に修正
            qout_ = self.qout;
            lout_ = self.lout;
            gout_ = self.gout;

            x_max = 2 * max(qout_(:, 1));

            x_ground_st = -0.2;
            y_ground_st = 0;
            x_ground_fn = x_max;
            y_ground_fn = 0;
            stick_num = length(qout_(:, 1));

            %% 描画する各点を計算
            for i = 1:stick_num
                x = qout_(i, 1);   %質量中心
                y = qout_(i, 2);
                th = qout_(i, 3);
                ph = qout_(i, 4);

                x_joint(i) = x - self.L * cos(ph) * cos(th) + self.L * cos(th - ph);   %ジョイント部
                y_joint(i) = y - self.L * cos(ph) * sin(th) + self.L * sin(th - ph);

                x_hip(i) = x - self.L * cos(th) * cos(ph) - self.L * cos(th - ph);  %胴体
                y_hip(i) = y - self.L * cos(ph) * sin(th) - self.L * sin(th - ph);
                x_head(i) = x + self.L * cos(th) * cos(ph) + self.L * cos(th + ph);
                y_head(i) = y + self.L * cos(ph) * sin(th) + self.L * sin(th + ph);

                x_hipjoint(i) = x - self.L * cos(th) * cos(ph) - self.D * cos(th - ph);    %関節
                y_hipjoint(i) = y - self.L * cos(ph) * sin(th) - self.D * sin(th - ph);
                x_headjoint(i) = x + self.L * cos(th) * cos(ph) + self.D * cos(th + ph);
                y_headjoint(i) = y + self.L * cos(ph) * sin(th) + self.D * sin(th + ph);

                x_foot_b(i) = x_hipjoint(i) + lout_(i, 1) * sin(gout_(i, 1));     %脚先
                y_foot_b(i) = y_hipjoint(i) - lout_(i, 1) * cos(gout_(i, 1));
                x_foot_f(i) = x_headjoint(i) + lout_(i, 2) * sin(gout_(i, 2));
                y_foot_f(i) = y_headjoint(i) - lout_(i, 2) * cos(gout_(i, 2));

            end

            set(gca, 'position', [0.10, 0.15, 0.8, 0.7])

            %% 動画を描写

            h1 = figure;
            % h1.InnerPosition = [100, 50, 600, 600];
            % set(h1, 'DoubleBuffer', 'off');

            axis equal

            clr = cool(stick_num);
            for i_t = 1:skip_num:stick_num
                line([x_hip(i_t), x_joint(i_t)], [y_hip(i_t), y_joint(i_t)], 'color', clr(i_t,:), 'LineWidth', 1);
                line([x_joint(i_t), x_head(i_t)], [y_joint(i_t), y_head(i_t)], 'color', clr(i_t,:), 'LineWidth', 1);
                line([x_hipjoint(i_t), x_foot_b(i_t)], [y_hipjoint(i_t), y_foot_b(i_t)], 'color', clr(i_t,:), 'LineWidth', 1);
                line([x_headjoint(i_t), x_foot_f(i_t)], [y_headjoint(i_t), y_foot_f(i_t)], 'color', clr(i_t,:), 'LineWidth', 1);
                drawnow
                hold on
            end
            
            line([min(x_joint) - 1, max(x_joint)+ 1], [0, 0], 'color', 'k', 'LineWidth', 1);

            xlim([min(x_joint) - 1, max(x_joint)+ 1])
            ylim([-0.2 1.3])

            qeout_ = self.qeout;
            event_num = length(self.teout);

            for i = 1:event_num
                x =  qeout_(i, 1);   %質量中心
                y =  qeout_(i, 2);
                th = qeout_(i, 3);
                ph = qeout_(i, 4);

                x_joint(i) = x - self.L * cos(ph) * cos(th) + self.L * cos(th - ph);   %ジョイント部
                y_joint(i) = y - self.L * cos(ph) * sin(th) + self.L * sin(th - ph);

                x_hip(i) = x - self.L * cos(th) * cos(ph) - self.L * cos(th - ph);  %胴体
                y_hip(i) = y - self.L * cos(ph) * sin(th) - self.L * sin(th - ph);
                x_head(i) = x + self.L * cos(th) * cos(ph) + self.L * cos(th + ph);
                y_head(i) = y + self.L * cos(ph) * sin(th) + self.L * sin(th + ph);

                x_hipjoint(i) = x - self.L * cos(th) * cos(ph) - self.D * cos(th - ph);    %関節
                y_hipjoint(i) = y - self.L * cos(ph) * sin(th) - self.D * sin(th - ph);
                x_headjoint(i) = x + self.L * cos(th) * cos(ph) + self.D * cos(th + ph);
                y_headjoint(i) = y + self.L * cos(ph) * sin(th) + self.D * sin(th + ph);

                x_foot_b(i) = x_hipjoint(i) + lout_(i, 1) * sin(gout_(i, 1));     %脚先
                y_foot_b(i) = y_hipjoint(i) - lout_(i, 1) * cos(gout_(i, 1));
                x_foot_f(i) = x_headjoint(i) + lout_(i, 2) * sin(gout_(i, 2));
                y_foot_f(i) = y_headjoint(i) - lout_(i, 2) * cos(gout_(i, 2));

                line([x_hip(i), x_joint(i)], [y_hip(i), y_joint(i)], 'color', 'k', 'LineWidth', 2);
                line([x_joint(i), x_head(i)], [y_joint(i), y_head(i)], 'color', 'k', 'LineWidth', 2);
                line([x_hipjoint(i), x_foot_b(i)], [y_hipjoint(i), y_foot_b(i)], 'color', 'k', 'LineWidth', 2);
                line([x_headjoint(i), x_foot_f(i)], [y_headjoint(i), y_foot_f(i)], 'color', 'k', 'LineWidth', 2);
                drawnow
                hold on
            end

            if saveflag == 1
                figname = [date, 'stickDiagram'];
                saveas(gcf, figname, 'fig')
                saveas(gcf, figname, 'png')
                saveas(gcf, figname, 'pdf')
            end

        end % stick

    end % methods

end
