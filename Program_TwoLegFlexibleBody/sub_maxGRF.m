% fileName: sub_maxGRF.m
% initDate:　2020/9/3
% Object:  最大床反力をプロット
% 修正1 : 2020/9/15 Markeredgecolorを黒にした
% 修正2 : 2020/12/21 前後脚区別を加えた＆abs_maxを修正
% チーターと一致で黒枠，安定で記号大

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
    logdata(i).maxGRF = fixedPoint(i).GRF/(2 * model.m * model.g);

end

%% -----------------------------------------------------------------------------------------
%自重で正規化した最大床反力をプロット

figure 

for i = 1:length(fixedPoint)
    
    maxGRF = fixedPoint(i).GRF/(2 * model.m * model.g);
    i_middle = round(length(fixedPoint(i).trajectory.tout)/2);


        if logdata(i).eeout(3) == 1    

            %EE
            if fixedPoint(i).u_fix(3) > 0  &&  fixedPoint(i).trajectory.qout(i_middle, 4) > 0

                %後脚から着地
                if fixedPoint(i).q_constants(3) > 0   

                    %安定
                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, '^','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)   
                        hold on   
                    
                    %不安定    
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF ,'^','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')
                        hold on      

                    end

                
                %前脚から接地
                elseif fixedPoint(i).q_constants(3) < 0   

                    %安定
                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, '^','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE','MarkerSize',12)   
                        hold on   
                    
                    %不安定    
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF ,'^','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')
                        hold on      

                    end

                end

           

            %GG
            elseif fixedPoint(i).u_fix(3)  < 0  && fixedPoint(i).trajectory.qout(i_middle, 4) < 0  

                % if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                %     plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, '^','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12)      
                %     hold on   
                    
                % elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                %     plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)),maxGRF , '^','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319')      
                %     hold on   
                % end


                %後脚から接地
            if fixedPoint(i).q_constants(3) > 0    

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, '^', 'markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12)      
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)),maxGRF , '^', 'markerfacecolor', '#D95319', 'markeredgecolor', '#D95319')      
                end

            %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0   

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF , '^','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120','MarkerSize',12)      
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF , '^','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120')      
                end
 
            end




            %EG
            elseif (fixedPoint(i).u_fix(3)) > 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) < 0          
                 
                %後脚から接地
                if fixedPoint(i).q_constants(3) > 0    


                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF , 'o','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)     
                        hold on
                    
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)),maxGRF , 'o','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')      
                        hold on

                    end

                %前脚から接地
                elseif fixedPoint(i).q_constants(3) < 0   

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF , 'o', 'LineWidth', 1.5, 'markerfacecolor', '#4DBEEE', 'markeredgecolor', 'k','MarkerSize',12)      
                        hold on
                    
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, 'o', 'LineWidth', 1.5, 'markerfacecolor', '#4DBEEE', 'markeredgecolor', 'k')       
                        hold on

                    end


                end
 
                

            %GE    
            elseif (fixedPoint(i).u_fix(3)) < 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) > 0

                if fixedPoint(i).q_constants(3) > 0   

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF,'o', 'LineWidth', 1.5, 'markerfacecolor', '#D95319', 'markeredgecolor', 'k','MarkerSize',12)   
                        hold on    
                    
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF , 'o', 'LineWidth', 1.5, 'markerfacecolor', '#D95319', 'markeredgecolor', 'k')        
                        hold on
                    end

                elseif fixedPoint(i).q_constants(3) < 0   

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF , 'o','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120','MarkerSize',12)
                        hold on    
                    
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF,  'o','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120')      
                        hold on
                    end

                end


                

            end
        
        
        elseif logdata(i).eeout(3) == 3

            %E
            if fixedPoint(i).u_fix(3) > 0 

                if fixedPoint(i).q_constants(3) > 0

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, 's','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)  
                        hold on 
                        
                        
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, 's','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')   
                        hold on  
                    end
                    
                %前脚から
                elseif fixedPoint(i).q_constants(3) < 0

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, 's','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE','MarkerSize',12)  
                        hold on 
                        
                        
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, 's','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')  
                        hold on

                    end

                %プロンク
                elseif  fixedPoint(i).q_constants(3) == 0

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, 'd','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)   
                        hold on                  
                        
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, 'd','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')
                        hold on      
                    end
                     

                end


            %C
            elseif fixedPoint(i).u_fix(3)  < 0

                if fixedPoint(i).q_constants(3) > 0

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, 's','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12) 
                        hold on     
                        
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)),maxGRF, 's','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319')      
                        hold on
                    end


                elseif fixedPoint(i).q_constants(3) < 0

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF,'s','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12)    
                        hold on  
                        
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, 's','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319') 
                        hold on     
                    end

    
                elseif fixedPoint(i).q_constants(3) == 0

                    if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, 'd','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12)      
                        hold on
                        
                        elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                        plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), maxGRF, 'd','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319')    
                        hold on
                    
                    end
        
                end

            end

        end   
    
    
end

xlabel('$$\dot{\theta_0}$$[deg/s]','Interpreter','latex')
ylabel('\phi_0 [deg]')
zlabel('maxGRF')
%title('dx=13,y=0.62,kt=240,D=0.02')



if saveflag == true
        
    figname = ['maxGRF'];
    saveas(gcf, figname, 'pdf')
    saveas(gcf, figname, 'fig')
    disp('save finish!')
end





