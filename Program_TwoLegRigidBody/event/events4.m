function [value, isterminal, direction] = events4(y, model)

    % Fore leg stance の終端イベント

    xg = y(1);
    yg = y(2);
    theta = y(3);

    hind_toeHight = yg - model.L .* sin(theta) - model.l3 * cos(model.gb);

    Head = [xg + model.L .* cos(theta); yg + model.L .* sin(theta)];
    lf_x = model.xf_toe - Head(1);
    lf_y = Head(2);
    lf_length = sqrt(lf_x^2 + lf_y^2) - model.lf;

    value = [hind_toeHight; lf_length; yg];
    isterminal = [1; 1; 1];
    direction = [-1; 1; 0];
end
