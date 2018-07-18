%original script by Kristin Branson
%modified by Annika Rings May 2018

%for use with Goodwin Group videos
%requires prior tracking in ctrax
%tracks wing extension

%USAGE:
%1. convert videos to ufmf file format - single chamber per video
%2. track videos in Ctrax setting threshold for optimal body position and
%fly identity tracking (wings do not have to be tracked and detected in
%Ctrax)
%3. Create experiment folder containing required files (files must be named
%according to the naming conventions specified below)

%NAMING CONVENTIONS:

%video name: movie.ufmf
%annotation file: movie.ufmf.ann
%tracking data file: registered_trx.mat
%Wing tracking parameters file (to be created by user): WingTrackingParameters.txt

%4. enter the name of experiment folder below in the parameters section,
%amend the path if necessary in the set up paths section of the script
%5.find tracking result in your directory saved as test.mat, the
%perframe data in the perframe folder
%% set up paths
function SimpleWingTracking_wholedir(rootdatadir)
%addpath '/Users/annika/Documents/Projects/automated_tracking/Tracking_files_for_annika/JAABA-master/misc';
%addpath '/Users/annika/Documents/Projects/automated_tracking/Tracking_files_for_annika/JAABA-master/filehandling';
%these are the paths to the JABBA-master sufbolders 'misc' and
%'filehandling'
%these folders are required - download from github if missing

dirs = dir(rootdatadir);

for i = 1:numel(dirs)
  if ~dirs(i).isdir
    continue;
  end
  
  name = dirs(i).name;
  if ismember(name,{'.','..'})
    continue;
  end
  disp(name);



%this is the path to the experiment folder
%rootdatadir = '/Users/annika/Documents/Projects/automated_tracking/testfiles2';

%% parameters

% this is your experiment folder - update for each experiment
experiment_name = name;
expdir = fullfile(rootdatadir,experiment_name);
paramsfile = 'WingTrackingParameters.txt';

DEBUG = 1;

%%

[trx,perframedata] = TrackWings(expdir,...
  'paramsfile',paramsfile,...
  'debug',DEBUG,...
  'outtrxfilestr','test.mat');
end

