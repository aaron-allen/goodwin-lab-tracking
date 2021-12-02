% Author: Aaron M. Allen
% Date: 2018.10.04
%     updated: 2021.12.02

% Description:

% Updated ExtractData.m srcipt:
% This script extracts and concatenates JAABA annotated behaviour scores,
% and Calteck FlyTracker feature data and raw tracking data. These data are
% saved to csv file to be more portable and saves it in a folder names 'Results'.

% This scipt assumes that it will be run across multiple folders containing
% tracking data for different videos. As such this script should be run in
% the parent directory containing all the video directories created by the
% Caltech FlyTracker scripts.



# The variable "OutputDirectory" and "FileName" are passed to the script when running from bash
# Do I need to change directory?
cd ([OutputDirectory '/' FileName]);








diary([OutputDirectory '/' FileName '/Logs/DiagnosticPlot_logfile.log'])
diary on


ParentDir = pwd;
dirs = dir();
ResultsFolder = [OutputDirectory '/' FileName '/Results'];


errorlogfile = strcat(OutputDirectory,'/',FileName,'/Logs/ExtractData_errors.log');
try
    cd(FileName);

    % Extracting the data from the track.mat, feat.mat, and JAABA score*.mat files
    % =====================================================================
    CurrentDirectory = pwd;

    TrackFile = dir('*-track_id_corrected.mat');
    FeatFile = dir('*-feat_id_corrected.mat');
    load(TrackFile.name);
    load(FeatFile.name);
    JAABAFolder = dir('*_JAABA');
    cd (JAABAFolder.name);
    load('trx_id_corrected.mat', 'trx');
    JAABAScoreFiles = dir('scores_*_id_corrected.mat');
    cd('perframe');
    perframeFiles = dir('*_id_corrected.mat');
    cd (CurrentDirectory)

    ArrayLength = size(trk.data,2);
    ArrayWidth = 3 + size(JAABAScoreFiles,1) + size(feat.data,3) + size(trk.data,3);
    trk.names = regexprep(trk.names, ' ', '_'); % spaces in the variable names gives an error when assembling the table
    AllData = [];
    AllStartPos = [];
    disp(['Now extracting tracking data from: ' name]);
    for I=1:size(trx,2)
        %disp(I);
        IdNumber = ones(ArrayLength,1)*trx(I).id; % important to use the trx(I).id due to the id_correction
        ArenaNumber = round((ones(ArrayLength,1)*trx(I).id)/2); % important to use the trx(I).id due to the id_correction
        FrameNumber = transpose(1:1:ArrayLength);
        IndStartPos = [];
        [IndStartPos{1:ArrayLength}] = deal(trx(I).startpos);
        IndStartPos = transpose(IndStartPos);
        IndData = NaN([ArrayLength ArrayWidth]);
        IndData(:,1:3) = [ArenaNumber, IdNumber, FrameNumber];
        cd (JAABAFolder.name);
        %disp('JAABA');
        for m = 1:numel(JAABAScoreFiles)
            FileData = load(fullfile(pwd, JAABAScoreFiles(m).name));
            IndJAABA = transpose(FileData.allScores.postprocessed{1,trx(I).id});
            ColPos = 3 + m;
            IndData(1:length(IndJAABA),ColPos) = IndJAABA;
            JAABAnames(1,(m)) = extractBetween(JAABAScoreFiles(m).name,'scores_','_id_corrected.mat');
        end
        cd ..;
        FeatureNames = [];
        feat.units = regexprep(feat.units, '/', 'per'); % forward slashes in the variable names gives an error when assembling the table
        %disp('feat');
        for B=1:length([feat.names])
            FeatureNames = [FeatureNames, strcat(feat.names(B),'__',feat.units(B))];
            IndFeat = transpose(feat.data((trx(I).id),:,B));
            ColPos = 3 + size(JAABAScoreFiles,1) + B;
            IndData(1:length(IndFeat),ColPos) = IndFeat;
        end
        TrackNames = [];
        trk.units = cellstr(["px", "px", "rad", "px", "px", "px", "px", "au", "px", "px", "px", "px", "px", "rad", "px", "rad", "px", "px", "px", "px", "px", "px", "px", "px", "px", "px", "px", "px", "px", "rad", "rad", "rad", "rad", "rad", "rad"]);
        %disp('track');
        for T=1:length([trk.names])
            TrackNames = [TrackNames, strcat(trk.names(T),'__',trk.units(T))];
            IndTrk = transpose(trk.data((trx(I).id),:,T));
            ColPos = 3 + size(JAABAScoreFiles,1) + size([feat.data],3) + T;
            IndData(1:length(IndTrk),ColPos) = IndTrk;
        end
        cd (CurrentDirectory);
        AllData = vertcat(AllData, IndData);
        AllStartPos = vertcat(AllStartPos, IndStartPos);
    end

    % Extract the name of the video
    % =====================================================================
    TempArray = [];
    HorzVideoArray = {};
    VertVideoArray = [];
    disp(['Now extracting Video name from: ' name]);
    [TempArray{1:length(AllData)}] = deal(name);
    HorzVideoArray = [HorzVideoArray, TempArray];
    VertVideoArray = transpose(HorzVideoArray);



    % Converting the arrays into tables - need to do this in order to append character vectors/matrices and number vectors/matrices
    % =====================================================================
    VideoVariableNames{1,1} = ('FileName');
    disp(['Making Names Table for: ' name])
    VideoTable = array2table(VertVideoArray, 'VariableNames', VideoVariableNames);

    StartPosVariableName{1,1} = ('StartPosition');
    StartPosTable = array2table(AllStartPos, 'VariableNames', StartPosVariableName);

    disp(['Making Data Table for: ' name])
    DataVariableNames = ['Arena', 'Id', 'Frame', JAABAnames, FeatureNames, TrackNames];
    AllDataTable = array2table(AllData, 'VariableNames', DataVariableNames);

    disp(['Making Final Table for: ' name])
    MySuperFinalTable = [VideoTable, StartPosTable, AllDataTable];
    disp(['Writing CSV for:' name])
    writetable(MySuperFinalTable, [ResultsFolder '/' name '_ALLDATA.csv']);


catch ME
    errorMessage= ME.message;
    disp(errorMessage);
    cd (ParentDir);
    fidd = fopen(errorlogfile, 'a');
    fprintf(fidd, '%s\n', errorMessage); % To file
    fclose(fidd);
end

exit
