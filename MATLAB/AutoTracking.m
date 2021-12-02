% Author: Aaron M. Allen
% Date: 2018.10.09
%     updated: 2021.12.02

% Description:
% This script is used to automatically run the Caltech FlyTracker without the GUI



% add our MATLAB code to path if its not there already
check = which('ApplyClassifiers');
if isempty(check)
    parentdir = fileparts(mfilename('fullpath'));
    addpath(genpath(parentdir));
end



# still need to add the tracker path though ..
# this is not as clean as above, but might clean up later.
addpath(genpath('../../FlyTracker'));




# The variable "OutputDirectory" and "FileName" are passed to the script when running from bash
# Do I need to change directory?
cd ([OutputDirectory '/' FileName]);







% Track videos
% ==========================================================================
% list of all folders to be processed

folders = {pwd};

diary([OutputDirectory '/' FileName '/Logs/tracker_logfile.log'])

% set options (omit any or all to use default options)
% options.granularity  = 10000;
options.num_chunks   = 1;       % set either granularity or num_chunks - using more than 1 chunk leads to orientation errors
options.num_cores    = 1;
options.max_minutes  = 15;      % tracking 15 minutes to save on RAM
options.save_JAABA   = 1;
options.save_seg     = 0;
diary on
disp('Now Tracking Videos');


% set parameters for specific folder
videos.dir_in  = {pwd};
videos.dir_out = {pwd};         % save results into video folder
videos.filter = ['*.' video_type];       % extension of the videos to process

% track video
tracker(videos,options);




% ==========================================================================
% move the calibration file to the tracking directory
% why ??? do we need this ??? we have 3 versions of the calib file ...

% dirs = dir;
% for p = 1:numel(dirs)
%     if ~dirs(p).isdir
%       continue;
%     end
%     name = dirs(p).name;
%     if ismember(name,{'.','..'})
%       continue;
%     end
%
%     calibfile = ([name '/' name '-calibration.mat']);
%     if ~exist(calibfile)
%         copyfile('calibration.mat',calibfile)
%     end
% end
% ==========================================================================


diary off

exit
