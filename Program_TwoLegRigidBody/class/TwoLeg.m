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

        function plot(self, saveflag)

            % -----------------------------------------------------------------
            qlabelset = {'$$x_g$$', '$$y_g$$', '$$\theta$$', ...
                '$$\dot{x}_g$$', '$$\dot{y}_g$$', '$$\dot\theta$$'};
            % -----------------------------------------------------------------
            % 座標変換
            qout_(:, 1) = self.qout(:, 1);
            qout_(:, 2) = self.qout(:, 2);
            qout_(:, 3) = self.qout(:, 3) * 180 / pi; %degに変換
            qout_(:, 4) = self.qout(:, 4);
            qout_(:, 5) = self.qout(:, 5);
            qout_(:, 6) = self.qout(:, 6) * 180 / pi; %degに変換;

            tend = self.tout(end);
            tout_ = self.tout;

            %% 状態量のグラフ
            figure
            % figure('outerposition', [50, 200, 1200, 500])

            for pp = 1:6
                subplot(2, 3, pp)
                plot(tout_, qout_(:, pp));
                hold on
                xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
                ylabel(qlabelset{pp}, 'interpreter', 'latex', 'Fontsize', 14);
                xlim([0, max(tout_)]);
            end

            if saveflag == 1
                figname = [date, 'variable1'];
                saveas(gcf, figname, 'fig')
                saveas(gcf, figname, 'png')
                saveas(gcf, figname, 'epsc')
            end

            %% 状態変数以外
            % フェーズのグラフ
            figure
            plot(tout_, self.phaseout);
            xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
            ylabel('phase', 'Fontsize', 14);
            xlim([0, max(tout_)]);

            if saveflag == 1
                figname = [date, 'phase'];
                saveas(gcf, figname, 'fig')
                saveas(gcf, figname, 'png')
                saveas(gcf, figname, 'epsc')
            end
            % 脚長さのグラフ
            figure
            plot(tout_, self.lout(:, 1));
            hold on
            plot(tout_, self.lout(:, 2), '--');
            xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
            ylabel('$$l_{\rm h},l_{\rm f}$$', 'interpreter', 'latex', 'Fontsize', 14);
            xlim([0, max(tout_)]);
            ylim([min(self.lout(:, 1)) - 0.01, 0.37]);
            legend({'hind leg', 'fore leg'}, 'Location', 'best')

            if saveflag == 1
                figname = [date, 'variable2'];
                saveas(gcf, figname, 'fig')
                saveas(gcf, figname, 'png')
                saveas(gcf, figname, 'epsc')
            end

            % 脚角度のグラフ
            figure
            plot(tout_, self.gout(:, 1));
            hold on
            plot(tout_, self.gout(:, 2), '--r');
            xlim([0, max(tout_)]);
            xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
            ylabel('$$\gamma_{\rm h},\gamma_{\rm f}$$', 'interpreter', 'latex', 'Fontsize', 14);
            legend({'hind leg', 'fore leg'}, 'Location', 'best')

            if saveflag == 1
                figname = [date, 'variable3'];
                saveas(gcf, figname, 'fig')
                saveas(gcf, figname, 'png')
                saveas(gcf, figname, 'epsc')
            end

            figure
            Eout_ = [self.Eout(:, 1), self.Eout(:, 2), self.Eout(:, 3), self.Eout(:, 4), self.Eout(:, 5)];
            area(tout_, Eout_)
            xlabel('$$t$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
            ylabel('Energy', 'interpreter', 'latex', 'Fontsize', 14);
            legend('trans.', 'rot.', 'grav.', 'hind leg', 'fore leg')
            xlim([0, self.tout(end)])
            ylim([0, max(self.Eout(:, 6))])

            if saveflag == 1
                figname = [date, 'variable4'];
                saveas(gcf, figname, 'fig')
                saveas(gcf, figname, 'png')
                saveas(gcf, figname, 'epsc')
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
                x = qout_(i, 1);
                y = qout_(i, 2);
                th = qout_(i, 3);

                x_hip(i) = x - self.L * cos(th);
                y_hip(i) = y - self.L * sin(th);
                x_head(i) = x + self.L * cos(th);
                y_head(i) = y + self.L * sin(th);

                x_foot_b(i) = x_hip(i) + lout_(i, 1) * sin(gout_(i, 1));
                y_foot_b(i) = y_hip(i) - lout_(i, 1) * cos(gout_(i, 1));
                x_foot_f(i) = x_head(i) + lout_(i, 2) * sin(gout_(i, 2));
                y_foot_f(i) = y_head(i) - lout_(i, 2) * cos(gout_(i, 2));

            end

            set(gca, 'position', [0.10, 0.15, 0.8, 0.7])

            %% 動画を描写

            h1 = figure;
            % h1.InnerPosition = [100, 50, 600, 600];
            set(h1, 'DoubleBuffer', 'off');

            axis equal
            xlim([-0.5 max(x_head) + 0.2])
            ylim([-0.2 1.3])
            body = line([x_hip(1), x_head(1)], [y_hip(1), y_head(1)], 'color', 'k', 'LineWidth', 3);
            hindLeg = line([x_hip(1), x_foot_b(1)], [y_hip(1), y_foot_b(1)], 'color', 'r', 'LineWidth', 3);
            foreLeg = line([x_head(1), x_foot_f(1)], [y_head(1), y_foot_f(1)], 'color', 'b', 'LineWidth', 3);
            line([-0.5 max(x_head) + 0.2], [0, 0], 'color', 'k', 'LineWidth', 1);

            strng = [num2str(0, '%.2f'), ' s'];
            t = text(0, -0.1, strng, 'color', 'k', 'fontsize', 16);
            strng2 = ['x', num2str(speed, '%.2f')];
            t2 = text(max(x_head) - 0.1, -0.1, strng2, 'color', 'k', 'fontsize', 16);

            F = [];

            for i_t = 10:1:anim_num - 10
                body.XData = [x_hip(i_t), x_head(i_t)];
                body.YData = [y_hip(i_t), y_head(i_t)];
                hindLeg.XData = [x_hip(i_t), x_foot_b(i_t)];
                hindLeg.YData = [y_hip(i_t), y_foot_b(i_t)];
                foreLeg.XData = [x_head(i_t), x_foot_f(i_t)];
                foreLeg.YData = [y_head(i_t), y_foot_f(i_t)];
                strng = [num2str(teq(i_t), '%.3f'), ' s'];
                t.String = strng;
                drawnow

                if rec == true
                    F = [F; getframe(h1)];
                end

            end

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

    end % methods

end
