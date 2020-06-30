function dqdt1 = f4(t,states,param,param_ctrl)

    % state variables
    xg = states(1);
    yg = states(2);
    theta= states(3);
    dxg = states(4);
    dyg = states(5);
    dtheta = states(6);

    q = [xg yg theta];
    dq = [dxg dyg dtheta];
   
    
    % Inertia matrix
    M = myMassMatrix_F(q, param);
    % Colioris and gravity
    f_cg = myF_CoriGrav_F(q, dq, param);
    % input torque
    tau = [0; myInputFunc_flight(q, dq, param_ctrl)];
    % acceleration
    dd_q = M\(f_cg+tau);

    dqdt1 = [dxg ; dyg ;  dtheta ; dd_q(1) ; dd_q(2) ; dd_q(3)];
   
end

%%-----------------------------------------------------------------------

%function dydt1 = f4(y,model)
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

%M = [model.m 0 0;
%   0 model.m 0;
%   0 0 model.I];
%G = model.xf_toe - model.L*cos(theta) -xg;
%H = yg + model.L*sin(theta);
%lft = sqrt(G^2+H^2);


%dd_q = (model.kf*(lft-model.lf)/lft)*(M\[G ; -H;  -G*model.L*sin(theta)-H*model.L*cos(theta)])+...
%    [0; -model.g; 0];

% dydt1 = [dx1
%        dy1
%       dtheta
%        dd_q(1)
%        dd_q(2)
%        dd_q(3)];
