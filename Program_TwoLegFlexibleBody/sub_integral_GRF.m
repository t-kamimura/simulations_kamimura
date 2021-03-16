% fileName: sub_integral_GRF.m
% initDate:　2020/9/11
% Object:  床反力の積分地をプロット
% 修正1 : 2020/9/15 チーターと一致で枠を黒，安定で記号大


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

load('fixedPoints_for_y0=0.645_dx0=11,kt=200.mat')


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
    logdata(i).p = fixedPoint(i).p;

end


%% -------------------------------------------------------------------
% 床反力の積分値を自重で正規化してプロット

figure 

for i = 1:length(fixedPoint)
    
    integral_GRF = fixedPoint(i).p;
    i_middle = round(length(fixedPoint(i).trajectory.tout)/2);


        if logdata(i).eeout(3) == 1    

            %EE
            if fixedPoint(i).u_fix(3) > 0  &&  fixedPoint(i).trajectory.qout(i_middle, 4) > 0

                %安定
                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF, 's','markerfacecolor', 'r', 'markeredgecolor', 'r','MarkerSize',12)   
                    hold on   
                    
                %不安定    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF ,'s','markerfacecolor', 'r', 'markeredgecolor', 'r')
                    hold on      
                end

           

            %GG
            elseif fixedPoint(i).u_fix(3)  < 0  && fixedPoint(i).trajectory.qout(i_middle, 4) < 0  

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF, 's','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)      
                    hold on   
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)),integral_GRF , 's','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')      
                    hold on   
                end


            %EG
            elseif (fixedPoint(i).u_fix(3)) > 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) < 0          

                if fixedPoint(i).q_constants(3) > 0    

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF , 's','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120','MarkerSize',12)     
                         hold on
                    
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)),integral_GRF , 's','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120') 
                        hold on
                    end
                

                elseif fixedPoint(i).q_constants(3) < 0 

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF , 's','LineWidth', 1.5,'markerfacecolor', '#EDB120', 'markeredgecolor', 'k','MarkerSize',12)     
                         hold on
                    
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)),integral_GRF , 's','LineWidth', 1.5,'markerfacecolor', '#EDB120', 'markeredgecolor', 'k')
                        hold on
                    end

                end
                

            %GE    
            elseif (fixedPoint(i).u_fix(3)) < 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) > 0

                if fixedPoint(i).q_constants(3) > 0  

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF , 's','LineWidth', 1.5,'markerfacecolor', '#77AC30', 'markeredgecolor', 'k','MarkerSize',12)
                        hold on    
                    
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF,  's','LineWidth', 1.5,'markerfacecolor', '#77AC30', 'markeredgecolor', 'k')
                        hold on
                    end


                elseif fixedPoint(i).q_constants(3) < 0 

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF , 's','markerfacecolor', '#77AC30', 'markeredgecolor', '#77AC30','MarkerSize',12)
                        hold on    
                    
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF,  's','markerfacecolor', '#77AC30', 'markeredgecolor', '#77AC30')
                        hold on
                    end

                end


            end
        
        
        elseif logdata(i).eeout(3) == 3

            %E
            if fixedPoint(i).u_fix(3) > 0 

                if fixedPoint(i).q_constants(3) > 0

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF, '^','markerfacecolor', 'm', 'markeredgecolor', 'm','MarkerSize',12)  
                        hold on 
                        
                        
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF, '^','markerfacecolor', 'm', 'markeredgecolor', 'm')   
                        hold on  
                    end
                    

                elseif fixedPoint(i).q_constants(3) < 0

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF, '^','markerfacecolor', 'm', 'markeredgecolor', 'm','MarkerSize',12)  
                        hold on 
                        
                        
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF, '^','markerfacecolor', 'm', 'markeredgecolor', 'm')  
                        hold on

                    end

                elseif  fixedPoint(i).q_constants(3) == 0

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF, 'o','markerfacecolor', 'm', 'markeredgecolor', 'm','MarkerSize',12)   
                        hold on                  
                        
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF, 'o','markerfacecolor', 'm', 'markeredgecolor', 'm')
                        hold on      
                    end
                     

                end


            %G
            elseif fixedPoint(i).u_fix(3)  < 0

                if fixedPoint(i).q_constants(3) > 0

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF, '^','markerfacecolor', 'c', 'markeredgecolor', 'c','MarkerSize',12) 
                        hold on     
                        
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)),integral_GRF, '^','markerfacecolor', 'c', 'markeredgecolor', 'c')      
                        hold on
                    end


                elseif fixedPoint(i).q_constants(3) < 0

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF,'^','markerfacecolor', 'c', 'markeredgecolor', 'c','MarkerSize',12)    
                        hold on  
                        
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF, '^','markerfacecolor', 'c', 'markeredgecolor', 'c') 
                        hold on     
                    end

    
                elseif fixedPoint(i).q_constants(3) == 0

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF, 'o','markerfacecolor', 'c', 'markeredgecolor', 'c','MarkerSize',12)      
                        hold on
                        
                        elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), integral_GRF, 'o','markerfacecolor', 'c', 'markeredgecolor', 'c')    
                        hold on
                    
                    end
        
                end

            end

        end   
    
    
end

xlabel('$$\dot{\theta_0}$$[deg/s]','Interpreter','latex')
ylabel('\phi_0 [deg]')
zlabel('integralGRF')
%title('dx = 11,y=0.645,kt=200')



if saveflag == true
        
    figname = ['integral_GRF'];
    saveas(gcf, figname, 'png')
    saveas(gcf, figname, 'fig')
    disp('save finish!')
end







