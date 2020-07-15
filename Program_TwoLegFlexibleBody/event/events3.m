function [value, isterminal, direction] = events3(q, model)
    % double leg stanceの終端イベント
    x = q(1);
    y = q(2);
    theta = q(3);
    phi = q(4);

    HipB(1) = x - model.L * cos(phi) * cos(theta)- model.D * cos(theta - phi);
    HipB(2) = y - model.L * cos(phi) * sin(theta) - model.D * sin(theta - phi);
    lh_x = model.xh_toe - HipB(1);
    lh_y = HipB(2);
    lh_length = sqrt(lh_x^2 + lh_y^2) - model.lh;
    % HipB(1) = xg - model.L * cos(theta);
    % HipB(2) = yg - model.L * sin(theta);
    % lb_x = model.xh_toe - HipB(1);
    % lb_y = HipB(2);
    % lb_length = sqrt(lb_x^2 + lb_y^2) - model.lh;

    
    Head(1) = x + model.L * cos(phi) * cos(theta) + model.D * cos(theta + phi);
    Head(2) = y + model.L * cos(phi) * sin(theta) + model.D * sin(theta + phi);
    lf_x = model.xf_toe - Head(1);
    lf_y = Head(2);
    lf_length = sqrt(lf_x^2 + lf_y^2) - model.lf;
    % Head(1) = xg + model.L * cos(theta);
    % Head(2) = yg + model.L * sin(theta);
    % lf_x = model.xf_toe - Head(1);
    % lf_y = Head(2);
    % lf_length = sqrt(lf_x^2 + lf_y^2) - model.lf;

    value = [lh_length; lf_length; y];
    isterminal = [1; 1; 1];
    direction = [1; 1; 0];
end