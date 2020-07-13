function [value, isterminal, direction] = events2(q, model)
    % Hind leg stanceの終端イベント
    x = q(1);
    y = q(2);
    theta = q(3);
    phi = q(4);

    fore_toeHight = y + model.L * cos(phi) * sin(theta) + model.D * sin(theta + phi) - model.l4 * cos(model.gamma_f_td);
    % fore_toeHight = yg + model.L .* sin(theta) - model.l4 * cos(model.gamma_f_td);

    HipB = [x - L * cos(phi) * cos(theta)- D * cos(theta - phi) ; y - L * cos(phi) * sin(theta) - D * sin(theta - phi)];
    lh_x = model.xh_toe - HipB(1);
    lh_y = HipB(2);
    lh_length = sqrt(lh_x^2 + lh_y^2) - model.lh;
    % HipB = [x - model.L .* cos(theta); yg - model.L .* sin(theta)];
    % lh_x = model.xh_toe - HipB(1);
    % lh_y = HipB(2);
    % lh_length = sqrt(lh_x^2 + lh_y^2) - model.lh;

    value = [fore_toeHight; lh_length; y];
    isterminal = [1; 1; 1];
    direction = [-1; 1; 0];
end