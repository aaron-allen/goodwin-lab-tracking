addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/FlyTracker-1.0.5'));
addpath /home/goodwintracking/TheCompleteFlyTrackingBundle/JAABA-master/perframe;
JABFiles = '/home/goodwintracking/TheCompleteFlyTrackingBundle/JABfilelist.txt';


%Track videos
%==========================================================================
% list of all folders to be processed

folders = {pwd};

% set options (omit any or all to use default options)
%options.granularity  = 10000;
options.num_chunks   = 1;       % set either granularity or num_chunks
options.num_cores    = 1;
options.max_minutes  = Inf;
options.save_JAABA   = 1;
options.save_seg     = 1;
disp('Now Tracking Videos');
% loop through all folders
for f=1:numel(folders)
    % set parameters for specific folder
    videos.dir_in  = folders{f};
    videos.dir_out = folders{f}; % save results into video folder
    videos.filter = '*.ufmf';     % extension of the videos to process
    % track all videos within folder
    tracker(videos,options);
end





% Diagnostic Plots
% =====================================================================
dirs = dir();
for ii = 1:numel(dirs)
if ~dirs(ii).isdir
    continue;
end
WatchaMaCallIt = dirs(ii).name;
if ismember(WatchaMaCallIt,{'.','..'})
    continue;
