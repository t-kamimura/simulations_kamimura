function E = myTotalEnergy_Fore(in1,in2,in3)
%MYTOTALENERGY_FORE
%    E = MYTOTALENERGY_FORE(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    01-Jul-2020 14:52:21

J = in3(:,2);
L = in3(:,8);
dtheta = in2(:,3);
dx = in2(:,1);
dy = in2(:,2);
g = in3(:,11);
kf = in3(:,4);
l4 = in3(:,10);
m = in3(:,1);
theta = in1(:,3);
x = in1(:,1);
xf_toe = in3(:,5);
y = in1(:,2);
E = (J.*dtheta.^2)./2.0+(kf.*(l4-sqrt((x-xf_toe+L.*cos(theta)).^2+(y+L.*sin(theta)).^2)).^2)./2.0+(m.*(dx.^2+dy.^2))./2.0+g.*m.*y;
