function model = Accumulate01(t, q, te, qe, ie, model)

    nt = length(t);
    model.eveflgout = [model.eveflgout; ones(nt - 1, 1) * model.eveflg];

    % どのイベントが起こったか？
    % value = [hind_toeHight; fore_toeHight; yg]; % from events1
    switch length(ie)
        case 0 % どのイベントも発生していない
%             disp('no event occured @phase1')
            model.eveflg = 20;
        case 1
            if ie(1) == 1
%                 disp('hind leg touch down @phase1')
                model.eveflg = 2;   % next phase: hind leg stance
            elseif ie(1) == 2
%                 disp('fore leg touch down @phase1')
                model.eveflg = 4;   % next phase: fore leg stance
            elseif ie(1) == 3
%                 disp('fall down @phase1')
                model.eveflg = 30;
            else
%                 disp('unknown error @phase1')
                model.eveflg = 30;
            end

        case 2  % 同時に2個のイベントが発生

            if ie(1) == 1 && ie(2) == 2
%                 disp('hind & fore leg touch down @phase1')
                model.eveflg = 3;
            else
%                 disp('fall down @phase1')
                model.eveflg = 30;
            end

        case 3
%             disp('unknown error @phase1')
            model.eveflg = 30;
    end

    model.tout = [model.tout; t(2:nt)];
    model.qout = [model.qout; q(2:nt, :)];

    model.lout = [model.lout; ones(nt - 1, 1) * model.l3, ones(nt - 1, 1) * model.l4];
    model.gout = [model.gout; ones(nt - 1, 1) * model.gamma_h_td(1), ones(nt - 1, 1) * model.gamma_f_td(1)];

    model.teout = [model.teout; te(1)];
    model.qeout = [model.qeout; qe(1, :)];
    model.ieout = [model.ieout; ie(1)];

end
