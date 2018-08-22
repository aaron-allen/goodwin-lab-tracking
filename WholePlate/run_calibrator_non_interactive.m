addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/FlyTracker-1.0.5'));
addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/WholePlate'));
videos=dir('*.ufmf');
videonames={videos.name};
videonamestr=cellfun(@(vid) strrep(vid,'.ufmf',''), videonames,'UniformOutput',false);
calibfilenames=cellfun(@(vidname) strcat(vidname,'_calibration.mat'), videonamestr,'UniformOutput',false);
cellfun(@(vid,calibfilename) error_handling_wrapper('calibration_errors.log','calibrator_non_interactive',char(vid),char(calibfilename)),videonames,calibfilenames,'UniformOutput',false);

    
    