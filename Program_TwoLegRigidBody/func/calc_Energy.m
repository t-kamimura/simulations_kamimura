function Eout = calc_Energy(model)
    xout = model.qout(:, 1);
    yout = model.qout(:, 2);
    thout = model.qout(:, 3);
    dxout = model.qout(:, 4);
    dyout = model.qout(:, 5);
    dthout = model.qout(:, 6);

    % 運動エネルギー
    T1out = 0.5 * (model.m * (dxout.^2 + dyout.^2));
    T2out = 0.5 * (model.J * dthout.^2);
    Tout = T1out + T2out;

    V1out = model.m * model.g * yout;
    V2out = 0.5 * model.kh * (model.l3 - model.lout(:, 1)).^2;
    V3out = 0.5 * model.kf * (model.l4 - model.lout(:, 2)).^2;
    Vout = V1out + V2out + V3out;
    %Total Energy
    Eout = [T1out, T2out, V1out, V2out, V3out, Tout + Vout];
end