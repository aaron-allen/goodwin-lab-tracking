% Aaron M. Allen, 2019.01.04
% 
% Added a bit of code to asses the number of flies per chamber, and if it varies
% between chambers, to delete the offending rows from the trx.mat file. The Classifiers
% have been trained assuming that there are 2 flies in each chamber, and won't work if
% there isn't (except maybe the WingGesture).


% If the average flies per chamber is between 1 and 2 (ie was supposed to be 2, but
% a fly died or escaped from a chamber), then the below deletes the entry in the trx.mat
% file for the remaining fly in the offending chambers. This will allow the social
% classifiers to be applied without issue.

% 2019.01.03 - added sections to deal with a single fly in a
% chamber that isn't at the end of the trx and perframe data. First
% I make a logical array for the id's that are in a 1 fly chamber,
% then delete the rows from the trx file, then renumber the id's in
% the trx file, then apply the logical array to delete the columns
% in the perframe data.

% Also added bit to delete the data for the singleton flies from the
% track.mat and feat.mat files, as well as renumber the id's in the
% trk.flies_in_chambers structure so they correspond to the trx file.


% 
% ==========================================================================
dirs = dir();
CurrDir = (pwd);
diary('DeleteSingleFly_logfile.log')
diary on
disp(datetime('now'));
for p = 1:numel(dirs)
    if ~dirs(p).isdir
      continue;
    end
    DIRname = dirs(p).name;
    if ismember(DIRname,{'.','..'})
      continue;
    end 
    cd (DIRname);
    TrackDir =(pwd);
    
    % load files
    TrackFile = dir('*track.mat');
    disp(['Loading ' TrackFile.name]);
    load(TrackFile.name);
    cd ([DIRname '_JAABA']);
    disp('Loading trx.mat')
    load('trx.mat');

    % Determining the average number of flies per chamber
    disp('Counting flies per chamber')
    TotalFlies = 0;
    for F = 1:size(trk.flies_in_chamber,2)
        TotalFlies = TotalFlies + size(trk.flies_in_chamber{F},2);
    end
    FliesPerChamber = TotalFlies/size(trk.flies_in_chamber,2);
    fprintf('Average number of flies per chamber is %f.\n',FliesPerChamber);

    if (1 < FliesPerChamber) && (FliesPerChamber < 2)
        disp('The number of flies differs between chambers');
        save('trxBackup.mat', 'trx', 'timestamps');
        
        % Create a logical array of the location of the singleton flies
        disp('Creating logical array of the location of the singleton flies');
        LM = [];
        for N = 1:size(trk.flies_in_chamber,2)
            if size(trk.flies_in_chamber{N},2) == 1
                LM = [LM, 1];
            else
                LM = [LM, 0, 0];
            end
        end
        LM = boolean(LM);

        % deleting single fly trx data
        disp('Deleting row(s) in trx file');
        for N = 1:size(trk.flies_in_chamber,2)
            if size(trk.flies_in_chamber{N},2) == 1
                trx([trx.id]==trk.flies_in_chamber{N}) = [];
            end
        end
        disp('Re-numbering Ids in trx file');
        for I = 1:length(trx)
            trx(I).id = I;
        end
        save('trx.mat', 'trx', 'timestamps')

        % deleting single fly perframe data
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
        disp('Renumbering flies_in_chambers in trk file');
        save([DIRname '-trackBackup.mat'], 'trk');
        trk.flies_in_chamber = [];
        for A = 1:(size(trx,2)/2)
            trk.flies_in_chamber{A} = [2.*A-1,2.*A];
        end
        disp('Deleting row(s) from track file');
        trk.data(LM,:,:) = [];
        save(TrackFile.name, 'trk');

        % deleting single fly feat data
        disp('Deleting row(s) from feat file');
        FeatFile = dir('*feat.mat');
        load(FeatFile.name);
        save([DIRname '-featBackup.mat'], 'feat');
        feat.data(LM,:,:) = [];
        save(FeatFile.name, 'feat');
        
    else
        if (FliesPerChamber == 2)
            disp('There are 2 flies per chamber.')
        else
            if (FliesPerChamber == 1)
                disp('There is 1 fly per chamber.')
            end
        end
    end
    cd (CurrDir)
end
disp('ALL DONE!')
diary off
exit
