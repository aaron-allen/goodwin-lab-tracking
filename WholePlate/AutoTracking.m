% Aaron M. Allen and Annika Rings, 2018.10.09

% This script is used to automatically run the Caltech FlyTracker without the GUI



addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/FlyTracker-1.0.5'));


% Track videos
% ==========================================================================
% list of all folders to be processed

folders = {pwd};
diary('tracker_logfile.log')

% set options (omit any or all to use default options)
% options.granularity  = 10000;
options.num_chunks   = 1;       % set either granularity or num_chunks - using more than 1 chunk leads to orientation errors
options.num_cores    = 1;       
options.max_minutes  = 15;      % tracking 15 minutes to save on RAM
options.save_JAABA   = 1;
options.save_seg     = 1;
diary on
disp('Now Tracking Videos');


% loop through all folders - even though there is only one folder ...
for f=1:numel(folders)
    
	% set parameters for specific folder
    videos.dir_in  = folders{f};
    videos.dir_out = folders{f}; % save results into video folder
    videos.filter = '*.ufmf';     % extension of the videos to process
    
	% track all videos within folder
    tracker(videos,options);
    
    dirs = dir;
    for p = 1:numel(dirs)
        if ~dirs(p).isdir
          continue;
        end
        name = dirs(p).name;
        if ismember(name,{'.','..'})
          continue;
        end
        % move the calibration file to the tracking directory
        calibfile = ([name '/' name '-calibration.mat']);
        if ~exist(calibfile)
            copyfile('calibration.mat',calibfile) 
        end
    end
end

diary off
disp('now exiting the for-loop');

exit
