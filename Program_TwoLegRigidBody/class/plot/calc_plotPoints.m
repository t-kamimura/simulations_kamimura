function pointPos = calc_plotPoints(model, trajectoryEq)
    anim_num = length(trajectoryEq.qout(:, 1));
    for i = 1:anim_num
        x  = trajectoryEq.qout(i, 1);
        y  = trajectoryEq.qout(i, 2);
        th = trajectoryEq.qout(i, 3);
        lh = trajectoryEq.lout(i, 1);
        lf = trajectoryEq.lout(i, 2);
        gh = trajectoryEq.gout(i, 1);
        gf = trajectoryEq.gout(i, 2);

        pointPos(i).x_hip  = x - model.L * cos(th);
        pointPos(i).y_hip  = y - model.L * sin(th);
        pointPos(i).x_head = x + model.L * cos(th);
        pointPos(i).y_head = y + model.L * sin(th);

        pointPos(i).x_foot_b = pointPos(i).x_hip  + lh * sin(gh);
        pointPos(i).y_foot_b = pointPos(i).y_hip  - lh * cos(gh);
        pointPos(i).x_foot_f = pointPos(i).x_head + lf * sin(gf);
        pointPos(i).y_foot_f = pointPos(i).y_head - lf * cos(gf);
    end

end