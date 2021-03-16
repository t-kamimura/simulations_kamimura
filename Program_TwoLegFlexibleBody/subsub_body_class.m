% fileName: subsub_classification_body.m
% initDate:　2020/11/06
% Object:  sub_body_classificationに加えて前脚接地後脚接地を分けた．(2)
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
%flight phaseでの体の状態を分類したい


figure 
hold on

xlabel('$$\dot{\theta_0}$$[deg/s]','Interpreter','latex')
ylabel('\phi_0 [deg]')

for i = 1:length(fixedPoint)


    i_middle = round(length(fixedPoint(i).trajectory.tout)/2);
    

    
        %double leg flightが二回ある歩容
    if logdata(i).eeout(3) == 1                                                                      


        %EE
        if fixedPoint(i).u_fix(3) > 0  &&  fixedPoint(i).trajectory.qout(i_middle, 4) > 0          

            %後脚から着地
            if fixedPoint(i).q_constants(3) > 0                                                           
               
                %安定
                if (max( abs(logdata(i).eigenValue)) - 1 )  < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)      
                    
                %不安定    
                elseif ( max( abs(logdata(i).eigenValue)) - 1)  > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')      
                end


            %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0                           

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE','MarkerSize',12)      
                    
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')      
                end

            end

        
        %GG
        elseif fixedPoint(i).u_fix(3)  < 0  && fixedPoint(i).trajectory.qout(i_middle, 4) < 0      

            %後脚から接地
            if fixedPoint(i).q_constants(3) > 0    

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^', 'markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12)      
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^', 'markerfacecolor', '#D95319', 'markeredgecolor', '#D95319')      
                end

            %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0   

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120','MarkerSize',12)      
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), '^','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120')      
                end
 
            end

        
        %EG
        elseif (fixedPoint(i).u_fix(3)) > 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) < 0            

            %後脚から接地
            if fixedPoint(i).q_constants(3) > 0    

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)     
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')      
                end


            %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0   

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'LineWidth', 1.5, 'markerfacecolor', '#4DBEEE', 'markeredgecolor', 'k','MarkerSize',12)      
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'LineWidth', 1.5, 'markerfacecolor', '#4DBEEE', 'markeredgecolor', 'k')      
                end
 
            end 

        

        %GE
        elseif (fixedPoint(i).u_fix(3)) < 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) > 0             

            if fixedPoint(i).q_constants(3) > 0    

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'LineWidth', 1.5, 'markerfacecolor', '#D95319', 'markeredgecolor', 'k','MarkerSize',12)     
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o', 'LineWidth', 1.5, 'markerfacecolor', '#D95319', 'markeredgecolor', 'k')      
                end

 
            elseif fixedPoint(i).q_constants(3) < 0   

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120','MarkerSize',12)      
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'o','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120')      
                end
 
            end 


        end



    

    %double leg stanceがあるとき(double leg flightが一回だけ)
    elseif  logdata(i).eeout(3) == 3

        %E
        if fixedPoint(i).u_fix(3) > 0 

            %後脚から
            if fixedPoint(i).q_constants(3) > 0                                                           
               
                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)   
                    
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')     
                end

            %前脚から
            elseif fixedPoint(i).q_constants(3) < 0                          

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE','MarkerSize',12)      
                    
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')      
                end

            
            %プロンク
            elseif fixedPoint(i).q_constants(3) == 0

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'd','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)      
                    
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'd','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')      
                end


            end


        %G
        elseif fixedPoint(i).u_fix(3)  < 0 

            %後脚から
            if fixedPoint(i).q_constants(3) > 0    

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12)      
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319')      
                end

 
            %前脚から
             elseif fixedPoint(i).q_constants(3) < 0   

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120','MarkerSize',12)      
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 's','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120')      
                end
 
            %プロンク
            elseif fixedPoint(i).q_constants(3) == 0

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'd','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12)      
                
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                plot(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), 'd','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319')    
                
                end

            end

        end



    end

end



if saveflag == true
        
    figname = ['phidtheta']
    saveas(gcf, figname, 'png')
    %saveas(gcf, figname, 'pdf')
    disp('save finish!')
end

