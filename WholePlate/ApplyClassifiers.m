% Aaron M. Allen, 2018.10.31
% This script uses the JAABADetect functio to apply JAABA classifiers in the JABfilelist.txt from the JABFromFlyTracker
% to videos that have been tracked with the Caltech FlyTracker. This script assume the directory structure that is
% generated by this tracker. 


addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/WholePlate'));
addpath /home/goodwintracking/TheCompleteFlyTrackingBundle/JAABA-master/perframe;
JABFiles = '/home/goodwintracking/TheCompleteFlyTrackingBundle/JABsFromFlyTracker/JABfilelist.txt';
wingJAB = '/home/goodwintracking/TheCompleteFlyTrackingBundle/JABsFromFlyTracker/WingGesture.jab';

% Apply Classifiers
% ==========================================================================
dirs = dir();
CurrDir = (pwd);
diary('JAABA_logfile.log')
disp(datetime('now'));
for p = 1:numel(dirs)
    if ~dirs(p).isdir
      continue;
    end
    JAABAname = dirs(p).name;
    if ismember(JAABAname,{'.','..'})
      continue;
    end 
    diary on
    cd (JAABAname);
    JAABAdir =(pwd);
    
    cd (JAABAdir);
    disp(['Now applying classifiers for: ' JAABAname]);
    if (round(FliesPerChamber)==2)
        error_handling_wrapper('JAABA_errors.log','JAABADetect',[JAABAname '_JAABA'],'jablistfile',JABFiles);
    else
        error_handling_wrapper('JAABA_errors.log','JAABADetect',[JAABAname '_JAABA'],'jabfiles',wingJAB);
    end
    diary off
    cd (CurrDir)
end
exit
