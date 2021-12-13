function dydt1 = f3(y,model)
%Leg4 Stance
%dd_q = inv(M) * f
%f = f_cg + f_cont, 
%y =  [x y theta1 theta2 dx dy dtheta1 dtheta2];
xg = y(1);
yg = y(2);
theta = y(3);
dx1 = y(4);
dy1 = y(5);
dtheta = y(6);

M = [model.m 0 0;
    0 model.m 0;
    0 0 model.I];
A = model.xb_toe + model.L*cos(theta) - xg;
B = -yg + model.L*sin(theta);
lbt = sqrt(A^2 + B^2);


df2 = model.xf_toe - model.xb_toe;
P = df2 + A - 2*model.L*cos(theta);
Q = B - 2*model.L*sin(theta);
lft = sqrt(P^2 + Q^2);


dd_q = (model.kb*(lbt-model.lb)/lbt)*(M\[+A ; +B ; +A*model.L*sin(theta)-B*model.L*cos(theta)])+...
       (model.kf*(lft-model.lf)/lft)*(M\[+P ; +Q ; -P*model.L*sin(theta)+Q*model.L*cos(theta)])+...
    [0; -model.g; 0];

dydt1 = [dx1
        dy1
        dtheta
        dd_q(1)
        dd_q(2)
        dd_q(3)];
