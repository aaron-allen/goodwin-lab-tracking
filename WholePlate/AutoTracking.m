addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/FlyTracker-1.0.5'));


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


exit
