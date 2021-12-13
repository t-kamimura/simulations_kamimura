function dqdt1 = eom_flight(t,states,param,param_ctrl)
    
    % state variables
    y = states(1);
    theta1 = states(2);
    theta2 = states(3);
    dy = states(4);
    dtheta1 = states(5);
    dtheta2 = states(6);
    
    q = [y theta1 theta2];
    dq = [dy dtheta1 dtheta2];
    
    % Inertia matrix
    M = myMassMatrix_F(q, param);
    % Colioris and gravity
    f_cg = myF_CoriGrav_F(q, dq, param);
    % input torque
    tau = [0; myInputFunc_flight(q, dq, param_ctrl)];
    % acceleration
    dd_q = M\(f_cg+tau);

    dqdt1 = [dy; dtheta1; dtheta2; dd_q(1); dd_q(2); dd_q(3)];
end


