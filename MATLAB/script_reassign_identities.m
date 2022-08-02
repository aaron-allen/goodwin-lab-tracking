
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







% Make/Move backups to backups folder

disp('Moving track and feat files to backup directory ...');
movefile([OutputDirectory '/' FileName '/' FileName '/' FileName '-track_old.mat'], ...
         [OutputDirectory '/' FileName '/Backups/' FileName '-track--backup_3_pre_reassign_identities.mat']);
movefile([OutputDirectory '/' FileName '/' FileName '/' FileName '-feat_old.mat'], ...
         [OutputDirectory '/' FileName '/Backups/' FileName '-feat--backup_3_pre_reassign_identities.mat']);
movefile([OutputDirectory '/' FileName  '/calibration_old.mat'], ...
         [OutputDirectory '/' FileName '/Backups/calibration--backup_3_pre_reassign_identities.mat']);
delete([OutputDirectory '/' FileName '/calibration_id_corrected.mat']);
delete([OutputDirectory '/' FileName '/' FileName '/' FileName '-track_id_corrected.mat']);
delete([OutputDirectory '/' FileName '/' FileName '/' FileName '-feat_id_corrected.mat']);


disp('Moving JAABA files to backup directory ...');
movefile([OutputDirectory '/' FileName '/' FileName '/' FileName '_JAABA/trx.mat'], ...
         [OutputDirectory '/' FileName '/Backups/' FileName '_JAABA/trx--backup_3_pre_reassign_identities.mat']);
movefile([OutputDirectory '/' FileName '/' FileName '/' FileName '_JAABA/trx_id_corrected.mat'], ...
         [OutputDirectory '/' FileName '/' FileName '/' FileName '_JAABA/trx.mat']);
perframeDataFiles = dir([OutputDirectory '/' FileName '/' FileName '/' FileName '_JAABA/perframe/*.mat']);
for P = 1:length(perframeDataFiles)
    if endsWith(perframeDataFiles(P).name, 'id_corrected.mat')
        continue;
    end
 movefile([perframeDataFiles(P).folder '/' perframeDataFiles(P).name], ...
          [OutputDirectory '/' FileName '/Backups/' FileName '_JAABA/perframe/' perframeDataFiles(P).name(1:end-4) '--backup_3_pre_reassign_identities.mat']);
end
perframeDataFiles = dir([OutputDirectory '/' FileName '/' FileName '/' FileName '_JAABA/perframe/*id_corrected.mat']);
for P = 1:length(perframeDataFiles)
    movefile([perframeDataFiles(P).folder '/' perframeDataFiles(P).name], ...
          [perframeDataFiles(P).folder '/' perframeDataFiles(P).name(1:end-17) '.mat']);
end

scoresDataFiles = dir([OutputDirectory '/' FileName '/' FileName '/' FileName '_JAABA/scores_*.mat']);
for P = 1:length(scoresDataFiles)
    if endsWith(scoresDataFiles(P).name, 'id_corrected.mat')
        continue;
    end
    movefile([scoresDataFiles(P).folder '/' scoresDataFiles(P).name], ...
             [OutputDirectory '/' FileName '/Backups/' FileName '_JAABA/' scoresDataFiles(P).name(1:end-4) '--backup_3_pre_reassign_identities.mat']);
end
scoresDataFiles = dir([OutputDirectory '/' FileName '/' FileName '/' FileName '_JAABA/perframe/*id_corrected.mat']);
for P = 1:length(scoresDataFiles)
    movefile([scoresDataFiles(P).folder '/' scoresDataFiles(P).name], ...
             [scoresDataFiles(P).folder '/' scoresDataFiles(P).name(1:end-17) '.mat']);
end



exit
