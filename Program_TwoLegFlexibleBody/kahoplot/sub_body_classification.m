% fileName: sub_body_classification.m
% initDate: 2020/8/26
% Object:   体の形,脚の接地,安定性を分類したグラフ
% 修正1 :    2020/9/14 チーターの運動に一致している点のmarkeredgecolorを変更

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

for i = 1:length(fixedPoint)

    q_fix = fixedPoint(i).q_ini;
    u_fix(1) = fixedPoint(i).u_fix(1);
    u_fix(2) = fixedPoint(i).u_fix(2);

    [eigenValues, eivenVectors, jacobi] = calc_eigenvalue(model, q_fix, u_fix);

    diagonal = diag(eigenValues);
    logdata(i).eigenValue = diagonal;
    logdata(i).eivenVectors = eivenVectors;
    logdata(i).jacobi = jacobi;
    logdata(i).eeout = model.eeout;

end


%%---------------------------------------------------------------------------------------
%flight phaseでの体の状態を分類

figure 
hold on

xlabel('$$\dot{\theta_0}$$[deg/s]','Interpreter','latex')
ylabel('\phi_0 [deg]')
%title('dx = 13,y=0.62,kt=200,D=-0.05')

for i = 1:length(fixedPoint)


    i_middle = round(length(fixedPoint(i).trajectory.tout)/2);
    

    
        %double leg flightが二回ある歩容
    if logdata(i).eeout(3) == 1                                                                      


        %EE
        if fixedPoint(i).u_fix(3) > 0  &&  fixedPoint(i).trajectory.qout(i_middle, 4) > 0          

            %後脚から着地
            if fixedPoint(i).q_constants(3) > 0                                                           
               
                %安定
                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', 'r', 'markeredgecolor', 'r','MarkerSize',12)      
                    
                %不安定    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', 'r', 'markeredgecolor', 'r')      
                end


            %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0                           

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', 'r', 'markeredgecolor', 'r','MarkerSize',12)      
                    
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's', 'markerfacecolor', 'r', 'markeredgecolor', 'r')      
                end

            end

        
        %GG
        elseif fixedPoint(i).u_fix(3)  < 0  && fixedPoint(i).trajectory.qout(i_middle, 4) < 0      

            if fixedPoint(i).q_constants(3) > 0    

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's', 'markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)      
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's', 'markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')      
                end

 
            elseif fixedPoint(i).q_constants(3) < 0   

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)      
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')      
                end
 
            end

        
        %EG
        elseif (fixedPoint(i).u_fix(3)) > 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) < 0            

            if fixedPoint(i).q_constants(3) > 0    

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120','MarkerSize',12)     
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120')      
                end

 
            elseif fixedPoint(i).q_constants(3) < 0   

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's', 'LineWidth', 1.5, 'markerfacecolor', '#EDB120', 'markeredgecolor', 'k','MarkerSize',12)      
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's', 'LineWidth', 1.5, 'markerfacecolor', '#EDB120', 'markeredgecolor', 'k')      
                end
 
            end 

        

        %CE
        elseif (fixedPoint(i).u_fix(3)) < 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) > 0             

            if fixedPoint(i).q_constants(3) > 0    

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's', 'LineWidth', 1.5, 'markerfacecolor', '#77AC30', 'markeredgecolor', 'k','MarkerSize',12)     
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's', 'LineWidth', 1.5, 'markerfacecolor', '#77AC30', 'markeredgecolor', 'k')      
                end

 
            elseif fixedPoint(i).q_constants(3) < 0   

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', '#77AC30', 'markeredgecolor', '#77AC30','MarkerSize',12)      
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', '#77AC30', 'markeredgecolor', '#77AC30')      
                end
 
            end 


        end



    

    %double leg stanceがあるとき(double leg flightが一回だけ)
    elseif  logdata(i).eeout(3) == 3

        %E
        if fixedPoint(i).u_fix(3) > 0 

            if fixedPoint(i).q_constants(3) > 0                                                           
               
                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^','markerfacecolor', 'm', 'markeredgecolor', 'm','MarkerSize',12)   
                    
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^','markerfacecolor', 'm', 'markeredgecolor', 'm')     
                end

            elseif fixedPoint(i).q_constants(3) < 0                          

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^','markerfacecolor', 'm', 'markeredgecolor', 'm','MarkerSize',12)      
                    
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^','markerfacecolor', 'm', 'markeredgecolor', 'm')      
                end

            elseif fixedPoint(i).q_constants(3) == 0

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o','markerfacecolor', 'm', 'markeredgecolor', 'm','MarkerSize',12)      
                    
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o','markerfacecolor', 'm', 'markeredgecolor', 'm')      
                end


            end


        %C
        elseif fixedPoint(i).u_fix(3)  < 0 

            if fixedPoint(i).q_constants(3) > 0    

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^','markerfacecolor', 'c', 'markeredgecolor', 'c','MarkerSize',12)      
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^','markerfacecolor', 'c', 'markeredgecolor', 'c')      
                end

 
             elseif fixedPoint(i).q_constants(3) < 0   

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^','markerfacecolor', 'c', 'markeredgecolor', 'c','MarkerSize',12)      
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^','markerfacecolor', 'c', 'markeredgecolor', 'c')      
                end
 
            
            elseif fixedPoint(i).q_constants(3) == 0

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o','markerfacecolor', 'c', 'markeredgecolor', 'c','MarkerSize',12)      
                
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o','markerfacecolor', 'c', 'markeredgecolor', 'c')    
                
                end

            end

        end



    end

end




if saveflag == true
        
    figname = ['body_classification']
    saveas(gcf, figname, 'png')
    disp('save finish!')
end


