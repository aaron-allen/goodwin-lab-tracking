
% add our MATLAB code to path if its not there already
check = which('AutoTracking');
if isempty(check)
    parentdir = fileparts(mfilename('fullpath'));
    addpath(genpath(parentdir));
end




# The variable "OutputDirectory" and "FileName" are passed to the script when running from bash
# Do I need to change directory?
cd ([OutputDirectory '/' FileName]);




videoname = strcat(FileName,'.',video_type);
disp(['Now detecting optogenetic light for: ' FileName]);
error_handling_wrapper([OutputDirectory '/' FileName '/Logs/optogenetic_light_detection_errors.log'],'ison',videoname,22500);


exit
