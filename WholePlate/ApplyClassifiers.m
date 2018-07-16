addpath /home/goodwintracking/TheCompleteFlyTrackingBundle/JAABA-master/perframe;
JABFiles = '/home/goodwintracking/TheCompleteFlyTrackingBundle/JABsFromFlyTracker/JABfilelist.txt';



% Apply Classifiers
% ==========================================================================
% dirs = dirs(~ismember({dirs.name},{'.','..'}));
cd(WatchaMaCallIt);
dirs = dir();
for p = 1:numel(dirs)
    if ~dirs(p).isdir
      continue;
    end
    JAABAname = dirs(p).name;
    if ismember(JAABAname,{'.','..'})
      continue;
    end 
    disp(['Now applying classifiers for: ' JAABAname]);
    JAABADetect(JAABAname,'jablistfile',JABFiles);
end




exit



