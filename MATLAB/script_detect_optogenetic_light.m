addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/WholePlate'));
addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/reassign_identities'));
dirs = dir();

for p = 1:numel(dirs)
    if ~dirs(p).isdir
      continue;
    end
    dirname = dirs(p).name;
    videoname = strcat(dirname,'.ufmf');
    if ismember(dirname,{'.','..'})
      continue;
    end 
    
    disp(['Now detecting optogenetic light for: ' dirname]);
    error_handling_wrapper('optogenetic_light_detection_errors.log','ison',videoname,22500);
   
end

exit

