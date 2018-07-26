addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/FlyTracker-1.0.5'));

% Track videos
% ==========================================================================

folders = {pwd};
VideosToBeTracked = dir('*.ufmf');
for V in length(VideosToBeTracked)
	options.num_chunks   = V;
	options.num_cores    = V;
	options.max_minutes  = Inf;
	options.save_JAABA   = 1;
	options.save_seg     = 1;
	disp('Now Tracking Videos');
    videos.dir_in  = folders{f};
    videos.dir_out = folders{f};
    videos.filter = '*.ufmf';
    tracker(videos,options);
	end
end
exit