addpath /home/goodwintracking/TheCompleteFlyTrackingBundle/JAABA-master/perframe;
JABFiles = '/home/goodwintracking/TheCompleteFlyTrackingBundle/JABsFromFlyTracker/JABfilelist.txt';


% Apply Classifiers
% ==========================================================================
dirs = dir();
CurrDir = (pwd);
for p = 1:numel(dirs)
    if ~dirs(p).isdir
      continue;
    end
    JAABAname = dirs(p).name;
    if ismember(JAABAname,{'.','..'})
      continue;
    end 
    cd ([JAABAname]);
    disp(['Now applying classifiers for: ' JAABAname]);
    JAABADetect([JAABAname '_JAABA'],'jablistfile',JABFiles);
    cd (CurrDir)
end

exit
