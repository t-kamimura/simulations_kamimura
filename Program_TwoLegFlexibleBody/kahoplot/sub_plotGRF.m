% fileName: sub_plotGRF.m
% initDate:　2020/11/19
% 最大床反力・接地・離地の脚をプロット
% Object: 11/19 床反力の向きと方向をプロット
% Object: 11/20 接地と離地の瞬間を重ねて書く
% Object: 11/25 一枚にまとめる

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

load('fixedPoints_for_y0=0.62_dx0=13,kt=300.mat')



%for i = 1:length(fixedPoint)
    
    i = 26;

    q_fix = fixedPoint(i).q_ini;
    u_fix(1) = fixedPoint(i).u_fix(1);
    u_fix(2) = fixedPoint(i).u_fix(2);

    [eigenValues, eivenVectors, jacobi] = calc_eigenvalue(model, q_fix, u_fix);

    %床反力の計算
    GRF_hind = model.kh*(model.l4 - model.lout(:,1));    % 後脚
    GRF_fore = model.kf*(model.l4 - model.lout(:,2));    % 前脚

    %logdata出力
    diagonal = diag(eigenValues);
    logdata(i).eigenValue = diagonal;
    logdata(i).eivenVectors = eivenVectors;
    logdata(i).jacobi = jacobi;
    logdata(i).eeout = model.eeout;
    logdata(i).leg_h = model.lout(:,1);       %l_hind の履歴
    logdata(i).leg_f = model.lout(:,2);       %l_fore の履歴
    logdata(i).g_h_out = model.gout(:, 1);    %gamma_hind の履歴
    logdata(i).g_f_out = model.gout(:, 2);    %gamma_fore の履歴
    logdata(i).GRF_hind = GRF_hind;
    logdata(i).GRF_fore = GRF_fore;

    % maxGRF計算
    % fixedPoint(i).maxGRF_hind = model.kh*(model.l3 - min(model.lout(:,1)));   % 後脚
    % fixedPoint(i).maxGRF_fore = model.kf*(model.l4 - min(model.lout(:,2)));   % 前脚

    % maxGRFのインデックスを返す(この時が時間の平均値)
    [M_h,I_h] = max(GRF_hind);
    [M_f,I_f] = max(GRF_fore);

    fixedPoint(i).I_h = I_h;
    fixedPoint(i).I_f = I_f;
   
    % maxGRF時のgammaを算出
    fixedPoint(i).gamma_h_av = logdata(i).g_h_out(I_h); %I_h番目のgammaがmaxGRFの時のgamma
    fixedPoint(i).gamma_f_av = logdata(i).g_f_out(I_f); 

    % Poulakakisの式から，接地角と離地角を算出
    % touch down
    fixedPoint(i).gamma_h_td = model.gamma_h_td;
    fixedPoint(i).gamma_f_td = model.gamma_f_td;
    % lift off
    fixedPoint(i).gamma_h_lo = - fixedPoint(i).gamma_f_td;
    fixedPoint(i).gamma_f_lo = - fixedPoint(i).gamma_h_td;

