function M = myMassMatrix_Fore(in1,in2)
%MYMASSMATRIX_FORE
%    M = MYMASSMATRIX_FORE(IN1,IN2)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    19-Jun-2020 11:44:14

J = in2(:,2);
l = in2(:,8);
m = in2(:,1);
M = reshape([m,0.0,0.0,0.0,m,0.0,0.0,0.0,J.*l.^2.*m],[3,3]);