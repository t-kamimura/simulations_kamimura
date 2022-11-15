function E = myTotalEnergy_Flight(in1,in2,in3)
%MYTOTALENERGY_FLIGHT
%    E = MYTOTALENERGY_FLIGHT(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    01-Jul-2020 14:52:31

J = in3(:,2);
dtheta = in2(:,3);
dx = in2(:,1);
dy = in2(:,2);
g = in3(:,6);
m = in3(:,1);
y = in1(:,2);
E = (J.*dtheta.^2)./2.0+(m.*(dx.^2+dy.^2))./2.0+g.*m.*y;