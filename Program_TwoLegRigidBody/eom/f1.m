
    function dqdt1 = f1(t,states,param,param_ctrl)
    %double flight stance        
        
    % state variables
    xg = states(1);
    yg = states(2);
    theta= states(3);
    dxg = states(4);
    dyg = states(5);
    dtheta = states(6);
        
    q = [xg yg theta];
    dq = [dxg dyg dtheta];
    
    dqdt1 = [dxg ; dyg ;  dtheta ; dd_q(1) ; dd_q(2) ; dd_q(3)];

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

    