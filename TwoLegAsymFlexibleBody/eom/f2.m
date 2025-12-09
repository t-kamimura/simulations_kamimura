function dqdt1 = f2(q,model)

    %hind stance phase
    param = [model.m model.J model.kh model.kt model.xh_toe model.gamma_h_td model.L model.l3  model.D model.g]; 
    
    % state variables
    x = q(1);
    y = q(2);
    theta= q(3);
    phi = q(4);
    dx = q(5);
    dy = q(6);
    dtheta = q(7);
    dphi = q(8);
        
    q = [x y theta phi];
    dq = [dx dy dtheta dphi];
    
     % Inertia matrix
    M = myMassMatrix_Hind(q, param);
    % Colioris and gravity
    f_cg = myF_CoriGrav_Hind(q, dq, param);
    % acceleration
    dd_q = M\(-f_cg);
    
    dqdt1 = [dx ; dy ;  dtheta ; dphi ;  dd_q(1) ; dd_q(2) ; dd_q(3) ; dd_q(4)];

end


%function dydt1 = f2(y, model)
    % Leg4 Stance
    % dd_q = inv(M) * f
    % f = f_cg + f_cont,
    % y =  [x y theta1 theta2 dx dy dtheta1 dtheta2];
    %xg = y(1);
    %yg = y(2);
    %theta = y(3);
    %dx1 = y(4);
    %dy1 = y(5);
    %dtheta = y(6);

    %M = [model.m 0 0;
     %   0 model.m 0;
      %  0 0 model.I];
    
    
    %A = model.xb_toe + model.L * cos(theta) -xg;
    %A = -model.xb_toe + model.L * cos(theta) -xg;?
    %B = -yg + model.L * sin(theta);
    %lbt = sqrt(A^2 + B^2);

    %dd_q = (model.kb * (-model.lb + lbt) / lbt) * (M \ [A; B; A * model.L * sin(theta) - B * model.L * cos(theta)]) + ...
     %   [0; -model.g; 0];

    %dydt1 = [dx1
    %    dy1
    %    dtheta
    %    dd_q(1)
    %    dd_q(2)
     %   dd_q(3)];
%end
