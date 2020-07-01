function [value, isterminal, direction] = events3(y, model)
    % double leg stanceの終端イベント
    
    xg = y(1);
    yg = y(2);
    theta = y(3);

    HipB(1) = xg - model.L * cos(theta);
    HipB(2) = yg - model.L * sin(theta);
    lb_x = model.xh_toe - HipB(1);
    lb_y = HipB(2);
    lb_length = sqrt(lb_x^2 + lb_y^2) - model.lh;

    Head(1) = xg + model.L * cos(theta);
    Head(2) = yg + model.L * sin(theta);
    lf_x = model.xf_toe - Head(1);
    lf_y = Head(2);
    lf_length = sqrt(lf_x^2 + lf_y^2) - model.lf;

    value = [lb_length; lf_length; yg];
    isterminal = [1; 1; 1];
    direction = [1; 1; 0];
end