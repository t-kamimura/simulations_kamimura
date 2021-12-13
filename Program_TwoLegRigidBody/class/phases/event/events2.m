function [value, isterminal, direction] = events2(y, model)
    % Hind leg stanceの終端イベント
    xg = y(1);
    yg = y(2);
    theta = y(3);

    fore_toeHight = yg + model.L .* sin(theta) - model.l4 * cos(model.gamma_f_td);

    HipB = [xg - model.L .* cos(theta); yg - model.L .* sin(theta)];
    lh_x = model.xh_toe - HipB(1);
    lh_y = HipB(2);
    lh_length = sqrt(lh_x^2 + lh_y^2) - model.lh;

    value = [fore_toeHight; lh_length; yg];
    isterminal = [1; 1; 1];
    direction = [-1; 1; 0];
end