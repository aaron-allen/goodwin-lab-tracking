%original script by Kristin Branson
%modified by Annika Rings May 2018

%for use with Goodwin Group videos
%requires prior tracking in ctrax
%tracks wing extension

%PLEASE NOTE:
%In order for this script to work, the CtraxJAABA\cbtrack-master\simplewing
%folder has to be present and it has to be added to the matlab search path
%(for example, with the command 'addpath' or in the GUI)
%alternatively, you can navigate to this folder and run the script from
%there

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

%4. put all the experiments in a separate folder for each experiment, named after the name of the experiment (or any desired unique identifier)
%5. put all experiment folders in a directory
%6. Call this function by typing (in the command line):
%SimpleWingTracking_wholedir(rootdatadir)
%where rootdatadir is the complete (absolute or relative) path to your
%directory containing the experiment directories
%7.find tracking result in your directory saved as test.mat, the
%perframe data in the perframe folder

%this is the function to be called
function SimpleWingTracking_wholedir(rootdatadir)

dirs = dir(rootdatadir);
%executes command for all directories in the rootdatadir except the one
%Called 'WingTracking_Errors'
for i = 1:numel(dirs)
  if ~dirs(i).isdir
    continue;
  end
  
  name = dirs(i).name;
  if ismember(name,{'.','..'})
    continue;
  end
   if strcmpi(name,'WingTracking_Errors')
    continue;
  end
  disp(name);




%% parameters


experiment_name = name;
expdir = fullfile(rootdatadir,experiment_name);
paramsfile = 'WingTrackingParameters.txt';
errorfilename=strcat(name,'_error.txt');
errorfile=fullfile(rootdatadir,errorfilename);
errordirname='WingTracking_Errors';
errordir=fullfile(rootdatadir,errordirname);

DEBUG = 1;

%% tries to execute the function
%% if matlab throws an error, the error message is saved to a file
%% the experiment is moved to the WingTracking_Errors directory
%% the script continues with the next directory
try
   %this is the main function - it is defined in a separate file
    [trx,perframedata] = TrackWings(expdir,...
        'paramsfile',paramsfile,...
        'debug',DEBUG,...
        'outtrxfilestr','test.mat');
catch ME
    %this is the error handling section
    %error message is displayed and saved to errorfile
    errorMessage= ME.message;
    disp(errorMessage);
    fidd = fopen(errorfile, 'w');
	fprintf(fidd, '%s\n', errorMessage); % To file
	fclose(fidd);
    
    if~exist(errordir, 'dir')
        mkdir(errordir);
    end
    %experiment directory is moved to errordir
    inerrordir=fullfile(errordir,experiment_name);
    fclose('all');
    movefile(expdir, inerrordir);
    
end
end

