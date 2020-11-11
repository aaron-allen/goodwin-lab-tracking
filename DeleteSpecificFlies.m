function DeleteSpecificFlies(flynumbers)

currentdir =pwd;


disp('Deleting data from perframe files:');
cd perframe
mkdir BackupPerframe
perframeDataFiles = dir('*.mat');
for P = 1:length(perframeDataFiles)
    copyfile(perframeDataFiles(P).name, ['BackupPerframe/Backup_' perframeDataFiles(P).name]);
    load(perframeDataFiles(P).name);
    LM2=zeros(1,size(data,2));
    LM2(flynumbers)=1;
    LM=boolean(LM2);
    disp(['    ' perframeDataFiles(P).name]);
    data(:,LM)=[];
    save(perframeDataFiles(P).name, 'data', 'units');
end
cd(currentdir);