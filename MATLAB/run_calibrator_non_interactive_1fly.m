% add our MATLAB code to path if its not there already
check = which('AutoTracking');
if isempty(check)
    parentdir = fileparts(mfilename('fullpath'));
    addpath(genpath(parentdir));
end

# still need to add the tracker path though ..
# this is not as clean as above, but might clean up later.
addpath(genpath('../../FlyTracker'));


# The variable "OutputDirectory" and "FileName" are passed to the script when running from bash
# Do I need to change directory?
cd ([OutputDirectory '/' FileName]);







videos=dir(['*.' video_type]);
videonames={videos.name};
videonamestr=cellfun(@(vid) strrep(vid,'.ufmf',''), videonames,'UniformOutput',false);
cellfun(@(videoname) mkdir(videoname), videonamestr);
calibfilenames=cellfun(@(vidname) strcat(vidname,'_calibration.mat'), videonamestr,'UniformOutput',false);

% if we pass the number of flies into this script, then there doesn't need to be 3 versions of it and we
% could just append the number of flies to the function name (maybe?)
cellfun(@(vid,calibfilename) error_handling_wrapper([OutputDirectory '/' FileName '/Logs/calibration_errors.log'],'calibrator_non_interactive_1fly',char(vid),char(calibfilename)),videonames,calibfilenames,'UniformOutput',false);


exit;
