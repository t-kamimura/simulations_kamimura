function [eigenValues, eivenVectors, jacobi] = calc_eigenvalue(model, q_fix, u_fix)
    dz = 1e-6;

    % q_fix = [];
    % u_fix = [];

    x_fix = q_fix(1);
    y_fix = q_fix(2);
    theta_fix = q_fix(3);
    phi_fix = q_fix(4);
    dx_fix = q_fix(5);
    dy_fix = q_fix(6);
    dtheta_fix = q_fix(7);
    dphi_fix = q_fix(8);

    % z_fix = [y_fix dx_fix dtheta_fix];
    z_fix = [y_fix theta_fix phi_fix dx_fix dtheta_fix dphi_fix];

    % 摂動がない場合の計算
    model.init;
    model.bound(q_fix, u_fix);
    q_err = model.q_err;
    y_err_max = max(abs(model.qout(end, 2) - q_fix(2)));

    jacobian = zeros(6, 6);

    for i_z = 1:6
        % 摂動を足す場合の計算
        z_fix_plus = z_fix;
        z_fix_plus(i_z) = z_fix_plus(i_z) + dz;
        q_fix_plus = [x_fix, z_fix_plus(1), z_fix_plus(2), z_fix_plus(3), z_fix_plus(4), dy_fix, z_fix_plus(5) z_fix_plus(6)];
        model.init;
        model.bound(q_fix_plus, u_fix);
        zend_plus(1) = model.qout(end, 2); % y
        zend_plus(2) = model.qout(end, 3); % theta
        zend_plus(3) = model.qout(end, 4); % phi
        zend_plus(4) = model.qout(end, 5); % dx
        zend_plus(5) = model.qout(end, 7); % dtheta
        zend_plus(6) = model.qout(end, 8); % dphi

        % 摂動を引く場合の計算
        z_fix_minus = z_fix;
        z_fix_minus(i_z) = z_fix_plus(i_z) - dz;
        q_fix_minus = [x_fix, z_fix_minus(1), z_fix_minus(2), z_fix_minus(3), z_fix_minus(4), dy_fix, z_fix_minus(5) z_fix_minus(6)];
        model.init;
        model.bound(q_fix_minus, u_fix);
        zend_minus(1) = model.qout(end, 2); % y
        zend_minus(2) = model.qout(end, 3); % theta
        zend_minus(3) = model.qout(end, 4); % phi
        zend_minus(4) = model.qout(end, 5); % dx
        zend_minus(5) = model.qout(end, 7); % dtheta
        zend_minus(6) = model.qout(end, 8); % dphi

        % 中央差分でヤコビアンを近似
        jacobi(:, i_z) = 0.5 * (zend_plus - zend_minus)' / dz;
    end

    [eivenVectors, eigenValues] = eig(jacobi);
end
