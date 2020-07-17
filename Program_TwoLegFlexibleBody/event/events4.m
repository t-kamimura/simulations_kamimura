function [value, isterminal, direction] = events4(q, model)

    % Fore leg stance の終端イベント
    x = q(1);
    y = q(2);
    theta = q(3);
    phi = q(4);

    hind_toeHight = y - model.L * cos(phi) * sin(theta) - model.D * sin(theta - phi) - model.l3 * cos(model.gamma_h_td);
    % hind_toeHight = yg - model.L .* sin(theta) - model.l3 * cos(model.gamma_h_td);

    Head = [ x + model.L * cos(phi) * cos(theta) + model.D * cos(theta + phi) ; y + model.L * cos(phi) * sin(theta) + model.D * sin(theta + phi)];
    lf_x = model.xf_toe - Head(1);
    lf_y = Head(2);
    lf_length = sqrt(lf_x^2 + lf_y^2) - model.l4;
    % Head = [xg + model.L .* cos(theta); yg + model.L .* sin(theta)];
    % lf_x = model.xf_toe - Head(1);
    % lf_y = Head(2);
    % lf_length = sqrt(lf_x^2 + lf_y^2) - model.lf;

    value = [hind_toeHight; lf_length; y];
    isterminal = [1; 1; 1];
    direction = [-1; 1; 0];
end
