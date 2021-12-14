function F = make_movie(teq, pointPos, movieOptions)

    h1 = figure;
    set(h1, 'DoubleBuffer', 'off');

    axis equal

    xlim([-0.5 max([pointPos.x_head]) + 0.2])
    ylim([-0.2 1.3])
    
    body    = line([pointPos(1).x_hip,  pointPos(1).x_head],   [pointPos(1).y_hip,  pointPos(1).y_head],   'color', 'k', 'LineWidth', 3);
    hindLeg = line([pointPos(1).x_hip,  pointPos(1).x_foot_b], [pointPos(1).y_hip,  pointPos(1).y_foot_b], 'color', 'r', 'LineWidth', 3);
    foreLeg = line([pointPos(1).x_head, pointPos(1).x_foot_f], [pointPos(1).y_head, pointPos(1).y_foot_f], 'color', 'b', 'LineWidth', 3);
    
    ground = line([-0.5 max([pointPos.x_head]) + 0.2], [0, 0], 'color', 'k', 'LineWidth', 1);

    strng = [num2str(0, '%.2f'), ' s'];
    t = text(0, -0.1, strng, 'color', 'k', 'fontsize', 16);

    strng2 = ['x', num2str(movieOptions.speed, '%.2f')];
    t2 = text(max([pointPos.x_head]) - 0.1, -0.1, strng2, 'color', 'k', 'fontsize', 16);

    F = [];

    for i_t = 1:length(pointPos)
        body.XData =    [pointPos(i_t).x_hip,  pointPos(i_t).x_head];
        body.YData =    [pointPos(i_t).y_hip,  pointPos(i_t).y_head];
        hindLeg.XData = [pointPos(i_t).x_hip,  pointPos(i_t).x_foot_b];
        hindLeg.YData = [pointPos(i_t).y_hip,  pointPos(i_t).y_foot_b];
        foreLeg.XData = [pointPos(i_t).x_head, pointPos(i_t).x_foot_f];
        foreLeg.YData = [pointPos(i_t).y_head, pointPos(i_t).y_foot_f];
        strng = [num2str(teq(i_t), '%.3f'), ' s'];
        t.String = strng;
        drawnow

        if movieOptions.saveFlag == true
            F = [F; getframe(h1)];
        end

    end
    
    if movieOptions.saveFlag == true
        save_movie(F, movieOptions);
    end
end % make_movie

function save_movie(F, movieOptions)
    videoobj = VideoWriter(['fig/movie.mp4'], 'MPEG-4');
    videoobj.FrameRate = movieOptions.FPS;
    fprintf('video saving...')
    open(videoobj);
    writeVideo(videoobj, F);
    close(videoobj);
    fprintf('complete!\n');
end % save_movie