%end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 図形を描写  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %% 後脚  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % max後脚 ---------------------------------------------------------------------------------
    x_1 = model.qout(I_h, 1);   %質量中心
    y_1 = model.qout(I_h, 2);
    th_1 = model.qout(I_h, 3);
    ph_1 = model.qout(I_h, 4);

    x_joint_1(i) = x_1 - model.L * cos(ph_1) * cos(th_1) + model.L * cos(th_1 - ph_1);   %ジョイント部
    y_joint_1(i) = y_1 - model.L * cos(ph_1) * sin(th_1) + model.L * sin(th_1 - ph_1);

    x_hip_1(i) = x_1 - model.L * cos(th_1) * cos(ph_1) - model.L * cos(th_1 - ph_1);  %胴体
    y_hip_1(i) = y_1 - model.L * cos(ph_1) * sin(th_1) - model.L * sin(th_1 - ph_1);
    x_head_1(i) = x_1 + model.L * cos(th_1) * cos(ph_1) + model.L * cos(th_1 + ph_1);
    y_head_1(i) = y_1 + model.L * cos(ph_1) * sin(th_1) + model.L * sin(th_1 + ph_1);
        
    x_hipjoint_1(i) = x_1 - model.L * cos(th_1) * cos(ph_1) - model.D * cos(th_1 - ph_1);    %関節
    y_hipjoint_1(i) = y_1 - model.L * cos(ph_1) * sin(th_1) - model.D * sin(th_1 - ph_1);
    x_headjoint_1(i) = x_1 + model.L * cos(th_1) * cos(ph_1) + model.D * cos(th_1 + ph_1);
    y_headjoint_1(i) = y_1 + model.L * cos(ph_1) * sin(th_1) + model.D * sin(th_1 + ph_1);

    x_foot_b_1(i) = x_hipjoint_1(i) + logdata(i).leg_h(I_h) * sin(logdata(i).g_h_out(I_h));     %脚先
    y_foot_b_1(i) = y_hipjoint_1(i) - logdata(i).leg_h(I_h) * cos(logdata(i).g_h_out(I_h));
    x_foot_f_1(i) = x_headjoint_1(i) + logdata(i).leg_f(I_h) * sin(logdata(i).g_f_out(I_h));
    y_foot_f_1(i) = y_headjoint_1(i) - logdata(i).leg_f(I_h) * cos(logdata(i).g_f_out(I_h));

 
    %% td後脚 ---------------------------------------------------------------------------------------------------

    if logdata(i).eeout(2) == 2      %phase2がeve2なら後脚から接地

        x_3 = model.qeout(1,1);   %質量中心
        y_3 = model.qeout(1,2);
        th_3 = model.qeout(1,3);
        ph_3 = model.qeout(1,4);

        x_joint_3(i) = x_3 - model.L * cos(ph_3) * cos(th_3) + model.L * cos(th_3 - ph_3);   %ジョイント部
        y_joint_3(i) = y_3 - model.L * cos(ph_3) * sin(th_3) + model.L * sin(th_3 - ph_3);

        x_hip_3(i) = x_3 - model.L * cos(th_3) * cos(ph_3) - model.L * cos(th_3 - ph_3);  %胴体
        y_hip_3(i) = y_3 - model.L * cos(ph_3) * sin(th_3) - model.L * sin(th_3 - ph_3);
        x_head_3(i) = x_3 + model.L * cos(th_3) * cos(ph_3) + model.L * cos(th_3 + ph_3);
        y_head_3(i) = y_3 + model.L * cos(ph_3) * sin(th_3) + model.L * sin(th_3 + ph_3);
        
        x_hipjoint_3(i) = x_3 - model.L * cos(th_3) * cos(ph_3) - model.D * cos(th_3 - ph_3);    %関節
        y_hipjoint_3(i) = y_3 - model.L * cos(ph_3) * sin(th_3) - model.D * sin(th_3 - ph_3);
        x_headjoint_3(i) = x_3 + model.L * cos(th_3) * cos(ph_3) + model.D * cos(th_3 + ph_3);
        y_headjoint_3(i) = y_3 + model.L * cos(ph_3) * sin(th_3) + model.D * sin(th_3 + ph_3);

        x_foot_b_3(i) = model.xh_toe;    %脚先
        y_foot_b_3(i) = 0;
        x_foot_f_3(i) = x_headjoint_3(i) + model.lf * sin(model.gamma_f_td);
        y_foot_f_3(i) = y_headjoint_3(i) - model.lf * cos(model.gamma_f_td);



    elseif logdata(i).eeout(2) == 4      %phase2がeve4なら前脚から接地→後脚はphase4

        x_3 = model.qeout(3,1);   %質量中心
        y_3 = model.qeout(3,2);
        th_3 = model.qeout(3,3);
        ph_3 = model.qeout(3,4);
    
        x_joint_3(i) = x_3 - model.L * cos(ph_3) * cos(th_3) + model.L * cos(th_3- ph_3);   %ジョイント部
        y_joint_3(i) = y_3 - model.L * cos(ph_3) * sin(th_3) + model.L * sin(th_3 - ph_3);
    
        x_hip_3(i) = x_3 - model.L * cos(th_3) * cos(ph_3) - model.L * cos(th_3 - ph_3);  %胴体
        y_hip_3(i) = y_3 - model.L * cos(ph_3) * sin(th_3) - model.L * sin(th_3 - ph_3);
        x_head_3(i) = x_3 + model.L * cos(th_3) * cos(ph_3) + model.L * cos(th_3 + ph_3);
        y_head_3(i) = y_3 + model.L * cos(ph_3) * sin(th_3) + model.L * sin(th_3 + ph_3);
            
        x_hipjoint_3(i) = x_3 - model.L * cos(th_3) * cos(ph_3) - model.D * cos(th_3 - ph_3);    %関節
        y_hipjoint_3(i) = y_3 - model.L * cos(ph_3) * sin(th_3) - model.D * sin(th_3 - ph_3);
        x_headjoint_3(i) = x_3 + model.L * cos(th_3) * cos(ph_3) + model.D * cos(th_3 + ph_3);
        y_headjoint_3(i) = y_3 + model.L * cos(ph_3) * sin(th_3) + model.D * sin(th_3 + ph_3);
    
        x_foot_b_3(i) = model.xh_toe;    %脚先
        y_foot_b_3(i) = 0;
        x_foot_f_3(i) = x_headjoint_3(i) + model.lf * sin(model.gamma_f_td);
        y_foot_f_3(i) = y_headjoint_3(i) - model.lf * cos(model.gamma_f_td);

    end

    





    %% lo後脚 -----------------------------------------------------------------------------------------------------------------

    if logdata(i).eeout(2) == 2      %phase2がeve2なら後脚から接地

        x_5 = model.qeout(2,1);   %質量中心
        y_5 = model.qeout(2,2);
        th_5 = model.qeout(2,3);
        ph_5 = model.qeout(2,4);

        x_joint_5(i) = x_5 - model.L * cos(ph_5) * cos(th_5) + model.L * cos(th_5 - ph_5);   %ジョイント部
        y_joint_5(i) = y_5 - model.L * cos(ph_5) * sin(th_5) + model.L * sin(th_5 - ph_5);

        x_hip_5(i) = x_5 - model.L * cos(th_5) * cos(ph_5) - model.L * cos(th_5 - ph_5);  %胴体
        y_hip_5(i) = y_5 - model.L * cos(ph_5) * sin(th_5) - model.L * sin(th_5 - ph_5);
        x_head_5(i) = x_5 + model.L * cos(th_5) * cos(ph_5) + model.L * cos(th_5 + ph_5);
        y_head_5(i) = y_5 + model.L * cos(ph_5) * sin(th_5) + model.L * sin(th_5 + ph_5);
        
        x_hipjoint_5(i) = x_5 - model.L * cos(th_5) * cos(ph_5) - model.D * cos(th_5 - ph_5);    %関節
        y_hipjoint_5(i) = y_5 - model.L * cos(ph_5) * sin(th_5) - model.D * sin(th_5 - ph_5);
        x_headjoint_5(i) = x_5 + model.L * cos(th_5) * cos(ph_5) + model.D * cos(th_5 + ph_5);
        y_headjoint_5(i) = y_5 + model.L * cos(ph_5) * sin(th_5) + model.D * sin(th_5 + ph_5);

        x_foot_b_5(i) = x_hipjoint_5(i) + model.lh * sin(fixedPoint(i).gamma_h_lo);    %脚先
        y_foot_b_5(i) = 0;
        x_foot_f_5(i) = x_headjoint_5(i) + model.lf * sin(model.gamma_f_td);
        y_foot_f_5(i) = y_headjoint_5(i) - model.lf * cos(model.gamma_f_td);



    elseif logdata(i).eeout(2) == 4      %phase2がeve4なら前脚から接地→後脚はphase4

        x_5 = model.qeout(4,1);   %質量中心
        y_5 = model.qeout(4,2);
        th_5 = model.qeout(4,3);
        ph_5 = model.qeout(4,4);
    
        x_joint_5(i) = x_5 - model.L * cos(ph_5) * cos(th_5) + model.L * cos(th_5- ph_5);   %ジョイント部
        y_joint_5(i) = y_5 - model.L * cos(ph_5) * sin(th_5) + model.L * sin(th_5 - ph_5);
    
        x_hip_5(i) = x_5 - model.L * cos(th_5) * cos(ph_5) - model.L * cos(th_5 - ph_5);  %胴体
        y_hip_5(i) = y_5 - model.L * cos(ph_5) * sin(th_5) - model.L * sin(th_5 - ph_5);
        x_head_5(i) = x_5 + model.L * cos(th_5) * cos(ph_5) + model.L * cos(th_5 + ph_5);
        y_head_5(i) = y_5 + model.L * cos(ph_5) * sin(th_5) + model.L * sin(th_5 + ph_5);
            
        x_hipjoint_5(i) = x_5 - model.L * cos(th_5) * cos(ph_5) - model.D * cos(th_5 - ph_5);    %関節
        y_hipjoint_5(i) = y_5 - model.L * cos(ph_5) * sin(th_5) - model.D * sin(th_5 - ph_5);
        x_headjoint_5(i) = x_5 + model.L * cos(th_5) * cos(ph_5) + model.D * cos(th_5 + ph_5);
        y_headjoint_5(i) = y_5 + model.L * cos(ph_5) * sin(th_5) + model.D * sin(th_5 + ph_5);
    
        x_foot_b_5(i) = x_hipjoint_5(i) + model.lh * sin(fixedPoint(i).gamma_h_lo);    %脚先
        y_foot_b_5(i) = 0;
        x_foot_f_5(i) = x_headjoint_5(i) + model.lf * sin(model.gamma_f_td);
        y_foot_f_5(i) = y_headjoint_5(i) - model.lf * cos(model.gamma_f_td);

    end




    





    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% max前脚 --------------------------------------------------------------------------------------------------------------------------------------------------

    x_2 = model.qout(I_f, 1);   %質量中心
    y_2 = model.qout(I_f, 2);
    th_2 = model.qout(I_f, 3);
    ph_2 = model.qout(I_f, 4);

    x_joint_2(i) = x_2 - model.L * cos(ph_2) * cos(th_2) + model.L * cos(th_2 - ph_2);   %ジョイント部
    y_joint_2(i) = y_2 - model.L * cos(ph_2) * sin(th_2) + model.L * sin(th_2 - ph_2);

    x_hip_2(i) = x_2 - model.L * cos(th_2) * cos(ph_2) - model.L * cos(th_2 - ph_2);  %胴体
    y_hip_2(i) = y_2 - model.L * cos(ph_2) * sin(th_2) - model.L * sin(th_2 - ph_2);
    x_head_2(i) = x_2 + model.L * cos(th_2) * cos(ph_2) + model.L * cos(th_2 + ph_2);
    y_head_2(i) = y_2 + model.L * cos(ph_2) * sin(th_2) + model.L * sin(th_2 + ph_2);
        
    x_hipjoint_2(i) = x_2 - model.L * cos(th_2) * cos(ph_2) - model.D * cos(th_2 - ph_2);    %関節
    y_hipjoint_2(i) = y_2 - model.L * cos(ph_2) * sin(th_2) - model.D * sin(th_2 - ph_2);
    x_headjoint_2(i) = x_2 + model.L * cos(th_2) * cos(ph_2) + model.D * cos(th_2 + ph_2);
    y_headjoint_2(i) = y_2 + model.L * cos(ph_2) * sin(th_2) + model.D * sin(th_2 + ph_2);

    x_foot_b_2(i) = x_hipjoint_2(i) + logdata(i).leg_h(I_f) * sin(logdata(i).g_h_out(I_f));     %脚先
    y_foot_b_2(i) = y_hipjoint_2(i) - logdata(i).leg_h(I_f) * cos(logdata(i).g_h_out(I_f));
    x_foot_f_2(i) = x_headjoint_2(i) + logdata(i).leg_f(I_f) * sin(logdata(i).g_f_out(I_f));
    y_foot_f_2(i) = y_headjoint_2(i) - logdata(i).leg_f(I_f) * cos(logdata(i).g_f_out(I_f));


    %% td前脚---------------------------------------------------------------------------------------------------------------------------------

    if logdata(i).eeout(2) == 2      %phase2がeve2なら後脚から接地

        x_4 = model.qeout(3,1);   %質量中心
        y_4 = model.qeout(3,2);
        th_4 = model.qeout(3,3);
        ph_4 = model.qeout(3,4);

        x_joint_4(i) = x_4 - model.L * cos(ph_4) * cos(th_4) + model.L * cos(th_4 - ph_4);   %ジョイント部
        y_joint_4(i) = y_4 - model.L * cos(ph_4) * sin(th_4) + model.L * sin(th_4 - ph_4);

        x_hip_4(i) = x_4 - model.L * cos(th_4) * cos(ph_4) - model.L * cos(th_4 - ph_4);  %胴体
        y_hip_4(i) = y_4 - model.L * cos(ph_4) * sin(th_4) - model.L * sin(th_4 - ph_4);
        x_head_4(i) = x_4 + model.L * cos(th_4) * cos(ph_4) + model.L * cos(th_4 + ph_4);
        y_head_4(i) = y_4 + model.L * cos(ph_4) * sin(th_4) + model.L * sin(th_4 + ph_4);
        
        x_hipjoint_4(i) = x_4 - model.L * cos(th_4) * cos(ph_4) - model.D * cos(th_4 - ph_4);    %関節
        y_hipjoint_4(i) = y_4 - model.L * cos(ph_4) * sin(th_4) - model.D * sin(th_4 - ph_4);
        x_headjoint_4(i) = x_4 + model.L * cos(th_4) * cos(ph_4) + model.D * cos(th_4 + ph_4);
        y_headjoint_4(i) = y_4 + model.L * cos(ph_4) * sin(th_4) + model.D * sin(th_4 + ph_4);

        x_foot_b_4(i) = x_hipjoint_4(i) + model.lh * sin(model.gamma_h_td);    %脚先
        y_foot_b_4(i) = y_hipjoint_4(i) - model.lh * cos(model.gamma_h_td);
        x_foot_f_4(i) = model.xf_toe;
        y_foot_f_4(i) = 0;


    elseif logdata(i).eeout(2) == 4      %phase2がeve4なら前脚から接地→後脚はphase4

        x_4 = model.qeout(1,1);   %質量中心
        y_4 = model.qeout(1,2);
        th_4 = model.qeout(1,3);
        ph_4 = model.qeout(1,4);
    
        x_joint_4(i) = x_4 - model.L * cos(ph_4) * cos(th_4) + model.L * cos(th_4- ph_4);   %ジョイント部
        y_joint_4(i) = y_4 - model.L * cos(ph_4) * sin(th_4) + model.L * sin(th_4 - ph_4);
    
        x_hip_4(i) = x_4 - model.L * cos(th_4) * cos(ph_4) - model.L * cos(th_4 - ph_4);  %胴体
        y_hip_4(i) = y_4 - model.L * cos(ph_4) * sin(th_4) - model.L * sin(th_4 - ph_4);
        x_head_4(i) = x_4 + model.L * cos(th_4) * cos(ph_4) + model.L * cos(th_4 + ph_4);
        y_head_4(i) = y_4 + model.L * cos(ph_4) * sin(th_4) + model.L * sin(th_4 + ph_4);
            
        x_hipjoint_4(i) = x_4 - model.L * cos(th_4) * cos(ph_4) - model.D * cos(th_4 - ph_4);    %関節
        y_hipjoint_4(i) = y_4 - model.L * cos(ph_4) * sin(th_4) - model.D * sin(th_4 - ph_4);
        x_headjoint_4(i) = x_4 + model.L * cos(th_4) * cos(ph_4) + model.D * cos(th_4 + ph_4);
        y_headjoint_4(i) = y_4 + model.L * cos(ph_4) * sin(th_4) + model.D * sin(th_4 + ph_4);
    
        x_foot_b_4(i) = x_hipjoint_4(i) + model.lh * sin(model.gamma_h_td);    %脚先
        y_foot_b_4(i) = y_hipjoint_4(i) - model.lh * cos(model.gamma_h_td);
        x_foot_f_4(i) = model.xf_toe;
        y_foot_f_4(i) = 0;


    end

    %% lo前脚 -----------------------------------------------------------------------------------------------------------------


    if logdata(i).eeout(2) == 2      %phase2がeve2なら後脚から接地

        x_6 = model.qeout(4,1);   %質量中心
        y_6 = model.qeout(4,2);
        th_6 = model.qeout(4,3);
        ph_6 = model.qeout(4,4);

        x_joint_6(i) = x_6 - model.L * cos(ph_6) * cos(th_6) + model.L * cos(th_6 - ph_6);   %ジョイント部
        y_joint_6(i) = y_6 - model.L * cos(ph_6) * sin(th_6) + model.L * sin(th_6 - ph_6);

        x_hip_6(i) = x_6 - model.L * cos(th_6) * cos(ph_6) - model.L * cos(th_6 - ph_6);  %胴体
        y_hip_6(i) = y_6 - model.L * cos(ph_6) * sin(th_6) - model.L * sin(th_6 - ph_6);
        x_head_6(i) = x_6 + model.L * cos(th_6) * cos(ph_6) + model.L * cos(th_6 + ph_6);
        y_head_6(i) = y_6 + model.L * cos(ph_6) * sin(th_6) + model.L * sin(th_6 + ph_6);
        
        x_hipjoint_6(i) = x_6 - model.L * cos(th_6) * cos(ph_6) - model.D * cos(th_6 - ph_6);    %関節
        y_hipjoint_6(i) = y_6 - model.L * cos(ph_6) * sin(th_6) - model.D * sin(th_6 - ph_6);
        x_headjoint_6(i) = x_6 + model.L * cos(th_6) * cos(ph_6) + model.D * cos(th_6 + ph_6);
        y_headjoint_6(i) = y_6 + model.L * cos(ph_6) * sin(th_6) + model.D * sin(th_6 + ph_6);

        x_foot_b_6(i) = x_hipjoint_6(i) + model.lh * sin(model.gamma_h_td);    %脚先
        y_foot_b_6(i) = y_hipjoint_6(i) - model.lh * sin(model.gamma_h_td);
        x_foot_f_6(i) = x_headjoint_6(i) + model.lf * sin(fixedPoint(i).gamma_f_lo);
        y_foot_f_6(i) = 0;


    elseif logdata(i).eeout(2) == 4      %phase2がeve4なら前脚から接地→後脚はphase4

        x_6 = model.qeout(2,1);   %質量中心
        y_6 = model.qeout(2,2);
        th_6 = model.qeout(2,3);
        ph_6 = model.qeout(2,4);
    
        x_joint_6(i) = x_6 - model.L * cos(ph_6) * cos(th_6) + model.L * cos(th_6- ph_6);   %ジョイント部
        y_joint_6(i) = y_6 - model.L * cos(ph_6) * sin(th_6) + model.L * sin(th_6 - ph_6);
    
        x_hip_6(i) = x_6 - model.L * cos(th_6) * cos(ph_6) - model.L * cos(th_6 - ph_6);  %胴体
        y_hip_6(i) = y_6 - model.L * cos(ph_6) * sin(th_6) - model.L * sin(th_6 - ph_6);
        x_head_6(i) = x_6 + model.L * cos(th_6) * cos(ph_6) + model.L * cos(th_6 + ph_6);
        y_head_6(i) = y_6 + model.L * cos(ph_6) * sin(th_6) + model.L * sin(th_6 + ph_6);
            
        x_hipjoint_6(i) = x_6 - model.L * cos(th_6) * cos(ph_6) - model.D * cos(th_6 - ph_6);    %関節
        y_hipjoint_6(i) = y_6 - model.L * cos(ph_6) * sin(th_6) - model.D * sin(th_6 - ph_6);
        x_headjoint_6(i) = x_6 + model.L * cos(th_6) * cos(ph_6) + model.D * cos(th_6 + ph_6);
        y_headjoint_6(i) = y_6 + model.L * cos(ph_6) * sin(th_6) + model.D * sin(th_6 + ph_6);
    
        x_foot_b_6(i) = x_hipjoint_6(i) + model.lh * sin(model.gamma_h_td);    %脚先
        y_foot_b_6(i) = y_hipjoint_6(i) - model.lh * sin(model.gamma_h_td);
        x_foot_f_6(i) = x_headjoint_6(i) + model.lf * sin(fixedPoint(i).gamma_f_lo);
        y_foot_f_6(i) = 0;

    end






