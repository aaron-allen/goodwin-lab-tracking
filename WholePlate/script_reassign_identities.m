
addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/WholePlate'));
addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/reassing_identities'));
dirs = dir();

for p = 1:numel(dirs)
    if ~dirs(p).isdir
      continue;
    end
    dirname = dirs(p).name;
    if ismember(dirname,{'.','..'})
      continue;
    end 
    
    disp(['Now reassigning identities for: ' dirname]);
    error_handling_wrapper('identity_assignment_errors.log','reassign_identities',dirname)
end

exit

