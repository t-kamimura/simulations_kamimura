function [model] = Accumulate04(t, q, te, qe, ie, model)
    nt = length(t);
    model.eveflgout = [model.eveflgout; ones(nt - 1, 1) * model.eveflg];

    % どのイベントが起こったか？
    % value = [hind_toeHight; lf_length; yg];
    switch length(ie)
        case 0
            % disp('no event occured @phase4')
            model.eveflg = 20;
        case 1
            if ie(1) == 1
                % disp('hind leg touch down @phase4')
                model.eveflg = 3;
            elseif ie(1) == 2
                % disp('fore leg lift off @phase4')
                model.eveflg = 1;
            elseif ie(1) == 3
                % disp('fall down @phase4')
                model.eveflg = 30;
            else
                % disp('unknown error @phase4')
                model.eveflg = 30;
            end

        case 2
            if ie(1) == 1 && ie(2) == 2
                % disp('hind leg touch down & fore leg lift off @phase4')
                model.eveflg = 2;
            else
                % disp('fall down @phase4')
                model.eveflg = 30;
            end

        case 3
            % disp('unknown error @phase4')
            model.eveflg = 30;
    end

    model.tout = [model.tout; t(2:nt)];
    model.qout = [model.qout; q(2:nt, :)];

    theta = q(2:nt, 3);
    phi = q(2:nt, 4);
    xf = q(2:nt, 1) + model.L .* cos(phi) .* cos(theta) + model.D .* cos(theta + phi);
    yf = q(2:nt, 2) + model.L .* cos(phi) .* sin(theta) + model.D .* sin(theta + phi);
    % theta = q(2:nt, 3);
    % xf = q(2:nt, 1) + model.L * cos(theta);
    % yf = q(2:nt, 2) + model.L * sin(theta);

    Pf = model.xf_toe * ones(nt - 1, 1) - xf;
    Qf = 0 - yf;
    LBf = sqrt(Pf.^2 + Qf.^2);
    GBf = atan2(Pf, -Qf);

    model.lout = [model.lout; ones(nt - 1, 1) * model.lh, LBf];
    model.gout = [model.gout; ones(nt - 1, 1) * model.gamma_h_td, GBf];

    model.teout = [model.teout; te(1)];
    model.qeout = [model.qeout; qe(1, :)];
    model.ieout = [model.ieout; ie(1)];

end
