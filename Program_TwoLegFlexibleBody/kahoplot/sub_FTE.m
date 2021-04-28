% fileName: sub_FTE.m
% initDate:　2020/9/7
% Object:  前進効率を求める(参照:山田さん論文)
% 修正1 : 2020/9/15 Markeredgecolorを黒にした
% 修正2 : 2020/12/21 前後脚区別を加えた(色の組み合わせも変更)＆abs_maxを修正
% チーターと運動一致で黒枠, 安定で記号大


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
    logdata(i).energy = fixedPoint(i).GRF/(2 * model.m * model.g);
    
end


%% -----------------------------------------------------------------------
%  エネルギー計算

figure 


for i = 1: length(fixedPoint)

    xh = q_fix(1) - model.L .* cos(q_fix(4)) .* cos(q_fix(3));
    yh = q_fix(2) - model.L .* cos(q_fix(4)) .* sin(q_fix(3));
    xf = q_fix(1) + model.L .* cos(q_fix(4)) .* cos(q_fix(3));
    yf = q_fix(2) + model.L .* cos(q_fix(4)) .* sin(q_fix(3));

    dxh = q_fix(5) + q_fix(7) .* model.L .* sin(q_fix(3)) .* cos(q_fix(4)) + q_fix(8) .* model.L .* cos(q_fix(3)) .* sin(q_fix(4));
    dyh = q_fix(6) - q_fix(7) .* model.L .* cos(q_fix(3)) .* cos(q_fix(4)) + q_fix(8) .* model.L .* sin(q_fix(3)) .* sin(q_fix(4));
    dxf = q_fix(5) - q_fix(7) .* model.L .* sin(q_fix(3)) .* cos(q_fix(4)) - q_fix(8) .* model.L .* cos(q_fix(3)) .* sin(q_fix(4));
    dyf = q_fix(6) + q_fix(7) .* model.L .* cos(q_fix(3)) .* cos(q_fix(4)) - q_fix(8) .* model.L .* sin(q_fix(3)) .* sin(q_fix(4));


    T1 = 0.5 * model.m * (dxh.^2 + dyh.^2) + 0.5 * model.m * (dxf.^2 + dyf.^2);
    T2 = model.J * (q_fix(7)^2 + q_fix(8)^2);
    T = T1 + T2;

    V1 = 2 * model.m * model.g * q_fix(2);
    % V2 = 0.5 * model.kh * (model.l3 - model.lout(:, 1)).^2;
    % V3 = 0.5 * model.kf * (model.l4 - model.lout(:, 2)).^2;
    V4 = 0.5 * model.kt * (2 * q_fix(4)).^2;
    % V = V1 + V2 + V3 + V4;
    V = V1 + V4;

    E_total = T + V;


    x_end = fixedPoint(i).trajectory.qout(end, 1);   
    t_end = fixedPoint(i).trajectory.tout(end);

    X_ave = x_end / t_end;                                      %平均速度

    fte = 2 * model.m * X_ave^2/(2 * E_total);                  %前進効率
    i_middle = round(length(fixedPoint(i).trajectory.tout)/2);

    if logdata(i).eeout(3) == 1    

        %EE
        if fixedPoint(i).u_fix(3) > 0  &&  fixedPoint(i).trajectory.qout(i_middle, 4) > 0

            %後脚から着地
            if fixedPoint(i).q_constants(3) > 0   

                %安定
                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte, '^','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)   
                    hold on   
                
                %不安定    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte ,'^','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')
                    hold on      

                end

            
            %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0   

                %安定
                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte, '^','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE','MarkerSize',12)   
                    hold on   
                
                %不安定    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte ,'^','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')
                    hold on      

                end

            end


       

        %GG
        elseif fixedPoint(i).u_fix(3)  < 0  && fixedPoint(i).trajectory.qout(i_middle, 4) < 0  

        %後脚から接地
        if fixedPoint(i).q_constants(3) > 0    

            if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte, '^', 'markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12)      
                
            elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)),fte , '^', 'markerfacecolor', '#D95319', 'markeredgecolor', '#D95319')      
            end

        %前脚から接地
        elseif fixedPoint(i).q_constants(3) < 0   

            if (max( abs(logdata(i).eigenValue)) - 1 ) < 1e-5
                plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte , '^','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120','MarkerSize',12)      
                
            elseif (max( abs(logdata(i).eigenValue)) - 1 ) > 1e-5
                plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte , '^','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120')      
            end

        end




        %EG
        elseif (fixedPoint(i).u_fix(3)) > 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) < 0          
             
            %後脚から接地
            if fixedPoint(i).q_constants(3) > 0    


                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte , 'o','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)     
                    hold on
                
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)),fte , 'o','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')      
                    hold on

                end

            %前脚から接地
            elseif fixedPoint(i).q_constants(3) < 0   

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte , 'o', 'LineWidth', 1.5, 'markerfacecolor', '#4DBEEE', 'markeredgecolor', 'k','MarkerSize',12)      
                    hold on
                
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte, 'o', 'LineWidth', 1.5, 'markerfacecolor', '#4DBEEE', 'markeredgecolor', 'k')       
                    hold on

                end


            end

            

        %GE    
        elseif (fixedPoint(i).u_fix(3)) < 0 && (fixedPoint(i).trajectory.qout(i_middle, 4)) > 0

            if fixedPoint(i).q_constants(3) > 0   

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte,'o', 'LineWidth', 1.5, 'markerfacecolor', '#D95319', 'markeredgecolor', 'k','MarkerSize',12)   
                    hold on    
                
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte , 'o', 'LineWidth', 1.5, 'markerfacecolor', '#D95319', 'markeredgecolor', 'k')        
                    hold on
                end

            elseif fixedPoint(i).q_constants(3) < 0   

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte , 'o','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120','MarkerSize',12)
                    hold on    
                
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte,  'o','markerfacecolor', '#EDB120', 'markeredgecolor', '#EDB120')      
                    hold on
                end

            end


            

        end
    
    
    elseif logdata(i).eeout(3) == 3

        %E
        if fixedPoint(i).u_fix(3) > 0 

            if fixedPoint(i).q_constants(3) > 0

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte, 's','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)  
                    hold on 
                    
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte, 's','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')   
                    hold on  
                end
                
            %前脚から
            elseif fixedPoint(i).q_constants(3) < 0

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte, 's','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE','MarkerSize',12)  
                    hold on 
                    
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte, 's','markerfacecolor', '#4DBEEE', 'markeredgecolor', '#4DBEEE')  
                    hold on

                end

            %プロンク
            elseif  fixedPoint(i).q_constants(3) == 0

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte, 'd','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD','MarkerSize',12)   
                    hold on                  
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte, 'd','markerfacecolor', '#0072BD', 'markeredgecolor', '#0072BD')
                    hold on      
                end
                 

            end


        %C
        elseif fixedPoint(i).u_fix(3)  < 0

            if fixedPoint(i).q_constants(3) > 0

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte, 's','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12) 
                    hold on     
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)),fte, 's','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319')      
                    hold on
                end


            elseif fixedPoint(i).q_constants(3) < 0

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte,'s','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12)    
                    hold on  
                    
                elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte, 's','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319') 
                    hold on     
                end


            elseif fixedPoint(i).q_constants(3) == 0

                if max( abs(logdata(i).eigenValue) - 1 ) < 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte, 'd','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319','MarkerSize',12)      
                    hold on
                    
                    elseif max( abs(logdata(i).eigenValue) - 1 ) > 1e-5
                    plot3(rad2deg(fixedPoint(i).q_constants(3)), rad2deg(fixedPoint(i).u_fix(3)), fte, 'd','markerfacecolor', '#D95319', 'markeredgecolor', '#D95319')    
                    hold on
                
                end
    
            end

        end

    end   


end



xlabel('$$\dot{\theta_0}$$[deg/s]','Interpreter','latex')
ylabel('\phi_0 [deg]')
zlabel('FTE')
%title('dx=13,y=0.62,d=0.08')


if saveflag == true
        
    figname = ['FTE'];
    saveas(gcf, figname, 'png')
    saveas(gcf, figname, 'fig')
    disp('save finish!')
end



