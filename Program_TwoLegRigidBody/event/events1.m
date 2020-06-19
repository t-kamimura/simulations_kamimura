function [value, isterminal, direction] = events1(y, model)
    % Flight phaseの終端イベント

    xg = y(1);
    yg = y(2);
    theta = y(3);

    hind_toeHight = yg - model.L .* sin(theta) - model.lb * cos(model.gb);
    fore_toeHight = yg + model.L .* sin(theta) - model.lf * cos(model.gf);

    value = [hind_toeHight; fore_toeHight; yg];
    isterminal = [1; 1; 1];
    direction = [-1; -1; 0];
end