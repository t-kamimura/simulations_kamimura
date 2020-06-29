function [value, isterminal, direction] = events5(y, model)
    % flight phaseの終端イベント
    
    xg = y(1);
    yg = y(2);
    theta = y(3);
    dxg = y(4);
    dyg = y(5);

    hind_toeHight = yg - model.L .* sin(theta) - model.lb * cos(model.gb);
    fore_toeHight = yg + model.L .* sin(theta) - model.lf * cos(model.gf);

    value = [dyg; hind_toeHight; fore_toeHight; yg];
    isterminal = [1; 1; 1; 1];
    direction = [-1; -1; -1; 0];

end