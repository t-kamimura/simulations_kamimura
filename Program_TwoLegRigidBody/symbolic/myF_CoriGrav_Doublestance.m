function f_cg = myF_CoriGrav_Doublestance(in1,in2,in3)
%MYF_CORIGRAV_DOUBLESTANCE
%    F_CG = MYF_CORIGRAV_DOUBLESTANCE(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    01-Jul-2020 14:52:12

L = in3(:,9);
g = in3(:,12);
kf = in3(:,4);
kh = in3(:,3);
l3 = in3(:,10);
l4 = in3(:,11);
m = in3(:,1);
theta = in1(:,3);
x = in1(:,1);
xf_toe = in3(:,5);
xh_toe = in3(:,6);
y = in1(:,2);
t2 = cos(theta);
t3 = sin(theta);
t4 = x.*2.0;
t5 = y.*2.0;
t10 = -x;
t11 = -xf_toe;
t6 = L.*t2;
t7 = L.*t3;
t8 = t2.*y;
t9 = t3.*x;
t12 = t6.*2.0;
t13 = t7.*2.0;
t14 = t7+y;
t15 = -t7;
t16 = -t9;
t19 = t6+t11+x;
t20 = t6+t10+xh_toe;
t21 = (t7-y).^2;
t17 = t15+y;
t18 = t14.^2;
t22 = t19.^2;
t23 = t20.^2;
t24 = t18+t22;
t25 = t21+t23;
t26 = sqrt(t24);
t28 = sqrt(t25);
t27 = 1.0./t26;
t29 = 1.0./t28;
t30 = -t26;
t32 = -t28;
t31 = l4+t30;
t33 = l3+t32;
f_cg = [(kh.*t29.*t33.*(-t4+t12+xh_toe.*2.0))./2.0-(kf.*t27.*t31.*(t4+t12-xf_toe.*2.0))./2.0;g.*m-(kh.*t29.*t33.*(t5-t13))./2.0-(kf.*t27.*t31.*(t5+t13))./2.0;-L.*kf.*t27.*t31.*(t8+t16+t3.*xf_toe)+L.*kh.*t29.*t33.*(t8+t16+t3.*xh_toe)];
