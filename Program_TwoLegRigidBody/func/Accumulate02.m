function [model] = Accumulate02(t, q, te, qe, ie, model)


    % どのイベントが起こったか？
    % value = [fore_toeHight; lb_length; yg];
    switch length(ie)
        case 0
            disp('no event occured @phase2')
            model.eveflg = 20;
        case 1

            if ie(1) == 1
                disp('fore leg touch down @phase2')
                model.eveflg = 3;
            elseif ie(1) == 2
                disp('hind leg lift off @phase2')
                model.eveflg = 1;
            elseif ie(1) == 3
                disp('fall down @phase2')
                model.eveflg = 30;
            else
                disp('unknown error @phase2')
                model.eveflg = 30;
            end

        case 2

            if ie(1) == 1 && ie(2) == 2
%                 disp('fore leg touch down & hind leg lift off@phase2')
                model.eveflg = 4;
            else
%                 disp('fall down @phase2')
                model.eveflg = 30;
            end

        case 3
            % disp('unknown error@phase2')
            model.eveflg = 30;
    end

    % *outを更新
    nt = length(t);
    model.eveflgout = [model.eveflgout; ones(nt - 1, 1) * model.eveflg];
    model.tout = [model.tout; t(2:nt)];
    model.qout = [model.qout; q(2:nt, :)];

    theta = q(2:nt, 3);
    xb = q(2:nt, 1) - model.L * cos(theta);
    yb = q(2:nt, 2) - model.L * sin(theta);

    Pb = model.xh_toe * ones(nt - 1, 1) - xb;
    Qb = 0 - yb;
    LBb = sqrt(Pb.^2 + Qb.^2);
    GBb = atan2(Pb, -Qb);
    
    model.lout = [model.lout; LBb, ones(nt - 1, 1) * model.lf];
    model.gout = [model.gout; GBb, ones(nt - 1, 1) * model.gamma_f_td];

    model.teout = [model.teout; te(1)];
    model.qeout = [model.qeout; qe(1, :)];
    model.ieout = [model.ieout; ie(1)];

end
