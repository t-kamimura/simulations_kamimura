% fileName: thesis_maxGRF.m
% initDate:　2020/9/3
% Object:  最大床反力をプロット
% 修正1 : 2020/9/15 Markeredgecolorを黒にした
% 修正2 : 2020/12/21 前後脚区別を加えた＆abs_maxを修正
% 修正3 : 2020/1/26 二次元プロットに変更(x,z)
% 修正4 : 2021/2/15 卒論発表用に安定で大→一致で大

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
                    plot(rad2deg(fixedPoint(i).q_constants(3)), maxGRF ,'^','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')
                    hold on  
          
                %前脚から接地
                elseif fixedPoint(i).q_constants(3) < 0   
                    plot(rad2deg(fixedPoint(i).q_constants(3)), maxGRF ,'^','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')
                    hold on  
                
                end


           

            %GG
            elseif fixedPoint(i).u_fix(3)  < 0  && fixedPoint(i).trajectory.qout(i_middle, 4) < 0  

                     %後脚から接地
                 if fixedPoint(i).q_constants(3) > 0    
                    plot(rad2deg(fixedPoint(i).q_constants(3)), maxGRF , '^', 'markerfacecolor', '#D95319', 'markeredgecolor', '#D95319') 
                    hold on       

                 %前脚から接地
                     elseif fixedPoint(i).q_constants(3) < 0   
                     plot(rad2deg(fixedPoint(i).q_constants(3)), maxGRF , '^','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120') 
                     hold on       
 
                 end




            %EG
            elseif (fixedPoint(i).u_fix(3)) > 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) < 0          
                 
                %後脚から接地
                if fixedPoint(i).q_constants(3) > 0    
                    plot(rad2deg(fixedPoint(i).q_constants(3)), maxGRF , 'o','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')
                    hold on        

                %前脚から接地
                elseif fixedPoint(i).q_constants(3) < 0   
                    plot(rad2deg(fixedPoint(i).q_constants(3)), maxGRF, 'o', 'LineWidth', 1.0, 'markerfacecolor', '#4DBEEE', 'markeredgecolor', 'k', 'MarkerSize',12)       
                    hold on  

                end
 
                

            %GE    
            elseif (fixedPoint(i).u_fix(3)) < 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) > 0

                if fixedPoint(i).q_constants(3) > 0   
                    plot(rad2deg(fixedPoint(i).q_constants(3)), maxGRF , 'o', 'LineWidth', 1.0, 'markerfacecolor', '#D95319', 'markeredgecolor', 'k', 'MarkerSize',12)        
                    hold on  
                elseif fixedPoint(i).q_constants(3) < 0   
                    plot(rad2deg(fixedPoint(i).q_constants(3)), maxGRF,  'o','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120')   
                    hold on     
                end

            end
        
        
        elseif logdata(i).eeout(3) == 3

            %E
            if fixedPoint(i).u_fix(3) > 0 

                if fixedPoint(i).q_constants(3) > 0
                        plot(rad2deg(fixedPoint(i).q_constants(3)), maxGRF, 's','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD') 
                        hold on   
                    
                %前脚から
                elseif fixedPoint(i).q_constants(3) < 0
                        plot(rad2deg(fixedPoint(i).q_constants(3)), maxGRF, 's','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')
                        hold on    

                %プロンク
                elseif  fixedPoint(i).q_constants(3) == 0
                        plot(rad2deg(fixedPoint(i).q_constants(3)), maxGRF, 'd','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')
                        hold on  
                end


            %C
            elseif fixedPoint(i).u_fix(3)  < 0

                if fixedPoint(i).q_constants(3) > 0
                        plot(rad2deg(fixedPoint(i).q_constants(3)), maxGRF, 's','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319')      
                        hold on  

                elseif fixedPoint(i).q_constants(3) < 0
                        plot(rad2deg(fixedPoint(i).q_constants(3)), maxGRF, 's','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319') 
                        hold on  

                elseif fixedPoint(i).q_constants(3) == 0
                        plot(rad2deg(fixedPoint(i).q_constants(3)), maxGRF, 'd','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319') 
                        hold on     

                end

            end

        end   
    
    
end

xlabel('$$\dot{\theta_0}$$[deg/s]','Interpreter','latex')
%ylabel('\phi_0 [deg]')
ylabel('maxGRF [N]')
%title('dx=13,y=0.62,kt=240,D=0.02')



if saveflag == true
        
    figname = ['thesis_maxGRF'];
    saveas(gcf, figname, 'pdf')
    saveas(gcf, figname, 'fig')
    disp('save finish!')
end





