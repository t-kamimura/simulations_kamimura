function [value, isterminal, direction] = events2(y, model)
    % Hind leg stanceの終端イベント
    xg = y(1);
    yg = y(2);
    theta = y(3);

    fore_toeHight = yg + model.L .* sin(theta) - model.l4 * cos(model.gf);

    HipB = [xg - model.L .* cos(theta); yg - model.L .* sin(theta)];
    lb_x = model.xb_toe - HipB(1);
    lb_y = HipB(2);
    lb_length = sqrt(lb_x^2 + lb_y^2) - model.lb;

    value = [fore_toeHight; lb_length; yg];
    isterminal = [1; 1; 1];
    direction = [-1; 1; 0];
end