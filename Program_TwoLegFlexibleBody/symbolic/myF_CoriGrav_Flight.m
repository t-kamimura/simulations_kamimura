function f_cg = myF_CoriGrav_Flight(in1,in2,in3)
%MYF_CORIGRAV_FLIGHT
%    F_CG = MYF_CORIGRAV_FLIGHT(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    14-Jul-2020 12:02:20

L = in3(:,4);
dphi = in2(:,4);
dtheta = in2(:,3);
g = in3(:,7);
kt = in3(:,3);
m = in3(:,1);
phi = in1(:,4);
t2 = L.^2;
t3 = phi.*2.0;
t4 = sin(t3);
f_cg = [0.0;g.*m.*2.0;dphi.*dtheta.*m.*t2.*t4.*-2.0;kt.*phi.*4.0+dphi.^2.*m.*t2.*t4+dtheta.^2.*m.*t2.*t4];
