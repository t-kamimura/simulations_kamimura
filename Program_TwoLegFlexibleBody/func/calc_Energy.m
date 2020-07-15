function Eout = calc_Energy(model)
    xout = model.qout(:, 1);
    yout = model.qout(:, 2);
    thout = model.qout(:, 3);
    phout = model.qout(:, 4);
    dxout = model.qout(:, 5);
    dyout = model.qout(:, 6);
    dthout = model.qout(:, 7);
    dphout = model.qout(:, 8);

    % param = [model.m model.J model.kh model.kf model.kt model.xf_toe model.xh_toe model.gamma_h_td model.gamma_f_td model.L model.l3 model.l4 model.D model.g];

    xh = xout - model.L .* cos(phout) .* cos(thout);
    yh = yout - model.L .* cos(phout) .* sin(thout);
    xf = xout + model.L .* cos(phout) .* cos(thout);
    yf = yout + model.L .* cos(phout) .* sin(thout);
    % dxh = dxout + (dthout).^2 .* model.L .* sin(thout) .* cos(phout) + (dphout).^2 .* model.L .* sin(phout) .* cos(thout);
    % dyh = dyout - (dthout).^2 .* model.L .* cos(phout) .* cos(thout) + (dphout).^2 .* model.L .* sin(phout) .* sin(thout);
    % dxf = dxout - (dthout).^2 .* model.L .* sin(thout) .* cos(phout) - (dphout).^2 .* model.L .* sin(phout) .* cos(thout);
    % dyf = dyout + (dthout).^2 .* model.L .* cos(phout) .* cos(thout) - (dphout).^2 .* model.L .* sin(phout) .* sin(thout);
    dxh = dxout + dthout .* model.L .* sin(phout) .* cos(thout) + dphout .* model.L .* cos(phout) .* sin(thout);
    dyh = 0;
    dxf = 0;
    dyf = 0;

    % 運動エネルギー
    T1out = 0.5 * model.m * (dxh.^2 + dyh.^2) + 0.5 * model.m * (dxf.^2 + dyf.^2);
    T2out = model.J * (dthout.^2 + dphout.^2);
    Tout = T1out + T2out;

    V1out = 2 * model.m * model.g * yout;
    V2out = 0.5 * model.kh * (model.l3 - model.lout(:, 1)).^2;
    V3out = 0.5 * model.kf * (model.l4 - model.lout(:, 2)).^2;
    V4out = 0.5 * model.kt * (2 * phout).^2;
    Vout = V1out + V2out + V3out + V4out;
    %Total Energy
    Eout = [T1out, T2out, V1out, V2out, V3out, V4out, Tout + Vout];
end
