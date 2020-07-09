function M = myMassMatrix_Fore(in1,in2)
%MYMASSMATRIX_FORE
%    M = MYMASSMATRIX_FORE(IN1,IN2)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    09-Jul-2020 17:53:10

J = in2(:,2);
l = in2(:,13);
m = in2(:,1);
phi = in1(:,4);
theta = in1(:,3);
t2 = cos(phi);
t3 = cos(theta);
t4 = sin(phi);
t5 = sin(theta);
t6 = J.*2.0;
t7 = l.^2;
t8 = t4.^2;
t9 = t5.^2;
t10 = l.*m.*t4.*t5;
t11 = l.*m.*t2.*t3;
t12 = l.*m.*t2.*t5;
t13 = l.*m.*t3.*t4;
t17 = m.*t2.*t3.*t4.*t5.*t7.*2.0;
t14 = -t11;
t15 = -t12;
t16 = -t13;
t18 = m.*t7.*t8.*t9.*2.0;
t19 = -t18;
M = reshape([m.*3.0,0.0,t15,t16,0.0,m,t14,t10,t15,t14,t6+t19+m.*t7-m.*t7.*t8+m.*t7.*t9.*2.0,t17,t16,t10,t17,t6+t19+m.*t7.*t8.*3.0],[4,4]);