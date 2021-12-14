function fixedPoints = keep_logData(fixedPoints, logData)
    if logData.fsolveResult.exitFlag > 0
        % まともな解が見つかっていたら

        n = length(fixedPoints);

        if n == 0
            fprintf('*');
            fixedPoints = logData;
        else
            newFlag = doubling_check(fixedPoints,logData.u_fix);

            if newFlag == true
                % 新しい解が見つかった
                fprintf('*');
                fixedPoints(n+1) = logData;
            else
                fprintf('-')
            end

        end % if n==o

    else
        fprintf('.');
    end % if exitflag

end % keep_logData

function newFlag = doubling_check(fixedPoints,u_fix)
    
    newFlag = true;

    for i_sol = 1:length(fixedPoints)

        if abs(u_fix - fixedPoints(i_sol).u_fix) < 1e-3
            newFlag = false;
            break
        end

    end
end % doubling_check