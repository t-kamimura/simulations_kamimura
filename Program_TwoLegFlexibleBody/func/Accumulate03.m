function [model] = Accumulate03(t, q, te, qe, ie, model)
    nt = length(t);
    model.eveflgout = [model.eveflgout; ones(nt - 1, 1) * model.eveflg];

    % どのイベントが起こったか？
    % value = [lb_length; lf_length; yg];
    switch length(ie)
        case 0
            disp('no event occured @phase3')
            model.eveflg = 20;
        case 1

            if ie(1) == 1
                disp('hind leg lift off @phase3')
                model.eveflg = 4;
            elseif ie(1) == 2
                disp('fore leg lift off @phase3')
                model.eveflg = 2;
            elseif ie(1) == 3
                disp('fall down @phase3')
                model.eveflg = 30;
            else
                disp('unknown error @phase3')
                model.eveflg = 30;
            end

        case 2

            if ie(1) == 1 && ie(2) == 2
                disp('fore & hind leg lift off @phase3')
                model.eveflg = 1;
            else
                disp('fall down @phase3')
                model.eveflg = 30;
            end

        case 3
            disp('unkown error@phase3')
            model.eveflg = 30;
    end

    model.tout = [model.tout; t(2:nt)];
    model.qout = [model.qout; q(2:nt, :)];

    theta = q(2:nt, 3);
    phi = q(2:nt, 4);
    xb = q(2:nt, 1) - model.L .* cos(phi) .* cos(theta) - model.D .* cos(theta - phi);
    yb = q(2:nt, 2) - model.L .* cos(phi) .* sin(theta) - model.D .* sin(theta - phi);
    xf = q(2:nt, 1) + model.L .* cos(phi) .* cos(theta) + model.D .* cos(theta + phi);
    yf = q(2:nt, 2) + model.L .* cos(phi) .* sin(theta) + model.D .* sin(theta + phi);
    % theta = q(2:nt, 3);
    % xb = q(2:nt, 1) - model.L * cos(theta);
    % yb = q(2:nt, 2) - model.L * sin(theta);
    % xf = q(2:nt, 1) + model.L * cos(theta);
    % yf = q(2:nt, 2) + model.L * sin(theta);

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

end
