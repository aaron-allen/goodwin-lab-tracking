% add our MATLAB code to path if its not there already
check = which('DiagnosticPlots');
if isempty(check)
    parentdir = fileparts(mfilename('fullpath'));
    addpath(genpath(parentdir));
end


# The variable "OutputDirectory" and "FileName" are passed to the script when running from bash
# Do I need to change directory?
cd ([OutputDirectory ',' FileName]);




disp(['Now reassigning identities for: ' FileName]);
cd(FileName);
error_handling_wrapper('trk_for_visualizer_errors.log','fix_trk','../track_correction.mat','../feat_correction.mat')

exit
