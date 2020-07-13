function E = myTotalEnergxflight(in1,in2,in3)
%MYTOTALENERGXFLIGHT
%    E = MYTOTALENERGXFLIGHT(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    13-Jul-2020 17:09:40

J = in3(:,2);
dphi = in2(:,4);
dtheta = in2(:,3);
g = in3(:,7);
kt = in3(:,3);
m = in3(:,1);
phi = in1(:,4);
y = in1(:,2);
E = J.*(dphi.^2+dtheta.^2)+kt.*phi.^2.*2.0+g.*m.*y.*2.0;
