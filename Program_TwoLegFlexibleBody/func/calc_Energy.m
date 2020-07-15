function Eout = calc_Energy(model)
    xout = model.qout(:, 1);
    yout = model.qout(:, 2);
    thout = model.qout(:, 3);
    phout = model.qout(:, 4);
    dxout = model.qout(:, 5);
    dyout = model.qout(:, 6);
    dthout = model.qout(:, 7);
    dphout = model.qout(:, 8);
    
    % syms m J kt xh yh xf yf dxh dyh dxf dyf
    % syms kh kf kt
    % syms xf_toe xh_toe gamma_h_td gamma_f_td% x*_toe :足先位置
    % syms L l3 l4 D
    % syms g
    % param = [m J kh kf kt xf_toe xh_toe gamma_h_td gamma_f_td L l3 l4 D g];
    
    param = [model.m model.J model.kh model.kf model.kt model.xf_toe model.xh_toe model.gamma_h_td model.gamma_f_td model.L model.l3 model.l4 model.D model.g];
    

    xh = model.qout(:, 1) - model.L .* cos(model.qout(:, 4)) .* cos(model.qout(:, 3));
    yh = model.qout(:, 2) - model.L .* cos(model.qout(:, 4)) .* sin(model.qout(:, 3));
    xf = model.qout(:, 1) + model.L .* cos(model.qout(:, 4)) .* cos(model.qout(:, 3));
    yf = model.qout(:, 2) + model.L .* cos(model.qout(:, 4)) .* sin(model.qout(:, 3));
    dxh = model.qout(:, 5) + (model.qout(:, 7)).^2 .* model.L .* sin(model.qout(:, 3)) .* cos(model.qout(:, 4)) + (model.qout(:, 8)).^2 .* model.L .* sin(model.qout(:, 4)) .* cos(model.qout(:, 3)); 
    dyh = model.qout(:, 6) - (model.qout(:, 7)).^2 .* model.L .* cos(model.qout(:, 4)) .* cos(model.qout(:, 3)) + (model.qout(:, 8)).^2 .* model.L .* sin(model.qout(:, 4)) .* sin(model.qout(:, 3));
    dxf = model.qout(:, 5) - (model.qout(:, 7)).^2 .* model.L .* sin(model.qout(:, 3)) .* cos(model.qout(:, 4)) - (model.qout(:, 8)).^2 .* model.L .* sin(model.qout(:, 4)) .* cos(model.qout(:, 3));
    dyf = model.qout(:, 6) + (model.qout(:, 7)).^2 .* model.L .* cos(model.qout(:, 4)) .* cos(model.qout(:, 3)) - (model.qout(:, 8)).^2 .* model.L .* sin(model.qout(:, 4)) .* sin(model.qout(:, 3));


    % 運動エネルギー
    T1out = 0.5 * model.m * (dxh .^2 + dyh .^2) + 0.5 * model.m * (dxf .^2 +dyf .^2);
    T2out = model.J * ((model.qout(:, 7)) .^2 + (model.qout(:, 8)).^2);
    Tout = T1out + T2out;

    V1out = 2 * model.m * model.g * yout;
    V2out = 0.5 * model.kh * (model.l3 - model.lout(:, 1)).^2;
    V3out = 0.5 * model.kf * (model.l4 - model.lout(:, 2)).^2;
    V4out = 0.5 * model.kt * (2 * model.qout(:, 4)).^2; 
    Vout = V1out + V2out + V3out + V4out;
    %Total Energy
    Eout = [T1out, T2out, V1out, V2out, V3out, V4out , Tout + Vout];
end