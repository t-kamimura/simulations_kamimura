
    function dqdt1 = f1(t, q,model)
    %double flight stance
    if rem(t,T)
        % 硬くする
        model.kt = model.ke;
    else
        % 柔らかくする
        model.kt = model.kg;
    end
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
    % Colioris and gravity
    f_cg = myF_CoriGrav_Flight(q, dq, param);
    % acceleration
    dd_q = M\(-f_cg);
    
    dqdt1 = [dx ; dy ;  dtheta ; dphi ; dd_q(1) ; dd_q(2) ; dd_q(3) ; dd_q(4)];
    % dqdt1 = [dxg ; dyg ;  dtheta ; dd_q(1) ; dd_q(2) ; dd_q(3)];

    end


    
    
    
%function dydt1 = f1(y,model)
%Leg4 Stance
%dd_q = inv(M) * f
%f = f_cg + f_cont, 
%y =  [x y theta1 theta2 dx dy dtheta1 dtheta2];
%xg = y(1);
%yg = y(2);
%theta = y(3);
%dx1 = y(4);
%dy1 = y(5);
%dtheta = y(6);

%dydt1 = [dx1
%       dy1
%       dtheta
%       0
%       -model.g
%       0];

    