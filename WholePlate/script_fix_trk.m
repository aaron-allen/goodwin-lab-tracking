
addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/WholePlate'));
startdir=pwd;
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
    cd(dirname);
    error_handling_wrapper('trk_for_visualizer_errors.log','fix_trk','../track_correction.mat','../feat_correction.mat')
   cd(startdir);
end

exit

