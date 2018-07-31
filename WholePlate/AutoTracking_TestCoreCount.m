addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/FlyTracker-1.0.5'));

% Track videos
% ==========================================================================

VideosToBeTracked = dir('*.ufmf');
for v = 1:length(VideosToBeTracked)
	options.num_chunks   = v;
	options.num_cores    = v;
	options.max_minutes  = Inf;
	options.save_JAABA   = 1;
	options.save_seg     = 1;
	disp('Now Tracking Videos');
    videos.dir_in  = pwd;
    videos.dir_out = pwd;
    videos.filter = '*.ufmf';
    tracker(videos,options);
end
exit