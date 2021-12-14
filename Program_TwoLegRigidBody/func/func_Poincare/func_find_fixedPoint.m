function logData = func_find_fixedPoint(model, q_constants, u_ini)

    % 今回，解を探す関数の定義．入力uを計算することになる
    myNeutonFunc = @(u) bound_once(model, q_constants, u);
    % options = optimset('Algorithm','levenberg-marquardt','Display','iter'); %debug
    options = optimset('Algorithm','levenberg-marquardt','Display','none');

    % Newton法実行
    [u_fix, fval, exitFlag, output, jacobi] = fsolve(myNeutonFunc, u_ini, options);

    fsolveResult.fval = fval;
    fsolveResult.exitFlag = exitFlag;
    fsolveResult.output = output;
    fsolveResult.jacobi = jacobi;
    
    % 結果をまとめる
    logData = make_log(model, q_constants, u_fix, fsolveResult);

end % func_find_fixedPoint