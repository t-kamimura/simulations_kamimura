% fileName: sub_anime.m
% initDate:　2020/11/05
% Object:  モデル図に近い絵が動く

clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaultAxesFontSize', 18);
set(0, 'defaultAxesFontName', 'Arial');
set(0, 'defaultTextFontSize', 24);
set(0, 'defaultTextFontName', 'Arial');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Construct a questdlg with three options
choice = questdlg('Do you want to save the result(s)?', ...
    'Saving opptions', ...
    'Yes', 'No', 'No');
% Handle response
saveflag = false;

switch choice
    case 'Yes'
        saveflag = true;
    case 'No'
        saveflag = false;
end

%saveflag = false;

% path追加
addpath(pwd, 'class')
addpath(pwd, 'symbolic')
addpath(pwd, 'eom')
addpath(pwd, 'event')
addpath(pwd, 'func')
addpath(pwd, 'data')
addpath(pwd, 'fig')


model = Twoleg;

E0 = 4500;
dtheta0 = -1.5;
% filename = ['data/identical_energy_dtheta/fixedPoints_for_E0=', num2str(E0),'_dtheta0=',num2str(dtheta0),'.mat'];
% filename = ['data/fixedPoints_for_kappa=',num2str(model.ke/model.kg),'_E0=', num2str(E0), '_dtheta0=', num2str(dtheta0), '.mat'];
filename = ['data/fixedPoints_for_ke=',num2str(model.ke),'_kg=',num2str(model.kg),'_E0=', num2str(E0), '_dtheta0=', num2str(dtheta0), '.mat'];
load(filename)

%%
i_sol = 6;

q_fix = fixedPoint_(i_sol).q_ini;
u_fix(1) = fixedPoint_(i_sol).z_fix(2);
u_fix(2) = fixedPoint_(i_sol).z_fix(3);

model.init
model.bound(q_fix, u_fix)
if dtheta0>0
    q_ini2 = model.qeout(4,:);
    model.init
    model.bound(q_ini2, u_fix)
end
%% animation
speed = 0.05;
FPS = 60;
dt = speed / FPS; % [ms]

% 時間を等間隔に修正
tstart = model.tout(1);
tfinal = model.tout(end);
tspan = tfinal - tstart;
teq = [tstart:dt:tfinal]';
t_mid = 1e3 * 0.5 * (tfinal + tstart);
qout_ = interp1(model.tout, model.qout, teq);
lout_ = interp1(model.tout, model.lout, teq);
gout_ = interp1(model.tout, model.gout, teq);

x_max = 2 * max(qout_(:, 1));

x_ground_st = -0.2;
y_ground_st = 0;
x_ground_fn = x_max;
y_ground_fn = 0;
anim_num = length(qout_(:, 1));

% 描画する各点を計算
for i = 1:anim_num
    x = qout_(i, 1);   %質量中心
    y = qout_(i, 2);
    th = qout_(i, 3);
    ph = qout_(i, 4);

    pos(i).joint = [x - model.L * cos(ph) * cos(th) + model.L * cos(th - ph); y - model.L * cos(ph) * sin(th) + model.L * sin(th - ph)];

    pos(i).hip   = [x - model.L * cos(th) * cos(ph) - model.L * cos(th - ph); y - model.L * cos(ph) * sin(th) - model.L * sin(th - ph)];
    pos(i).head  = [x + model.L * cos(th) * cos(ph) + model.L * cos(th + ph); y + model.L * cos(ph) * sin(th) + model.L * sin(th + ph)];

    pos(i).r1    = 0.5*(pos(i).hip + pos(i).joint);
    pos(i).r2    = 0.5*(pos(i).head + pos(i).joint);
    pos(i).th1   = th - ph;
    pos(i).th2   = th + ph;

    pos(i).hipjoint = [x - model.L * cos(th) * cos(ph) - model.D * cos(th - ph); y - model.L * cos(ph) * sin(th) - model.D * sin(th - ph)];
    pos(i).headjoint = [x + model.L * cos(th) * cos(ph) + model.D * cos(th + ph); y + model.L * cos(ph) * sin(th) + model.D * sin(th + ph)];
end

%% 剛体とバネを作る
psi = 0:0.02*pi:2*pi;
ellipse = [model.L*cos(psi); 0.35*model.L*sin(psi)];
spring_width = 0.05*model.l3;

% 動画を描写
% set(gca, 'position', [0.10, 0.15, 0.8, 0.7])

h1 = figure;
h1.Color = 'w';
h1.InnerPosition = [100, 50, 1024, 768];
set(h1, 'DoubleBuffer', 'off');

axis equal

F = [];