%%% グラフに出力 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    h1 = figure;
    set(h1, 'DoubleBuffer', 'off');
    subplot(2,1,1)
    xlim([(x_hip_3(i))-0.3 (x_head_5(i))+0.5])
    ylim([-0.2 1.1])
    line([(x_hip_3(i))-0.8 (x_head_5(i))+1.5], [0, 0], 'color', 'k', 'LineWidth', 1);
    axis equal
    grid on
    grid minor

    body1_1 = line([x_hip_1(i), x_joint_1(i)], [y_hip_1(i), y_joint_1(i)], 'color', 'r', 'LineWidth', 3);
    body2_1 = line([x_joint_1(i), x_head_1(i)], [y_joint_1(i), y_head_1(i)], 'color', 'r', 'LineWidth', 3);
    hindLeg_1 = line([x_hipjoint_1(i), x_foot_b_1(i)], [y_hipjoint_1(i), y_foot_b_1(i)], 'color', 'r', 'LineWidth', 3);
    foreLeg_1 = line([x_headjoint_1(i), x_foot_f_1(i)], [y_headjoint_1(i), y_foot_f_1(i)], 'color', 'r', 'LineWidth', 3);

    body1_3 = line([x_hip_3(i), x_joint_3(i)], [y_hip_3(i), y_joint_3(i)], 'color', 'k', 'LineWidth', 1);
    body2_3 = line([x_joint_3(i), x_head_3(i)], [y_joint_3(i), y_head_3(i)], 'color', 'k', 'LineWidth', 1);
    hindLeg_3 = line([x_hipjoint_3(i), x_foot_b_3(i)], [y_hipjoint_3(i), y_foot_b_3(i)], 'color', 'k', 'LineWidth', 1);
    foreLeg_3 = line([x_headjoint_3(i), x_foot_f_3(i)], [y_headjoint_3(i), y_foot_f_3(i)], 'color', 'k', 'LineWidth', 1);


    body1_5 = line([x_hip_5(i), x_joint_5(i)], [y_hip_5(i), y_joint_5(i)], 'color', 'k', 'LineWidth', 1);
    body2_5 = line([x_joint_5(i), x_head_5(i)], [y_joint_5(i), y_head_5(i)], 'color', 'k', 'LineWidth', 1);
    hindLeg_5 = line([x_hipjoint_5(i), x_foot_b_5(i)], [y_hipjoint_5(i), y_foot_b_5(i)], 'color', 'k', 'LineWidth', 1);
    foreLeg_5 = line([x_headjoint_5(i), x_foot_f_5(i)], [y_headjoint_5(i), y_foot_f_5(i)], 'color', 'k', 'LineWidth', 1);
    


    subplot(2,1,2)
    line([(x_hip_4(i))-0.8 (x_head_6(i))+1.5], [0, 0], 'color', 'k', 'LineWidth', 1);
    xlim([(x_hip_4(i))-0.3 (x_head_6(i))+0.5])
    ylim([-0.2 1.1])

    body1_2 = line([x_hip_2(i), x_joint_2(i)], [y_hip_2(i), y_joint_2(i)], 'color', 'r', 'LineWidth', 3);
    body2_2 = line([x_joint_2(i), x_head_2(i)], [y_joint_2(i), y_head_2(i)], 'color', 'r', 'LineWidth', 3);
    hindLeg_2 = line([x_hipjoint_2(i), x_foot_b_2(i)], [y_hipjoint_2(i), y_foot_b_2(i)], 'color', 'r', 'LineWidth', 3);
    foreLeg_2 = line([x_headjoint_2(i), x_foot_f_2(i)], [y_headjoint_2(i), y_foot_f_2(i)], 'color', 'r', 'LineWidth', 3);
    % line([min(x_hip_2(i)) - 0.3 max(x_head_2(i)) + 0.8], [0, 0], 'color', 'k', 'LineWidth', 1);
    % hold on

    body1_4 = line([x_hip_4(i), x_joint_4(i)], [y_hip_4(i), y_joint_4(i)], 'color', 'k', 'LineWidth', 1);
    body2_4 = line([x_joint_4(i), x_head_4(i)], [y_joint_4(i), y_head_4(i)], 'color', 'k', 'LineWidth', 1);
    hindLeg_4 = line([x_hipjoint_4(i), x_foot_b_4(i)], [y_hipjoint_4(i), y_foot_b_4(i)], 'color', 'k', 'LineWidth', 1);
    foreLeg_4 = line([x_headjoint_4(i), x_foot_f_4(i)], [y_headjoint_4(i), y_foot_f_4(i)], 'color', 'k', 'LineWidth', 1);
    % line([min(x_hip_4(i)) - 0.3 max(x_head_4(i)) + 0.8], [0, 0], 'color', 'k', 'LineWidth', 1);
    % hold on

    axis equal
    body1_6 = line([x_hip_6(i), x_joint_6(i)], [y_hip_6(i), y_joint_6(i)], 'color', 'k', 'LineWidth', 1);
    body2_6 = line([x_joint_6(i), x_head_6(i)], [y_joint_6(i), y_head_6(i)], 'color', 'k', 'LineWidth', 1);
    hindLeg_6 = line([x_hipjoint_6(i), x_foot_b_6(i)], [y_hipjoint_6(i), y_foot_b_6(i)], 'color', 'k', 'LineWidth', 1);
    foreLeg_6 = line([x_headjoint_6(i), x_foot_f_6(i)], [y_headjoint_6(i), y_foot_f_6(i)], 'color', 'k', 'LineWidth', 1);
    % line([min(x_hip_6(i)) - 0.3 max(x_head_6(i)) + 0.8], [0, 0], 'color', 'k', 'LineWidth', 1);
    grid on
    grid minor



if saveflag == true
        
    figname = ['plot_GRF']
    saveas(gcf, figname, 'png')
    disp('save finish!')

end
    