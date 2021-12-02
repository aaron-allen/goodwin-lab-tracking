
% add our MATLAB code to path if its not there already
check = which('DiagnosticPlots');
if isempty(check)
    parentdir = fileparts(mfilename('fullpath'));
    addpath(genpath(parentdir));
end


# The variable "OutputDirectory" and "FileName" are passed to the script when running from bash
# Do I need to change directory?
cd ([OutputDirectory '/' FileName]);


disp(['Now reassigning identities for: ' FileName]);
error_handling_wrapper('identity_assignment_errors.log','reassign_identities',FileName)

exit
