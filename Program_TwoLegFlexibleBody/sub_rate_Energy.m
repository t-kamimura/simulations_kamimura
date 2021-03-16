% fileName: sub_rate_Energy.m
% initDate:　2020/12/04
% Object: (脚バネに蓄えられる最大エネルギー)/(総エネ)で比率を表すプログラム
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
 
    logdata(i).kh = model.Eout(:,6);
    logdata(i).kf = model.Eout(:,7);

    logdata(i).hind_max = 0.5 * model.kh * (model.l3 - min(model.lout(:, 1))).^2;
    logdata(i).fore_max = 0.5 * model.kf * (model.l4 - min(model.lout(:, 2))).^2;
    logdata(i).horzcat = horzcat(logdata(i).hind_max, logdata(i).fore_max);
    logdata(i).MAX_ki = max(logdata(i).horzcat, [], 2);

    logdata(i).sum = model.Eout(:,9);
    logdata(i).rate = max(abs((logdata(i).MAX_ki)/(logdata(i).sum)));

end



figure  
xlabel('$$\dot{\theta}$$ [s]', 'interpreter', 'latex', 'Fontsize', 14);
ylabel('\phi_0 [deg]')
zlabel('Energy', 'interpreter', 'latex', 'Fontsize', 14);

for i = 1: length(fixedPoint)


    i_middle = round(length(fixedPoint(i).trajectory.tout)/2);   


    %double leg flightが二回ある歩容
    if logdata(i).eeout(3) ==1                                                                      

        %EE
        if fixedPoint(i).u_fix(3) > 0  &&  fixedPoint(i).trajectory.qout(i_middle, 4) > 0          

            %後脚から着地
            if fixedPoint(i).q_constants(3) > 0                                                           
                
                %安定
                if (max( abs(logdata(i).eigenValue)) - 1 )  < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, '^','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)      
                    hold on
                    
                %不安定    
                elseif ( max( abs(logdata(i).eigenValue)) - 1)  > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, '^','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')  
                    hold on    
                end


            %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0                           

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, '^','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE','MarkerSize',12)
                    hold on      
                    
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, '^', 'markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')    
                    hold on  
                end

            end

        
        %GG
        elseif fixedPoint(i).u_fix(3)  < 0  && fixedPoint(i).trajectory.qout(i_middle, 4) < 0      

            %後脚から接地
            if fixedPoint(i).q_constants(3) > 0    

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, '^', 'markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12)   
                    hold on   
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, '^', 'markerfacecolor', '#D95319', 'markeredgecolor', '#D95319')      
                    hold on
                end

            %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0   

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, '^','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120','MarkerSize',12) 
                    hold on     
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, '^','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120')      
                    hold on
                end
 
            end

        
        %EG
        elseif (fixedPoint(i).u_fix(3)) > 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) < 0            

            %後脚から接地
            if fixedPoint(i).q_constants(3) > 0    

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 'o','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)  
                    hold on   
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 'o','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')      
                    hold on
                end


            %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0   

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 'o', 'LineWidth', 1.5, 'markerfacecolor', '#4DBEEE', 'markeredgecolor', 'k','MarkerSize',12)      
                    hold on
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 'o', 'LineWidth', 1.5, 'markerfacecolor', '#4DBEEE', 'markeredgecolor', 'k')     
                    hold on 
                end
 
            end 

        

        %GE
        elseif (fixedPoint(i).u_fix(3)) < 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) > 0             

            if fixedPoint(i).q_constants(3) > 0    

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 'o', 'LineWidth', 1.5, 'markerfacecolor', '#D95319', 'markeredgecolor', 'k','MarkerSize',12)     
                    hold on
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 'o', 'LineWidth', 1.5, 'markerfacecolor', '#D95319', 'markeredgecolor', 'k')      
                    hold on

                end

 
            elseif fixedPoint(i).q_constants(3) < 0   

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 'o','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120','MarkerSize',12)   
                    hold on   
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 'o','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120')      
                    hold on

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
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 's','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)  
                    hold on 
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 's','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')     
                    hold on

                end

            %前脚から
            elseif fixedPoint(i).q_constants(3) < 0                          

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 's','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE','MarkerSize',12)      
                    hold on
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 's','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')   
                    hold on

                end

            
            %プロンク
            elseif fixedPoint(i).q_constants(3) == 0

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 'd','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)  
                    hold on    
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 'd','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')      
                    hold on

                end


            end


        %G
        elseif fixedPoint(i).u_fix(3)  < 0 

            %後脚から
            if fixedPoint(i).q_constants(3) > 0    

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 's','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12)  
                    hold on    
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 's','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319')      
                    hold on

                end

 
            %前脚から
             elseif fixedPoint(i).q_constants(3) < 0   

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 's','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120','MarkerSize',12)     
                    hold on 
                    
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 's','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120')  
                    hold on

                end
 
            %プロンク
            elseif fixedPoint(i).q_constants(3) == 0

                if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 'd','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12)  
                hold on    
                
                elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), logdata(i).rate, 'd','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319')    
                hold on
                
                end

            end

        end



    end

end





if saveflag == true
        
    figname = ['rate_Energy'];
    saveas(gcf, figname, 'png')
    saveas(gcf, figname, 'fig')
    disp('save finish!')
end

