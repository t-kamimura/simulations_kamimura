function dqdt = f5(t,q,model)

    model.kt = set_kt(t,model);
    param = [model.m  model.J model.kt model.L model.l3 model.l4 model.g]; 
    % param = [model.m  model.J  model.L model.l3 model.l4 model.g];   
   
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
    M = myMassMatrix_F(q, param);
    % Colioris and gravity
    f_cg = myF_CoriGrav_F(q, dq, param);
    % acceleration
    dd_q = M\(-f_cg);
    
    dqdt = [dx ; dy ;  dtheta ; dphi ;  dd_q(1) ; dd_q(2) ; dd_q(3) ; dd_q(4)];

end




%%-----------------------------------------------



%function dydt1 = f5(t,y,gfout,gbout,g,alph,lf,lb,m,I,L,kf,kb)
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
%        dy1
%        dtheta
%        0
%       -g
%        0];
