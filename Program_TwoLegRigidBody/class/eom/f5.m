function dqdt1 = f5(y,model)
     param = [model.m  model.J  model.L model.l3 model.l4 model.g];   
   
    % state variables
    xg = y(1);
    yg = y(2);
    theta= y(3);
    dxg = y(4);
    dyg = y(5);
    dtheta = y(6);
        
    q = [xg yg theta];
    dq = [dxg dyg dtheta];
    
     % Inertia matrix
    M = myMassMatrix_F(q, param);
    % Colioris and gravity
    f_cg = myF_CoriGrav_F(q, dq, param);
    % acceleration
    dd_q = M\(-f_cg);
    
    dqdt1 = [dxg ; dyg ;  dtheta ; dd_q(1) ; dd_q(2) ; dd_q(3)];

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
