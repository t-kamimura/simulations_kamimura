function [value, isterminal, direction] = events1(q, model)
    % Flight phaseの終端イベント
    x = q(1);
    y = q(2);
    theta = q(3);
    phi = q(4);

    hind_toeHight = y - model.L * cos(phi) * sin(theta) - model.D * sin(theta - phi) - model.l3 * cos(model.gamma_h_td);
    fore_toeHight = y + model.L * cos(phi) * sin(theta) + model.D * sin(theta + phi) - model.l4 * cos(model.gamma_f_td);

    
    value = [hind_toeHight; fore_toeHight; y];
    isterminal = [1; 1; 1];
    direction = [-1; -1; 0];
end