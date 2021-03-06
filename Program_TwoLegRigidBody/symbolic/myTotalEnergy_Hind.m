function E = myTotalEnergy_Hind(in1,in2,in3)
%MYTOTALENERGY_HIND
%    E = MYTOTALENERGY_HIND(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    01-Jul-2020 15:20:03

J = in3(:,2);
L = in3(:,7);
dtheta = in2(:,3);
dx = in2(:,1);
dy = in2(:,2);
g = in3(:,10);
kh = in3(:,3);
l3 = in3(:,8);
m = in3(:,1);
theta = in1(:,3);
x = in1(:,1);
xh_toe = in3(:,5);
y = in1(:,2);
E = (J.*dtheta.^2)./2.0+(kh.*(l3-sqrt((-x+xh_toe+L.*cos(theta)).^2+(y-L.*sin(theta)).^2)).^2)./2.0+(m.*(dx.^2+dy.^2))./2.0+g.*m.*y;
