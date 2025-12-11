% Double flight stance
function dqdt = f1(t, q,model)
    % spring constant setting
    model.kt = set_kt(t,model);
    param = [model.m  model.J model.kt model.L model.l3 model.l4 model.g];
      
    % state variables
    x = q(1);
    y = q(2);
    theta = q(3);
    phi = q(4);
    dx = q(5);
    dy = q(6);
    dtheta = q(7);
    dphi = q(8);
        
    q = [x y theta phi];
    dq = [dx dy dtheta dphi];
    
    % Inertia matrix
    M = myMassMatrixflight(q, param);
    % Coriolis and gravity
    f_cg = myF_CoriGrav_Flight(q, dq, param);
    % Dissipation
    f_diss = my_diss(dq, model);
    % Acceleration
    dd_q = M\(-f_cg - f_diss);
    
    dqdt = [dx; dy;  dtheta; dphi; dd_q(1); dd_q(2); dd_q(3); dd_q(4)];

end