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


folders = {pwd};

diary([OutputDirectory '/' FileName '/Logs/tracker_logfile.log'])
diary on
disp('Now Tracking Videos');


% set options (omit any or all to use default options)
options.num_chunks   = maxNumCompThreads;
options.num_cores    = maxNumCompThreads*2;
options.max_minutes  = 15;
options.save_JAABA   = true;
options.save_xls     = false;
options.save_seg     = false;


options.startframe   = track_start;
options.fr_samp      = 200;
options.arena_r_mm   = 20;
options.n_flies      = flies_per_arena;

options.force_all       = true;
options.force_calib     = true;
options.force_tracking  = true;
options.force_features  = true;


options.f_parent_calib  = ['calibration_files/' best_calib_file];
video_file_name = [FileName '.' video_type];



% track video
tracker([],options,[],video_file_name);


diary off
% ==============================================================================================================================================================



exit
