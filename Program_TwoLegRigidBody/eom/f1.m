function dydt1 = f1(y,model)
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

dydt1 = [dx1
        dy1
        dtheta
        0
        -model.g
        0];
