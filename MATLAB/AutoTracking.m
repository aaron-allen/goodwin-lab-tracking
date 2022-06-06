% Author: Aaron M. Allen
% Date: 2018.10.09
%     updated: 2021.12.02

% Description:
% This script is used to automatically run the Caltech FlyTracker without the GUI




% ==============================================================================================================================================================
% add our MATLAB code to path if its not there already
check = which('ApplyClassifiers');
if isempty(check)
    parentdir = fileparts(mfilename('fullpath'));
    addpath(genpath(parentdir));
end

% still need to add the tracker path though ..
% this is not as clean as above, but might clean up later.
addpath(genpath('../../FlyTracker'));
% ==============================================================================================================================================================



% ==============================================================================================================================================================
% The variable "OutputDirectory" and "FileName" are passed to the script when running from bash
% Do I need to change directory?
cd ([OutputDirectory '/' FileName]);
% ==============================================================================================================================================================



% ==============================================================================================================================================================
% Track videos



diary([OutputDirectory '/' FileName '/Logs/tracker_logfile.log'])
diary on
disp('Now Tracking Videos');


% set options (omit any or all to use default options)
options.num_cores    = 1; % maxNumCompThreads;          %
options.num_chunks   = 1; % options.num_cores .* 2;     %
options.max_minutes  = tracking_duration;
options.save_JAABA   = true;
options.save_xls     = false;
options.save_seg     = false;


options.startframe   = max(1, track_start .* FPS);
options.fr_samp      = 100;

if assay_type == "courtship"
    options.arena_r_mm   = 10;
end
if assay_type == "oviposition"
    options.arena_r_mm   = 50;
end

options.n_flies      = flies_per_arena;

options.force_all       = true;     %false;  %
options.force_calib     = true;     %false;  %
options.force_tracking  = true;     %false;  %
options.force_features  = true;     %false;  %


options.f_parent_calib  = ['parent_calib_files/' best_calib_file];
video_file_name = [FileName '.' video_type];



% track video
tracker([],options,[],video_file_name);
% ==============================================================================================================================================================





% ==============================================================================================================================================================
% Predict Sex

% make backups ...
copyfile([OutputDirectory '/' FileName '/' FileName '/' FileName '-track.mat'], ...
         [OutputDirectory '/' FileName '/Backups/' FileName '-track--backup_1_pre_predictsex.mat']);

% first predict the sex of the flies and add to the the track.mat file
FlyTrackerClassifySex_generic([OutputDirectory '/' FileName '/' FileName '/' FileName '-track.mat'],'track',sex_ratio,true);

if options.save_JAABA,
    % second predict the sex of the flies and add to the the trx.mat file
    copyfile([OutputDirectory '/' FileName '/' FileName '/' FileName '_JAABA/trx.mat'], ...
             [OutputDirectory '/' FileName '/Backups/' FileName '_JAABA/trx--backup_1_pre_predictsex.mat']);
    FlyTrackerClassifySex_generic([OutputDirectory '/' FileName '/' FileName '/' FileName '_JAABA/trx.mat'],'trx',sex_ratio,true);
end

% I realize that this is a bit silly to do the predictions twice and save to files twice,
% instead of predicting once and then writing to either or both files ... but oh well ...
% maybe I'll address this later ...
% ==============================================================================================================================================================






diary off
% ==============================================================================================================================================================



exit
