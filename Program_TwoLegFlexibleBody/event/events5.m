function [value, isterminal, direction] = events5(q, model)
    % flight phaseの終端イベント
    x = q(1);
    y = q(2);
    theta = q(3);
    phi = q(4);
    dx = q(5);
    dy = q(6);
    % xg = y(1);
    % yg = y(2);
    % theta = y(3);
    % dxg = y(4);
    % dyg = y(5);

    hind_toeHight = y - model.L .* cos(phi) .* sin(theta) - model.D .* sin(theta - phi) - model.l3 * cos(model.gamma_h_td);
    
    fore_toeHight = y + model.L .* cos(phi) .* sin(theta) + model.D .* sin(theta + phi) - model.l4 * cos(model.gamma_f_td);
    
    value = [dy; hind_toeHight; fore_toeHight; y];
    isterminal = [1; 1; 1; 1];
    direction = [-1; -1; -1; 0];

end