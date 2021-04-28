% fileName: swarm_rateEnergy.m
% initDate:　2021/2/26
% Object: swarm用 rateEnergy
clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaultAxesFontSize', 12);
set(0, 'defaultAxesFontName', 'times');
set(0, 'defaultTextFontSize', 16);
set(0, 'defaultTextFontName', 'times');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Construct a questdlg with three options
choice = questdlg('Do you want to save the result(s)?', ...
    'Saving opptions', ...
    'Yes', 'No', 'Yes');
% Handle response
saveflag = false;

switch choice
    case 'Yes'
        saveflag = true;
    case 'No'
        saveflag = false;
end



% path追加
addpath(pwd, 'class')
addpath(pwd, 'symbolic')
addpath(pwd, 'eom')
addpath(pwd, 'event')
addpath(pwd, 'func')
addpath(pwd, 'data')
addpath(pwd, 'fig')

model = Twoleg;

load('main_fixedPoints_for_y0=0.62_dx0=13,D=0.06,kt=220.mat')

for i = 1: length(fixedPoint)

    q_fix = fixedPoint(i).q_ini;
    u_fix(1) = fixedPoint(i).u_fix(1);
    u_fix(2) = fixedPoint(i).u_fix(2);
    
    [eigenValues, eivenVectors, jacobi] = calc_eigenvalue(model, q_fix, u_fix);
    
    diagonal = diag(eigenValues);
    logdata(i).eigenValue = diagonal;
    logdata(i).eivenVectors = eivenVectors;
    logdata(i).jacobi = jacobi;
    logdata(i).eeout = model.eeout;
    % logdata(i).trans = model.Eout(:,1) + model.Eout(:,2);
    % logdata(i).rot = model.Eout(:,3) + model.Eout(:,4);
    % logdata(i).grav = model.Eout(:,5);
    logdata(i).kh = model.Eout(:,6);
    logdata(i).kf = model.Eout(:,7);
    % logdata(i).kt = model.Eout(:,8);

    % logdata(i).compare = horzcat(logdata(i).kh, logdata(i).kf);
    % logdata(i).max = max(logdata(i).compare, [], 2);
    % logdata(i).MAX = max(logdata(i).max);
    
    % minus = (model.l3 - min(model.lout(:, 1))).^2 - (model.l4 - min(model.lout(:, 2))).^2
   
    logdata(i).hind_max = 0.5 * model.kh * (model.l3 - min(model.lout(:, 1))).^2;
    logdata(i).fore_max = 0.5 * model.kf * (model.l4 - min(model.lout(:, 2))).^2;
    logdata(i).horzcat = horzcat(logdata(i).hind_max, logdata(i).fore_max);
    logdata(i).MAX_ki = max(logdata(i).horzcat, [], 2);

    logdata(i).sum = model.Eout(:,9);
    logdata(i).rate = max(abs((logdata(i).MAX_ki)/(logdata(i).sum)));

end



figure  
xlabel('$$\dot{\theta}$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
%ylabel('\phi_0 [deg]')
zlabel('maxUi', 'interpreter', 'latex', 'Fontsize', 14);

for i = 1: length(fixedPoint)


    i_middle = round(length(fixedPoint(i).trajectory.tout)/2);   


    %double leg flightが二回ある歩容
    if logdata(i).eeout(3) ==1                                                                      

        %EE
        if fixedPoint(i).u_fix(3) > 0  &&  fixedPoint(i).trajectory.qout(i_middle, 4) > 0          

            %後脚から着地
            if fixedPoint(i).q_constants(3) > 0                                                           
                    plot(rad2deg(fixedPoint(i).q_constants(3)), logdata(i).rate, 'o','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')  
                    hold on    

            %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0                           
                    plot(rad2deg(fixedPoint(i).q_constants(3)), logdata(i).rate, 'o', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')    
                    hold on  
            end

        
        %GG
        elseif fixedPoint(i).u_fix(3)  < 0  && fixedPoint(i).trajectory.qout(i_middle, 4) < 0      

            %後脚から接地
            if fixedPoint(i).q_constants(3) > 0    
                    plot(rad2deg(fixedPoint(i).q_constants(3)), logdata(i).rate, 'o', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')      
                    hold on

            %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0   
                    plot(rad2deg(fixedPoint(i).q_constants(3)), logdata(i).rate, 'o','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')      
                    hold on

            end

        
        %EG
        elseif (fixedPoint(i).u_fix(3)) > 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) < 0            

            %後脚から接地
            if fixedPoint(i).q_constants(3) > 0    
                    plot(rad2deg(fixedPoint(i).q_constants(3)), logdata(i).rate, 'o','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')      
                    hold on

            %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0   
                    plot(rad2deg(fixedPoint(i).q_constants(3)), logdata(i).rate, 'd', 'markerfacecolor', 'r', 'markeredgecolor', 'r')     
                    hold on 
            end 

        

        %GE
        elseif (fixedPoint(i).u_fix(3)) < 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) > 0             

            if fixedPoint(i).q_constants(3) > 0   
                    plot(rad2deg(fixedPoint(i).q_constants(3)), logdata(i).rate, 'd', 'markerfacecolor', 'r', 'markeredgecolor', 'r')      
                    hold on

            elseif fixedPoint(i).q_constants(3) < 0   
                    plot(rad2deg(fixedPoint(i).q_constants(3)), logdata(i).rate, 'o','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')      
                    hold on
            end 

        end



    

    %double leg stanceがあるとき(double leg flightが一回だけ)
    elseif  logdata(i).eeout(3) == 3

        %E
        if fixedPoint(i).u_fix(3) > 0 

            %後脚から
            if fixedPoint(i).q_constants(3) > 0                                                           
                    plot(rad2deg(fixedPoint(i).q_constants(3)), logdata(i).rate, 'o','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')     
                    hold on

            %前脚から
            elseif fixedPoint(i).q_constants(3) < 0                          
                    plot(rad2deg(fixedPoint(i).q_constants(3)), logdata(i).rate, 'o','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')   
                    hold on
            
            %プロンク
            elseif fixedPoint(i).q_constants(3) == 0
                    plot(rad2deg(fixedPoint(i).q_constants(3)), logdata(i).rate, 'o','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')      
                    hold on
            end


        %G
        elseif fixedPoint(i).u_fix(3)  < 0 

            %後脚から
            if fixedPoint(i).q_constants(3) > 0    
                    plot(rad2deg(fixedPoint(i).q_constants(3)), logdata(i).rate, 'o','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')      
                    hold on

            %前脚から
             elseif fixedPoint(i).q_constants(3) < 0   
                    plot(rad2deg(fixedPoint(i).q_constants(3)), logdata(i).rate, 'o','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')  
                    hold on
 
            %プロンク
            elseif fixedPoint(i).q_constants(3) == 0
                    plot(rad2deg(fixedPoint(i).q_constants(3)), logdata(i).rate, 'o','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')    
                    hold on
                

            end

        end



    end

end


if saveflag == true
        
    figname = ['swarm_rate_Energy'];
    saveas(gcf, figname, 'pdf')
    saveas(gcf, figname, 'fig')
    disp('save finish!')
end