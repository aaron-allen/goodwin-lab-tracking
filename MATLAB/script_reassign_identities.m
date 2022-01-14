
% add our MATLAB code to path if its not there already
check = which('AutoTracking');
if isempty(check)
    parentdir = fileparts(mfilename('fullpath'));
    addpath(genpath(parentdir));
end


% The variable "OutputDirectory" and "FileName" are passed to the script when running from bash
% Do I need to change directory?
cd ([OutputDirectory '/' FileName]);


disp(['Now reassigning identities for: ' FileName]);
error_handling_wrapper([OutputDirectory '/' FileName '/Logs/identity_assignment_errors.log'],'reassign_identities',FileName)



movefile([OutputDirectory '/' FileName '/' FileName '/' FileName '-track_old.mat'], ...
         [OutputDirectory '/' FileName '/Backups/' FileName '-track--backup_3_pre_reassign_identities.mat']);
movefile([OutputDirectory '/' FileName '/' FileName '/' FileName '-feat_old.mat'], ...
         [OutputDirectory '/' FileName '/Backups/' FileName '-feat--backup_3_pre_reassign_identities.mat']);
delete([OutputDirectory '/' FileName '/' FileName '/' FileName '-track_id_corrected.mat']);
delete([OutputDirectory '/' FileName '/' FileName '/' FileName '-feat_id_corrected.mat']);


exit