end
cd ([WatchaMaCallIt '\' WatchaMaCallIt '_JAABA']);
disp(['Now Plotting: ' WatchaMaCallIt]);

% Setup Plot - be be saved to the size of A4
%=====================================================================
CurrFolder = regexp(pwd,'[^/\\]+(?=[/\\]?$)','once','match');
DiagnosticFigure1 = figure('rend','painters','pos',[10 10 900 1200]);
DiagnosticFigure1.Units = 'centimeters';
DiagnosticFigure1.PaperType='A4';

% Load Data
% =====================================================================
load('trx.mat');
cd 'perframe'
LogVel = load('log_vel.mat');
LogAngVel = load('log_ang_vel.mat');
DistToOther = load('dist_to_other.mat');
FacingAngle = load('facing_angle.mat');
AxisRation = load('norm_axis_ratio.mat');
cd ..
% Rolling Average to Smooth data:
% Set the windowsize (in frames) the range you want to average over.
windowSize = 1; % a value of 1 means no smoothing
b = (1/windowSize)*ones(1,windowSize);
a = 1;
% NB: The velocity plot is very noisy without smoothing, so I've set it's
% own smoothing function with it's own window size that you have to be
% manipulated independently. The Velocity plot code is at line ~210-235.


% Figure 1
% =====================================================================
% =====================================================================
% Area - if a male and female were tracked, and assuming the male is
% smaller than the female, this lets us see if there were any identity
% swaps and if the male was correctly identified as track 1.
% =====================================================================
y1 = filter(b,a,(trx(1).a_mm).*(trx(1).b_mm).*pi);
y2 = filter(b,a,(trx(2).a_mm).*(trx(2).b_mm).*pi);
subplot(5,1,1)
% plot(x,y2,'m','LineWidth',1)
plot(y2,'m','LineWidth',1)
title(CurrFolder, 'Interpreter', 'none');
xlabel('Frame Number');
ylabel('Area (mm^2)');
hold on
% grid on
ylim([0 1])
% plot(x,y1,'b','LineWidth',1)
plot(y1,'b','LineWidth',1)
hold off

% Distance to Other - pretty self explanitory
% =====================================================================
y11 = filter(b,a,(DistToOther.data{1,1}));
y12 = filter(b,a,(DistToOther.data{1,2}));
subplot(5,1,2)
% plot(x,y12,'m','LineWidth',1)
plot(y12,'m','LineWidth',1)
xlabel('Frame Number');
ylabel('Distance to Other (mm)');
ylim([0 20])
hold on
% grid on
% plot(x,y11,'b','LineWidth',1)
plot(y11,'b','LineWidth',1)
hold off

% Change in Angle - To identify orientation errors
% =====================================================================
% Calculating the instantaneous rate of change in the fly's angle 
dThetaM=diff(trx(1).theta);
dThetaF=diff(trx(2).theta);
% Values of +/-2pi are due to the fly's angle crossing the "zero" line and
% don't represent 'true' large changes in angle. So I've reset anything
% larger than 5 to 0.1, making the plot more informative to find the times
% when the fly's angle changes by pi, which would be an orientation
% miss-annotation.
for i = 1:length(dThetaM)
    if dThetaM(i) > 5
        dThetaM(i) = 0.1;
    end
end
for i = 1:length(dThetaF)
    if dThetaF(i) > 5
        dThetaF(i) = 0.1;
    end
end
for i = 1:length(dThetaM)
    if dThetaM(i) < -5
        dThetaM(i) = -0.1;
    end
end
for i = 1:length(dThetaF)
    if dThetaF(i) < -5
        dThetaF(i) = -0.1;
    end
end
subplot(5,1,3)
% plot(x(2:end),dThetaF,'m')
plot(dThetaF,'m')
ylim([-4 4])
xlabel('Frame Number');
ylabel('Change in Angle');
hold on
% plot(x(2:end),dThetaM,'b')
plot(dThetaM,'b')
hold off

% Facing Angle
% =====================================================================
y13 = filter(b,a,(FacingAngle.data{1,1}));
y14 = filter(b,a,(FacingAngle.data{1,2}));
subplot(5,1,4)
% plot(x,y14,'m','LineWidth',1)
plot(y14,'m','LineWidth',1)
xlabel('Frame Number');
ylabel('Facing Angle (rad)');
hold on
% grid on
ylim([-1 4])
% plot(x,y13,'b','LineWidth',1)
plot(y13,'b','LineWidth',1)
hold off

% Velocity
% =====================================================================
VelWindowSize = 200; 
bVel = (1/VelWindowSize)*ones(1,VelWindowSize);
y3 = filter(bVel,a,(exp(LogVel.data{1,1})));
y4 = filter(bVel,a,(exp(LogVel.data{1,2})));
subplot(5,1,5)
% plot(x,y4,'m','LineWidth',1)
plot(y4,'m','LineWidth',1)
xlabel('Frame Number');
ylabel('Velocity');
hold on
ylim([0 4])
% plot(x,y3,'b','LineWidth',1)
plot(y3,'b','LineWidth',1)
% grid on
hold off

% Save PDF
%=====================================================================
PDFName1 = [CurrFolder '_fig1' '.pdf'];
print(DiagnosticFigure1, PDFName1, '-dpdf', '-r0')


% Figure 2
% =====================================================================
% =====================================================================
DiagnosticFigure2 = figure('rend','painters','pos',[10 10 900 1200]);
u = DiagnosticFigure2.Units;
DiagnosticFigure2.Units = 'centimeters';
DiagnosticFigure2.PaperType='A4';

% Angle
% =====================================================================
y5 = filter(b,a,(trx(1).theta));
y6 = filter(b,a,(trx(2).theta));
subplot(6,1,1)
% plot(x,y6,'m','LineWidth',1)
plot(y6,'m','LineWidth',1)
title(CurrFolder, 'Interpreter', 'none');
xlabel('Frame Number');
ylabel('Angle (rad)');
hold on
% grid on
ylim([-4 4])
% plot(x,y5,'b','LineWidth',1)
plot(y5,'b','LineWidth',1)
hold off

% X
% =====================================================================
y7 = filter(b,a,(trx(1).x));
y8 = filter(b,a,(trx(2).x));
subplot(6,1,2)
% plot(x,y8,'m','LineWidth',1)
plot(y8,'m','LineWidth',1)
xlabel('Frame Number');
ylabel('X position (px)');
hold on
% grid on
% ylim([-4 4])
% plot(x,y7,'b','LineWidth',1)
plot(y7,'b','LineWidth',1)
hold off

% Y
% =====================================================================
y9 = filter(b,a,(trx(1).y));
y10 = filter(b,a,(trx(2).y));
subplot(6,1,3)
% plot(x,y10,'m','LineWidth',1)
plot(y10,'m','LineWidth',1)
xlabel('Frame Number');
ylabel('Y position (px)');
hold on
% grid on
% ylim([-4 4])
% plot(x,y9,'b','LineWidth',1)
plot(y9,'b','LineWidth',1)
hold off

% a
% =====================================================================
y17 = filter(b,a,(trx(1).a_mm));
y18 = filter(b,a,(trx(2).a_mm));
subplot(6,1,4)
% plot(x,y18,'m','LineWidth',1)
plot(y18,'m','LineWidth',1)
xlabel('Frame Number');
ylabel('Major Axis (mm)');
hold on
% grid on
ylim([0 1])
% plot(x,y17,'b','LineWidth',1)
plot(y17,'b','LineWidth',1)
hold off

% b
% =====================================================================
y17 = filter(b,a,(trx(1).b_mm));
y18 = filter(b,a,(trx(2).b_mm));
subplot(6,1,5)
% plot(x,y18,'m','LineWidth',1)
plot(y18,'m','LineWidth',1)
xlabel('Frame Number');
ylabel('Minor Axis (mm)');
hold on
% grid on
ylim([0 0.6])
% plot(x,y17,'b','LineWidth',1)
plot(y17,'b','LineWidth',1)
hold off

% Axis Ratio
% =====================================================================
y15 = filter(b,a,(AxisRation.data{1,1}));
y16 = filter(b,a,(AxisRation.data{1,2}));
subplot(6,1,6)
% plot(x,y16,'m','LineWidth',1)
plot(y16,'m','LineWidth',1)
xlabel('Frame Number');
ylabel('Axis Ratio');
hold on
ylim([0 3])
% plot(x,y15,'b','LineWidth',1)
plot(y15,'b','LineWidth',1)
% grid on
hold off

% Save PDF
%=====================================================================
PDFName2 = [CurrFolder '_fig2' '.pdf'];
print(DiagnosticFigure2, PDFName2, '-dpdf', '-r0')

close all

cd ..
cd ..

end
disp('All done plotting ... but the scheming continues!');



%Apply Classifiers
%==========================================================================
% dirs = dirs(~ismember({dirs.name},{'.','..'}));
cd(WatchaMaCallIt);
dirs = dir();
for p = 1:numel(dirs)
    if ~dirs(p).isdir
      continue;
    end
    JAABAname = dirs(p).name;
    if ismember(JAABAname,{'.','..'})
      continue;
    end 
    disp(['Now applying classifiers for: ' JAABAname]);
    JAABADetect(JAABAname,'jablistfile',JABFiles);
end




exit



