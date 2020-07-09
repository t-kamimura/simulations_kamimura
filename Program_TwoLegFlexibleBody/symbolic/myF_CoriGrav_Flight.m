function f_cg = myF_CoriGrav_Flight(in1,in2,in3)
%MYF_CORIGRAV_FLIGHT
%    F_CG = MYF_CORIGRAV_FLIGHT(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    09-Jul-2020 17:47:10

dphi = in2(:,4);
dtheta = in2(:,3);
g = in3(:,10);
kt = in3(:,3);
l = in3(:,8);
m = in3(:,1);
phi = in1(:,4);
theta = in1(:,3);
t2 = cos(phi);
t3 = cos(theta);
t4 = sin(phi);
t5 = sin(theta);
t6 = dphi.^2;
t7 = dtheta.^2;
t8 = l.^2;
t9 = t3.^2;
t10 = t5.^2;
f_cg = [-l.*m.*(t2.*t3.*t6+t2.*t3.*t7-dphi.*dtheta.*t4.*t5.*2.0);m.*(g.*2.0+l.*t2.*t5.*t6+l.*t2.*t5.*t7+dphi.*dtheta.*l.*t3.*t4.*2.0);m.*t2.*t8.*(dphi.*dtheta.*t4.*-3.0+dphi.*dtheta.*t4.*t9.*2.0+t2.*t3.*t5.*t6+t2.*t3.*t5.*t7).*2.0;kt.*phi.*4.0+m.*t2.*t4.*t6.*t8.*t9.*3.0+m.*t2.*t4.*t6.*t8.*t10+m.*t2.*t4.*t7.*t8.*t9.*3.0+m.*t2.*t4.*t7.*t8.*t10-dphi.*dtheta.*m.*t3.*t4.^2.*t5.*t8.*4.0];
