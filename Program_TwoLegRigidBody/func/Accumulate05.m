function [model] = Accumulate05(t,q,te,qe,ie,model)

nt = length(t);
model.eveflgout = [model.eveflgout;ones(nt-1,1)*model.eveflg]; 
if isempty(ie)
%     disp('ie is empty event did not occured @phase5')
    model.eveflg = 20;
elseif ie(1) == 1
%      disp('reached apex height@phase5')
    model.eveflg = 1;
else
%     disp('error @phase5')
%     ie
    model.eveflg = 30;
end


model.tout = [model.tout; t(2:nt)];
model.qout = [model.qout; q(2:nt,:)];

model.lout = [model.lout; ones(nt - 1, 1) * model.lh, ones(nt - 1, 1) * model.lf];
model.gout = [model.gout; ones(nt - 1, 1) * model.gamma_h_td, ones(nt - 1, 1) * model.gamma_f_td];

model.teout = [model.teout; te(1)];
model.qeout = [model.qeout; qe(1,:)];
model.ieout = [model.ieout; ie(1)];
       
end