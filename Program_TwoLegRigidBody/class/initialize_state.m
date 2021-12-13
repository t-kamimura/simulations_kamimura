function [tstart_, q_ini_, phaseIndex, liftOffFlag] = initialize_state(model,q_initial, u_inital)
    
    model.tout = 0;
    model.qout = q_initial;
    model.gout = u_inital;
    model.lout = [model.l3 model.l4];

    model.teout = [];
    model.qeout = [];
    model.ieout = [];
    model.phaseout = 1;

    model.q_ini = q_initial;
    model.gamma_h_td = u_inital(1);
    model.gamma_f_td = u_inital(2);

    model.lh = model.l3;
    model.lf = model.l4;

    tstart_ = 0;
    q_ini_ = q_initial;

    liftOffFlag.hind = false;
    liftOffFlag.fore = false;

    % 初期値おかしかったとき
    y_ini = q_initial(2);
    phaseIndex = 1;
    if y_ini < 0
        phaseIndex = 22;
    end
end