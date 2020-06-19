function E = myTotalEnergy_Fore(in1,in2,in3)
%MYTOTALENERGY_FORE
%    E = MYTOTALENERGY_FORE(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    19-Jun-2020 12:25:59

J = in3(:,2);
dtheta = in2(:,3);
dx = in2(:,1);
dy = in2(:,2);
g = in3(:,10);
kf = in3(:,4);
l = in3(:,8);
l0 = in3(:,9);
m = in3(:,1);
theta = in1(:,3);
x = in1(:,1);
xf_toe = in3(:,5);
y = in1(:,2);
E = (kf.*(l0-sqrt((x-xf_toe+l.*cos(theta)).^2+(y+l.*sin(theta)).^2)).^2)./2.0+(m.*(dx.^2+dy.^2))./2.0+g.*m.*y+(J.*dtheta.^2.*l.^2.*m)./2.0;