for i_t = 1:1:anim_num
    cla
    hold on

    % body1 (hind)
    R1 = [cos(pos(i_t).th1) -sin(pos(i_t).th1); sin(pos(i_t).th1) cos(pos(i_t).th1)];
    body1 = pos(i_t).r1*ones(1,length(psi)) + R1*ellipse;
    plot([body1(1,:)],[body1(2,:)],'k','LineWidth', 1);
    % body (fore)
    R2 = [cos(pos(i_t).th2) -sin(pos(i_t).th2); sin(pos(i_t).th2) cos(pos(i_t).th2)];
    body2 = pos(i_t).r2*ones(1,length(psi)) + R2*ellipse;
    plot([body2(1,:)],[body2(2,:)],'k','LineWidth', 1);
    % body spring
    th1 = pos(i_t).th1;
    th2 = pos(i_t).th2;
    phset = linspace(th1-pi,2*pi+th2,200);
    rset = linspace(0.2*model.L,0.1*model.L,200);
    spring = pos(i_t).joint*ones(1,length(phset))+[rset.*cos(phset); rset.*sin(phset)];
    plot(spring(1,:),spring(2,:),'linewidth',2,'color','b')
    % leg1 spring (hind)
    R1 = [cos(gout_(i_t, 1)) -sin(gout_(i_t, 1)); sin(gout_(i_t, 1)) cos(gout_(i_t, 1))];
    spring_normal(:,1) = [0; 0];
    spring_normal(:,2) = [0; -0.2*lout_(i_t,1)];
    spring_normal(:,3) = [spring_width;  -0.25*lout_(i_t,1)];
    spring_normal(:,4) = [-spring_width; -0.35*lout_(i_t,1)];
    spring_normal(:,5) = [spring_width;  -0.45*lout_(i_t,1)];
    spring_normal(:,6) = [-spring_width; -0.55*lout_(i_t,1)];
    spring_normal(:,7) = [spring_width;  -0.65*lout_(i_t,1)];
    spring_normal(:,8) = [-spring_width; -0.75*lout_(i_t,1)];
    spring_normal(:,9) = [0; -0.8*lout_(i_t,1)];
    spring_normal(:,10) = [0; -1*lout_(i_t,1)];
    spring_hind = pos(i_t).hipjoint*ones(1,length(spring_normal)) + R1*spring_normal;
    for i_s = 1:9
        if abs(lout_(i_t,1)-model.l3)<1e-3
            line([spring_hind(1,i_s) spring_hind(1,i_s+1)],[spring_hind(2,i_s) spring_hind(2,i_s+1)],'linewidth',2,'color',[0.8 0.8 0.8])
        else
            line([spring_hind(1,i_s) spring_hind(1,i_s+1)],[spring_hind(2,i_s) spring_hind(2,i_s+1)],'linewidth',4,'color','k')
        end
    end
    % leg2 spring (fore)
    R2 = [cos(gout_(i_t, 2)) -sin(gout_(i_t, 2)); sin(gout_(i_t, 2)) cos(gout_(i_t, 2))];
    spring_normal(:,1) = [0; 0];
    spring_normal(:,2) = [0; -0.2*lout_(i_t,2)];
    spring_normal(:,3) = [spring_width;  -0.25*lout_(i_t,2)];
    spring_normal(:,4) = [-spring_width; -0.35*lout_(i_t,2)];
    spring_normal(:,5) = [spring_width;  -0.45*lout_(i_t,2)];
    spring_normal(:,6) = [-spring_width; -0.55*lout_(i_t,2)];
    spring_normal(:,7) = [spring_width;  -0.65*lout_(i_t,2)];
    spring_normal(:,8) = [-spring_width; -0.75*lout_(i_t,2)];
    spring_normal(:,9) = [0; -0.8*lout_(i_t,2)];
    spring_normal(:,10) = [0; -1*lout_(i_t,2)];
    spring_fore = pos(i_t).headjoint*ones(1,length(spring_normal)) + R2*spring_normal;
    for i_s = 1:9
        if abs(lout_(i_t,2)-model.l3)<1e-3
            line([spring_fore(1,i_s) spring_fore(1,i_s+1)],[spring_fore(2,i_s) spring_fore(2,i_s+1)],'linewidth',2,'color',[0.8 0.8 0.8])
        else
            line([spring_fore(1,i_s) spring_fore(1,i_s+1)],[spring_fore(2,i_s) spring_fore(2,i_s+1)],'linewidth',4,'color','k')
        end
    end
    % timer
    strng = [num2str(teq(i_t), '%.3f'), ' s'];
    t = text(pos(i_t).joint(1)+0.5, -0.1, strng, 'color', 'k', 'fontsize', 24);
    text(pos(i_t).joint(1)-0.7, -0.1, ['x',num2str(speed)], 'color', 'k', 'fontsize', 24);

    % label
    if teq(i_t) < model.teout(2)
        if model.qeout(1,8) < 0
            label = 'Extended Flight';
        else
            label = 'Gathered Flight';
        end
    elseif teq(i_t) < model.teout(3)
        if model.q_ini(7)>0
            label = 'Hind stance';
        else
            label = 'Fore stance';
        end
    elseif teq(i_t) < model.teout(5)
        if model.qeout(4,3) > 0
            label = 'Extended Flight';
        else
            label = 'Gathered Flight';
        end
    elseif teq(i_t) < model.teout(6)
        if model.q_ini(7) > 0
            label = 'Fore stance';
        else
            label = 'Hind stance';
        end
    else
        if model.qeout(1,8) < 0
            label = 'Extended Flight';
        else
            label = 'Gathered Flight';
        end
    end
    text(pos(i_t).joint(1), 1, label, 'color', 'k', 'fontsize',24,'HorizontalAlignment','center');
    
    
    xlim([pos(i_t).joint(1) - 1, pos(i_t).joint(1) + 1])
    line([pos(i_t).joint(1) - 1.2, pos(i_t).joint(1) + 1.2],[0 0],'color','k','linewidth',2)
    ylim([-0.2 1.3])
    drawnow

    if saveflag == true
        F = [F; getframe(h1)];
    end

end


if saveflag == true
    videoobj = VideoWriter(['E=',num2str(E0),'_dtheta=',num2str(dtheta0),'_i=',num2str(i_sol),'_movie.mp4'], 'MPEG-4');
    videoobj.FrameRate = FPS;
    fprintf('video saving...')
    open(videoobj);
    writeVideo(videoobj, F);
    close(videoobj);
    fprintf('complete!\n');
end % save
