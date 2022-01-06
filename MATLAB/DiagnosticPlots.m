% Author: Aaron M. Allen
% Date: 2018.10.04
%     updated: 2021.12.02


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  DEPRECATED  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Description:
% DiagnosticPlots.m loads the tracking data .mat files and generates plots of different features.
% These include: area, facing angle, distance to other, x and y postion, amoung others.



% The variable "OutputDirectory" and "FileName" are passed to the script when running from bash
% Do I need to change directory?
cd ([OutputDirectory '/' FileName]);






% Diagnostic Plots
% =====================================================================


diary([OutputDirectory '/' FileName '/Logs/DiagnosticPlot_logfile.log'])
diary on


ParentDir = pwd;
dirs = dir();
ResultsFolder = [OutputDirectory '/' FileName '/Results'];


errorlogfile = strcat(OutputDirectory,'/',FileName,'/Logs/DiagnosticPlot_errors.log');
try
    load('calibration.mat');
    NumberOfArenas = (calib.n_chambers);
    cd ([FileName '/' FileName '_JAABA']);
    disp(['Now Plotting: ' FileName]);


    % Setup Current folder name for saving files etc
    % =====================================================================
    CurrFolder = regexp(pwd,'[^/\\]+(?=[/\\]?$)','once','match');


    % Load Data
    % =====================================================================
    IdCorr = dir('*_id_corrected.mat');
    if length(IdCorr) >=1
        load('trx_id_corrected.mat');
        cd 'perframe'
        LogVel = load('log_vel_id_corrected.mat');
        LogAngVel = load('log_ang_vel_id_corrected.mat');
        DistToOther = load('dist_to_other_id_corrected.mat');
        FacingAngle = load('facing_angle_id_corrected.mat');
        AxisRation = load('norm_axis_ratio_id_corrected.mat');
		cd ..
    else
		load('trx.mat');
        cd 'perframe'
        LogVel = load('log_vel.mat');
        LogAngVel = load('log_ang_vel.mat');
        DistToOther = load('dist_to_other.mat');
        FacingAngle = load('facing_angle.mat');
        AxisRation = load('norm_axis_ratio.mat');
		cd ..
	end

    % Rolling Average to Smooth data:
    % Set the windowsize (in frames) the range you want to average over.
    windowSize = 1; % a value of 1 means no smoothing
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    % NB: The velocity plot is very noisy without smoothing, so I have set its
    % own smoothing function with its own window size that you have to be
    % manipulated independently. The Velocity plot code is at line ~210-235.

    NumberOfFlies = length([trx.id]);
    for F = 1:(NumberOfFlies/2)
    %for F = 1:1
        G = (2.*F)-1;


        % Figure 1
        % =====================================================================
        % =====================================================================
        % Setup Plot - be be saved to the size of A4
        % =====================================================================
        DiagnosticFigure1 = figure('rend','painters','pos',[10 10 900 1200]);
        DiagnosticFigure1.Units = 'centimeters';
        DiagnosticFigure1.PaperType='A4';


        % Area - if a male and female were tracked, and assuming the male is
        % smaller than the female, this lets us see if there were any identity
        % swaps and if the male was correctly identified as track 1.
        % =====================================================================
        y1 = filter(b,a,(trx(G).a_mm).*(trx(G).b_mm).*pi.*16);
        y2 = filter(b,a,(trx(G+1).a_mm).*(trx(G+1).b_mm).*pi.*16);
        subplot(5,1,1)
        % plot(x,y2,'m','LineWidth',1)
        plot(y2,'m','LineWidth',1)
        ArenaNumber = (trx(G).id + 1)/2;
        title([CurrFolder '_Arena_' char(string(ArenaNumber))], 'Interpreter', 'none');
        xlabel('Frame Number');
        ylabel('Area (mm^2)');
        hold on
        % grid on
        ylim([0 20])
        % plot(x,y1,'b','LineWidth',1)
        plot(y1,'b','LineWidth',1)
        hold off

        % Distance to Other - pretty self explanitory
        % =====================================================================
        y11 = filter(b,a,(DistToOther.data{1,trx(G).id}));
        y12 = filter(b,a,(DistToOther.data{1,trx(G+1).id}));
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
        % Calculating the instantaneous rate of change in the angle of the fly
        dThetaM=diff(trx(G).theta);
        dThetaF=diff(trx(G+1).theta);
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
        y13 = filter(b,a,(FacingAngle.data{1,trx(G).id}));
        y14 = filter(b,a,(FacingAngle.data{1,trx(G+1).id}));
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
        y3 = filter(bVel,a,(exp(LogVel.data{1,trx(G).id})));
        y4 = filter(bVel,a,(exp(LogVel.data{1,trx(G+1).id})));
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
        PDFName1 = [CurrFolder '_Arena_' char(sprintfc('%02d', F)) '_fig1' '.pdf'];
        print(DiagnosticFigure1, PDFName1, '-fillpage', '-dpdf', '-r600')





        % Figure 2
        % =====================================================================
        % =====================================================================
        % Setup Plot - be be saved to the size of A4
        % =====================================================================
        DiagnosticFigure2 = figure('rend','painters','pos',[10 10 900 1200]);
        DiagnosticFigure2.Units = 'centimeters';
        DiagnosticFigure2.PaperType='A4';

        % Angle
        % =====================================================================
        y5 = filter(b,a,(trx(G).theta));
        y6 = filter(b,a,(trx(G+1).theta));
        subplot(6,1,1)
        % plot(x,y6,'m','LineWidth',1)
        plot(y6,'m','LineWidth',1)
        title([CurrFolder '_Arena_' char(string(ArenaNumber))], 'Interpreter', 'none');
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
        y7 = filter(b,a,(trx(G).x));
        y8 = filter(b,a,(trx(G+1).x));
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
        y9 = filter(b,a,(trx(G).y));
        y10 = filter(b,a,(trx(G+1).y));
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
        y17 = filter(b,a,(trx(G).a_mm).*4);
        y18 = filter(b,a,(trx(G+1).a_mm).*4);
        subplot(6,1,4)
        % plot(x,y18,'m','LineWidth',1)
        plot(y18,'m','LineWidth',1)
        xlabel('Frame Number');
        ylabel('Major Axis (mm)');
        hold on
        % grid on
        ylim([0 5])
        % plot(x,y17,'b','LineWidth',1)
        plot(y17,'b','LineWidth',1)
        hold off

        % b
        % =====================================================================
        y17 = filter(b,a,(trx(G).b_mm).*4);
        y18 = filter(b,a,(trx(G+1).b_mm).*4);
        subplot(6,1,5)
        % plot(x,y18,'m','LineWidth',1)
        plot(y18,'m','LineWidth',1)
        xlabel('Frame Number');
        ylabel('Minor Axis (mm)');
        hold on
        % grid on
        ylim([0 3])
        % plot(x,y17,'b','LineWidth',1)
        plot(y17,'b','LineWidth',1)
        hold off

        % Axis Ratio
        % =====================================================================
        y15 = filter(b,a,(AxisRation.data{1,trx(G).id}));
        y16 = filter(b,a,(AxisRation.data{1,trx(G+1).id}));
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
        PDFName2 = [CurrFolder '_Arena_' char(sprintfc('%02d', F)) '_fig2' '.pdf'];
        print(DiagnosticFigure2, PDFName2, '-fillpage', '-dpdf', '-r600')

        % Move PDFs
        % =====================================================================
        PDFList = dir('*.pdf');
        disp(['Now moving PDFs for: ' FileName]);
        for x = 1:length(PDFList)
            movefile(PDFList(x).name, ResultsFolder)
        end
        % =====================================================================

        close all
    end
catch ME
    errorMessage= ME.message;
    disp(errorMessage);
     cd (ParentDir);
    fidd = fopen(errorlogfile, 'a');
    fprintf(fidd, '%s\n', errorMessage); % To file
    fclose(fidd);
end
cd (ParentDir);



disp('All done plotting.');
diary off
exit
