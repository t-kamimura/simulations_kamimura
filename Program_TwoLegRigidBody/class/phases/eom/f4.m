function dqdt1 = f4(y, model)
    %fore stance phase
    param = [model.m model.J model.kh model.kf model.xf_toe model.gamma_h_td model.gamma_f_td model.L model.l3 model.l4 model.g];
      
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
    M = myMassMatrix_Fore(q, param);
    % Colioris and gravity
    f_cg = myF_CoriGrav_Fore(q, dq, param);
    % acceleration
    dd_q = M\(-f_cg);
    
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
