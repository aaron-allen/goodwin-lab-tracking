addpath /home/goodwintracking/TheCompleteFlyTrackingBundle/JAABA-master/perframe;
JABFiles = '/home/goodwintracking/TheCompleteFlyTrackingBundle/JABsFromFlyTracker/JABfilelist.txt';


% Apply Classifiers
% ==========================================================================
dirs = dir();
CurrDir = (pwd);
diary('JAABA_logfile.log')
for p = 1:numel(dirs)
    if ~dirs(p).isdir
      continue;
    end
    JAABAname = dirs(p).name;
    if ismember(JAABAname,{'.','..'})
      continue;
    end 
    diary on
    cd ([JAABAname]);
    disp(['Now applying classifiers for: ' JAABAname]);
    
    
   
    error_handling_wrapper('JAABA_errors.log','JAABADetect',[JAABAname '_JAABA'],'jablistfile',JABFiles);
    diary off
    cd (CurrDir)
    
end
exit
