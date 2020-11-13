%Annika Rings, Nov 2020
%This function is for deleting specific flies (by FlyId) from the tracking
%before applying classifiers. This can be used in case tracking was
%unsuccessful and would cause JAABA to fail. Input argument is a matrix of
%flyIDs (or a single number)
function DeleteSpecificFlies(flynumbers)


currentdir =pwd;
dirs = dir();


for p = 1:numel(dirs)
    if ~dirs(p).isdir
        continue;
    end
    DIRname = dirs(p).name;
    if ismember(DIRname,{'.','..','Results','Logs','Backups'})
        continue;
    end
    cd (DIRname);
    TrackDir =(pwd);
    % load files
    TrackFilename = strcat(DIRname,'-track_old.mat');
    if ~exist(TrackFilename,'file')
        TrackFilename = strcat(DIRname,'-track.mat');
    end
    TrackFilename_new = strcat(DIRname,'-track.mat');
    FeatFilename = strcat(DIRname,'-feat_old.mat');
    if ~exist(FeatFilename,'file')
        FeatFilename = strcat(DIRname,'-feat.mat');
    end
    FeatFilename_new = strcat(DIRname,'-feat.mat');
    disp(['Loading ' TrackFilename]);
    load(TrackFilename);
    load(FeatFilename);
    cd ([DIRname '_JAABA']);
    disp('Loading trx.mat')
    load('trx.mat');
    LM2=zeros(1,size(trk.data,1));
    LM2(flynumbers)=1;
    LM=boolean(LM2);
    num2delete = size(flynumbers,2);
    sortedFlynumbers=sort (flynumbers,'descend');
    if num2delete ~=0
        disp('Deleting row(s) in trx file');
        sizetrx = size(trx,2);
        for i = 1:num2delete
            flytodelete = sortedFlynumbers(i);
            for j = flytodelete:sizetrx-1
                trx(j)=trx(j+1);
            end
        end
        
        trx(sizetrx+1-num2delete:sizetrx)=[];
        
        disp('Re-numbering Ids in trx file');
        for I = 1:length(trx)
            trx(I).id = I;
        end
        save('trx.mat', 'trx', 'timestamps');
    end
    disp('Deleting data from perframe files:');
    cd perframe
    mkdir BackupPerframe
    perframeDataFiles = dir('*.mat');
    for P = 1:length(perframeDataFiles)
        copyfile(perframeDataFiles(P).name, ['BackupPerframe/Backup_' perframeDataFiles(P).name]);
        load(perframeDataFiles(P).name);
        
        disp(['    ' perframeDataFiles(P).name]);
        data(:,LM)=[];
        save(perframeDataFiles(P).name, 'data', 'units');
    end
    
    % renumbering flies_in_chambers and deleting single fly trk data
    cd (TrackDir);
    save([DIRname '-trackBackup.mat'], 'trk');
    disp('Renumbering flies_in_chambers in trk file');
    trk.flies_in_chamber = [];
        for A = 1:(size(trx,2)/2)
            trk.flies_in_chamber{A} = [2.*A-1,2.*A];
        end
    
     disp('Deleting row(s) from track file');
        trk.data(LM,:,:) = [];
        save(TrackFilename_new, 'trk');
        save([DIRname '-featBackup.mat'], 'feat');
 disp('Deleting row(s) from feat file');
        feat.data(LM,:,:) = [];
        save(FeatFilename_new, 'feat');

    cd(currentdir);
end