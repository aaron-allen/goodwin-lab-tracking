
% add our MATLAB code to path if its not there already
check = which('AutoTracking');
if isempty(check)
    parentdir = fileparts(mfilename('fullpath'));
    addpath(genpath(parentdir));
end




% The variable "OutputDirectory" and "FileName" are passed to the script when running from bash
% Do I need to change directory?
cd ([OutputDirectory '/' FileName]);




numframes = tracking_duration*60*FPS;
disp(['Now detecting optogenetic light for: ' FileName]);
error_handling_wrapper([OutputDirectory '/' FileName '/Logs/optogenetic_light_detection_errors.log'],'ison',videoname,numframes);


exit
